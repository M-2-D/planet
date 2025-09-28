import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class EvaluationsPage extends StatefulWidget {
  final String ien;
  final String disciplineName;

  const EvaluationsPage({
    Key? key,
    required this.ien,
    required this.disciplineName,
  }) : super(key: key);

  @override
  _EvaluationsPageState createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {
  List<Map<String, dynamic>> evaluations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getEvaluations(widget.ien);
      final List<Map<String, dynamic>> filteredEvaluations = _extractAndFilterEvaluations(result);

      setState(() {
        evaluations = filteredEvaluations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
        evaluations = [];
      });
    }
  }

  List<Map<String, dynamic>> _extractAndFilterEvaluations(dynamic apiResult) {
    if (apiResult == null) {
      throw Exception("Aucune donnée reçue depuis l'API");
    }

    List<dynamic> rawEvaluations = [];

    // Extraire les évaluations selon le format reçu
    if (apiResult is Map<String, dynamic>) {
      if (apiResult.containsKey('evaluations') && apiResult['evaluations'] is List) {
        rawEvaluations = apiResult['evaluations'];
      } else {
        throw Exception("Format de réponse API invalide : clé 'evaluations' manquante ou incorrecte");
      }
    } else if (apiResult is List) {
      rawEvaluations = apiResult;
    } else {
      throw Exception("Format de réponse API non supporté");
    }

    // Filtrer et convertir les évaluations
    List<Map<String, dynamic>> validEvaluations = [];

    for (var eval in rawEvaluations) {
      if (eval is Map<String, dynamic>) {
        // Vérifier si l'évaluation correspond à la matière demandée
        String? matiere = eval['matiere']?.toString();
        if (matiere != null &&
            matiere.toLowerCase().trim() == widget.disciplineName.toLowerCase().trim()) {
          validEvaluations.add(eval);
        }
      }
    }

    return validEvaluations;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "Date inconnue";
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return "Date invalide";
    }
  }

  Widget _buildNoteWidget(dynamic note) {
    String noteText;
    Color backgroundColor;
    Color textColor;

    if (note == null || note.toString().isEmpty || note == "Aucune note disponible") {
      noteText = "Aucune note disponible";
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else {
      noteText = "Note : $note/20";
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        noteText,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(Map<String, dynamic> evaluation) {
    final String type = evaluation['nom']?.toString() ?? "Évaluation non définie";
    final String date = _formatDate(evaluation['date']?.toString());
    final String heure = evaluation['heure']?.toString() ?? "Heure inconnue";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: const Icon(
          Icons.assignment,
          color: Color(0xFF4666DB),
          size: 28,
        ),
        title: Text(
          type,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("Date : $date"),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("Heure : $heure"),
                ],
              ),
              SizedBox(height: 8),
              _buildNoteWidget(evaluation['note']),
            ],
          ),
        ),
      ),
    );
  }

  @override
  /*
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disciplineName),
        backgroundColor: Color(0xFF4666DB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Évaluations en ${widget.disciplineName}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4666DB),
              ),
            ),
            SizedBox(height: 16),

            if (isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF4666DB),
                      ),
                      SizedBox(height: 16),
                      Text("Chargement des évaluations..."),
                    ],
                  ),
                ),
              )
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Erreur lors du chargement",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEvaluations,
                        child: Text("Réessayer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4666DB),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (evaluations.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        const Text(
                          "Aucune évaluation trouvée",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Il n'y a pas encore d'évaluation pour cette matière.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadEvaluations,
                    child: ListView.builder(
                      itemCount: evaluations.length,
                      itemBuilder: (context, index) {
                        return _buildEvaluationCard(evaluations[index]);
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

   */

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disciplineName),
        backgroundColor: Color(0xFF4666DB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Évaluations en ${widget.disciplineName}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (evaluations.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Aucune évaluation trouvée pour cette discipline.",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                    ),

                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: evaluations.length,
                  itemBuilder: (context, index) {
                    final eval = evaluations[index];
                    final type = eval['nom'];
                    final note = eval['note'];
                    final date = eval['date'];
                    final heure = eval['heure'];

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Icon(
                          Icons.assignment,
                          color: Color(0xFF4666DB),
                        ),
                        title: Text(
                          type ?? "Évaluation non définie",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Date : ${DateFormat('dd/MM/yyyy').format(DateTime.parse(date))}"),
                              SizedBox(height: 4),
                              Text("Heure : $heure"),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: note != null &&
                                      note != "Aucune note disponible"
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  note != null &&
                                      note != "Aucune note disponible"
                                      ? "Note : $note/20"
                                      : "Note : Aucune note disponible",
                                  style: TextStyle(
                                    color: note != null &&
                                        note != "Aucune note disponible"
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }


}