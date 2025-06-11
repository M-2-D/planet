import 'package:flutter/material.dart';
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
  List<dynamic> evaluations = [];
  bool isLoading = true;


  final Color primaryColor = Color(0xFF4666DB);
  final Color amberColor = Color(0xFFFFC107);
  final Color blueColor = Color(0xFF2599FB);
  final Color petroleBlue = Color(0xFF006699);
  final Color textDark = Color(0xFF333333);
  final Color textMedium = Color(0xFF666666);
  final Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getEvaluations(widget.ien);
      setState(() {
        evaluations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.disciplineName.toUpperCase()),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildEvaluationsContent(),
    );
  }

  Widget _buildEvaluationsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: primaryColor.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              'PREMIER SEMESTRE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 20),

          if (evaluations.isEmpty)
            Center(
              child: Text(
                'Aucune évaluation disponible',
                style: TextStyle(color: textMedium),
              ),
            )
          else
            ...evaluations.map((evaluation) =>
                _buildEvaluationCard(evaluation)
            ).toList(),

          // Section Salle
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Salle 2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(Map<String, dynamic> evaluation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (evaluations.indexOf(evaluation) != 0)
          Divider(height: 30, thickness: 1, color: Colors.grey[300]),


        Text(
          evaluation['nom']?.toUpperCase() ?? 'ÉVALUATION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),

        SizedBox(height: 8),


        if (evaluation['note'] != null && evaluation['note'] != "Aucune note disponible")
          Text(
            'NOTE: ${evaluation['note']}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          )
        else
          Text(
            'AUCUNE NOTE DISPONIBLE',
            style: TextStyle(
              fontSize: 14,
              color: textMedium,
              fontStyle: FontStyle.italic,
            ),
          ),

        SizedBox(height: 8),


        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: textMedium),
            SizedBox(width: 6),
            Text(
              evaluation['date'] ?? 'Date non spécifiée',
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.access_time, size: 16, color: textMedium),
            SizedBox(width: 6),
            Text(
              evaluation['heure'] ?? 'Heure non spécifiée',
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}