import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../views/emploi_du_temps.dart';
import '../../views/discipline_list.dart';
import '../../views/menu_drawer.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> plannings = [];
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Nouvelles variables pour les statistiques
  int totalAbsences = 0;
  int totalRetards = 0;
  int totalEvaluations = 0;
  bool isLoadingStats = false;

  final Color primaryColor = Color(0xFF4666DB);
  final Color amberColor = Color(0xFFFFC107);
  final Color blueColor = Color(0xFF2599FB);
  final Color petroleBlue = Color(0xFF006699);
  final Color textDark = Color(0xFF333333);
  final Color textMedium = Color(0xFF666666);
  final Color textLight = Color(0xFF999999);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color currentCourseStartColor = Color(0xFF6C8EFF);
  final Color currentCourseEndColor = Color(0xFF4666DB);
  final Color currentCourseBadgeColor = Color(0xFF00C853);
  final Color redColor = Color(0xFFE53E3E);
  final Color orangeColor = Color(0xFFFF6B35);
  final Color greenColor = Color(0xFF38A169);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      userInfo = await ApiService.getUserInfo();
      final planningData = await ApiService.getPlanning(currentDate);
      setState(() {
        plannings = planningData ?? [];
        isLoading = false;
      });

      // Charger les statistiques en parallèle
      _loadStatistics();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoadingStats = true);
    try {
      final ien = userInfo['ien'];
      if (ien != null) {
        // Simuler le chargement des statistiques
        // À remplacer par vos vraies méthodes API
        final evaluations = await ApiService.getEvaluations(ien);

        setState(() {
          totalEvaluations = evaluations.length;
          // Vous devrez ajouter ces méthodes dans votre ApiService
          // totalAbsences = await ApiService.getAbsences(ien);
          // totalRetards = await ApiService.getRetards(ien);

          // Valeurs temporaires pour la démonstration
          totalAbsences = 3; // À remplacer par l'API réelle
          totalRetards = 1;  // À remplacer par l'API réelle

          isLoadingStats = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingStats = false);
      print('Erreur chargement statistiques: $e');
    }
  }

  String _getWeekdayName(int weekday) {
    return DateFormat.EEEE('fr_FR')
        .format(DateTime.now().subtract(Duration(days: DateTime.now().weekday - weekday)))
        .capitalize();
  }

  bool _isCurrentCourse(String hourRange) {
    try {
      final times = hourRange.split('-');
      if (times.length != 2) return false;

      final now = DateTime.now();
      final currentTime = TimeOfDay.fromDateTime(now);

      // Parse start time
      final startTimeParts = times[0].trim().split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);

      // Parse end time
      final endTimeParts = times[1].trim().split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      // Convert to minutes for easier comparison
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;

      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } catch (e) {
      print('Error parsing time: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      drawer: MenuDrawer(primaryColor: primaryColor),
      body: isLoading ? _buildLoader() : _buildContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/planet.png',
        height: 40,
        fit: BoxFit.contain,
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSchoolHeader(),
          _buildStudentInfo(),
          SizedBox(height: 12),
          _buildDailySchedule(),
          SizedBox(height: 16),
          _buildStatisticsSection(), // Remplace _buildEvaluationsSection()
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSchoolHeader() {
    return Container(
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
    );
  }

  Widget _buildStudentInfo() {
    return Container(
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
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }

  Widget _buildDailySchedule() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
          _buildSectionHeader(Icons.calendar_today, 'PLANNING DU JOUR'),
          _buildCoursesList(),
          _buildScheduleLink(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EE, dd MMM yyyy', 'fr_FR').format(now);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (title == 'PLANNING DU JOUR')
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 16,
                color: textMedium,
              ),
            ),
          ),
        Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    if (plannings.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Aucun cours prévu pour aujourd\'hui.',
          style: TextStyle(color: textMedium),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: plannings.map<Widget>((planning) {
          final bool isCurrentCourse = _isCurrentCourse(planning['heure'] ?? '');

          return Container(
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              gradient: isCurrentCourse
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ blueColor,currentCourseEndColor],
              )
                  : null,
              color: isCurrentCourse ? null : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isCurrentCourse
                      ? primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isCurrentCourse ? 10 : 6,
                  offset: Offset(0, 2),
                  spreadRadius: isCurrentCourse ? 1 : 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (planning['discipline'] ?? 'Non définie').toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrentCourse ? Colors.white : primaryColor,
                          ),
                        ),
                      ),
                      if (isCurrentCourse)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentCourseBadgeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'EN COURS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: isCurrentCourse ? Colors.white70 : amberColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        planning['heure']?.replaceAll('-', ' - ') ?? '--:--',
                        style: TextStyle(
                          fontSize: 14,
                          color: isCurrentCourse ? Colors.white : textDark,
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
                            Icon(
                              Icons.person_outline,
                              size: 18,
                              color: isCurrentCourse ? Colors.white70 : amberColor,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                planning['professeur'] ?? 'Non défini',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isCurrentCourse ? Colors.white : textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 18,
                              color: isCurrentCourse ? Colors.white70 : amberColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Salle ${planning['salle']?.toString().replaceAll('Salle ', '') ?? 'Non définie'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isCurrentCourse ? Colors.white : textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmploiDuTempsPage()),
            );
          },
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Emploi du temps",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    decorationThickness: 1.0,
                    decorationColor: primaryColor,
                  ),
                ),
                TextSpan(
                  text: " >",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NOUVELLE SECTION : Widgets statistiques
  Widget _buildStatisticsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Widget Absences et Retards
              Expanded(
                child: _buildStatCard(
                  'ABSENCES & RETARDS',
                  Icons.warning_amber_rounded,
                  redColor,
                  isLoadingStats,
                  children: [
                    _buildStatItem('Absences', totalAbsences, Icons.cancel, redColor),
                    SizedBox(height: 8),
                    _buildStatItem('Retards', totalRetards, Icons.schedule, orangeColor),
                  ],
                  onTap: () {
                    // Navigation vers la page des absences/retards
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => AbsencesPage()));
                  },
                ),
              ),
              SizedBox(width: 16),
              // Widget Évaluations
              Expanded(
                child: _buildStatCard(
                  'ÉVALUATIONS',
                  Icons.assessment,
                  greenColor,
                  isLoadingStats,
                  children: [
                    _buildStatItem('Total', totalEvaluations, Icons.quiz, greenColor),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DisciplineListPage(semester: 1)),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16, color: primaryColor),
                          SizedBox(width: 4),
                          Text(
                            'Voir détails',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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

  Widget _buildStatCard(
      String title,
      IconData icon,
      Color color,
      bool isLoading, {
        List<Widget>? children,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (isLoading)
                Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (children != null)
                ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: textMedium,
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
            icon: Icon(Icons.dashboard),
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
        currentIndex: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmploiDuTempsPage()),
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
    );
  }
}