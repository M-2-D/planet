import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../views/dashboard.dart';
import '../../views/menu_drawer.dart';
import '../../views/discipline_list.dart';

class EmploiDuTempsPage extends StatefulWidget {
  @override
  _EmploiDuTempsPageState createState() => _EmploiDuTempsPageState();
}

class _EmploiDuTempsPageState extends State<EmploiDuTempsPage> {
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  List<dynamic> emploiDuTemps = [];
  DateTime currentDate = DateTime.now();
  final DateFormat apiDateFormat = DateFormat('EEE, dd MMM, yyyy', 'fr_FR');
  final DateFormat displayDateFormat = DateFormat('EEE, dd MMM yyyy', 'fr_FR');


  final Color primaryColor = Color(0xFF4666DB);
  final Color amberColor = Color(0xFFFFC107);
  final Color blueColor = Color(0xFF2599FB);
  final Color petroleBlue = Color(0xFF006699);
  final Color textDark = Color(0xFF333333);
  final Color textMedium = Color(0xFF666666);
  final Color textLight = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadUserData();
    await _loadEmploiDuTemps();
  }

  Future<void> _loadUserData() async {
    try {
      userInfo = await ApiService.getUserInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement infos utilisateur')),
      );
    }
  }

  Future<void> _loadEmploiDuTemps() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.getEmploiDuTemps();
      if (mounted) {
        setState(() {
          emploiDuTemps = response['emploi du temps'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          emploiDuTemps = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString().replaceAll("Exception: ", "")}')),
        );
      }
    }
  }

  void _changeDate(int days) {
    setState(() {
      currentDate = currentDate.add(Duration(days: days));
    });
  }

  String _normalizeDate(String dateStr) {
    return dateStr
        .toLowerCase()
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll(',', '');
  }

  Widget _buildCoursItem(Map<String, dynamic> cours) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (cours['discipline'] ?? 'Non définie').toString().toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: amberColor),
              SizedBox(width: 8),
              Text(
                cours['heure']?.replaceAll('-', ' - ') ?? '--:--',
                style: TextStyle(
                  fontSize: 14,
                  color: textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: amberColor),
                    SizedBox(width: 8),
                    Text(
                      cours['professeur'] ?? 'Non défini',
                      style: TextStyle(
                        fontSize: 14,
                        color: textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.place_outlined, size: 18, color: amberColor),
                    SizedBox(width: 8),
                    Text(
                      'Salle ${cours['salle']?.toString().replaceAll('Salle ', '') ?? 'Non définie'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDateFormatted = apiDateFormat.format(currentDate);
    final filteredCours = emploiDuTemps.where((cours) {
      final coursDate = cours['date']?.toString() ?? '';
      return _normalizeDate(coursDate) == _normalizeDate(currentDateFormatted);
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/planet.png',
          height: 40,
          fit: BoxFit.contain,
        ),
       // centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: MenuDrawer(primaryColor: primaryColor),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Text(
                'ETABLISSEMENT SIMEN FORMATION (2024-2025)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: amberColor.withOpacity(0.2),
                    radius: 20,
                    child: Icon(Icons.person, color: amberColor, size: 24),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userInfo["prenom"] ?? ""} ${userInfo["nom"] ?? ""} / ${userInfo["classe"] ?? "Classe ?"}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textDark,
                        ),
                      ),
                      Text(
                        '${userInfo["ien"] ?? ""}',
                        style: TextStyle(
                          color: textMedium,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
           /* Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Text(
                'Classe: ${userInfo["classe"] ?? 'Non définie'}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),*/

            SizedBox(height: 12),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'EMPLOI DU TEMPS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: primaryColor),
                          onPressed: () => _changeDate(-1),
                        ),
                        Expanded(
                          child: Text(
                            displayDateFormat.format(currentDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: primaryColor),
                          onPressed: () => _changeDate(1),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  if (filteredCours.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Aucun cours prévu pour ce jour',
                        style: TextStyle(
                          color: textLight,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: filteredCours
                          .map((cours) => _buildCoursItem(cours))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        margin: EdgeInsets.zero,
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon( Icons.dashboard),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          currentIndex: 1,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            }
            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DisciplineListPage(semester: 1)),
              );
            }
          },
        ),
      ),
    );
  }
}