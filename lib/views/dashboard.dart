import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../views/emploi_du_temps.dart';
import '../../views/discipline_list.dart';
import '../../views/menu_drawer.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// Modèle pour les statistiques
class StatItemModel {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  StatItemModel({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> plannings = [];
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  bool _isPressed = false;

  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Données statistiques
  int totalAbsences = 0;
  int totalRetards = 0;
  int totalEvaluations = 0;
  bool isLoadingStats = false;

  // Couleurs globales
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
        final evaluations = await ApiService.getEvaluations(ien);
        setState(() {
          totalEvaluations = evaluations.length;
          totalAbsences = 3; // À remplacer par API réelle
          totalRetards = 1;  // À remplacer par API réelle
          isLoadingStats = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingStats = false);
      print('Erreur lors du chargement des statistiques : $e');
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
      final startTimeParts = times[0].trim().split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endTimeParts = times[1].trim().split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;

      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } catch (e) {
      print('Erreur lors du parsing de l\'heure : $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // INITIALISATION IMPORTANTE POUR LA RESPONSIVITÉ
    ScreenUtil.init(context, designSize: Size(393, 851));

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
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.white.withOpacity(0.8),
          BlendMode.modulate,
        ),
        child: Image.asset(
          'assets/logo_white_eleve.png',
          height: 32.h,
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: Colors.white,
              size: 24.sp),
          onPressed: () {
            print('Notifications pressed');
          },
        ),
      ],
    );
  }

  Widget _buildLoader() => Center(child: CircularProgressIndicator());

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSchoolHeader(),
          _buildStudentInfo(),
          SizedBox(height: 8.h),
          _buildDailySchedule(),
          SizedBox(height: 12.h),
          _buildStatisticsSection(),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildSchoolHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      color: Colors.white,
      child: Text(
        'ETABLISSEMENT SIMEN FORMATION (2024-2025)',
        style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: textMedium
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h
      ),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: amberColor.withOpacity(0.2),
            radius: 18.r,
            child: Icon(Icons.person,
                color: amberColor,
                size: 22.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${userInfo["prenom"] ??""} ${userInfo["nom"] ?? ""}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: textDark
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right,
                        size: 18.sp,
                        color: textMedium
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${userInfo["classe"] ?? "Classe ?"}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: textDark
                      ),
                    ),
                  ],
                ),
                Text(
                  '${userInfo["ien"] ?? ""}',
                  style: TextStyle(
                      color: textMedium,
                      fontSize: 13.sp
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
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.w,
            offset: Offset(0, 2.h)
        )],
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
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: primaryColor,
                  size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text(
            formattedDate,
            style: TextStyle(
                fontSize: 14.sp,
                color: textMedium
            ),
          ),
        ),
        Container(height: 1.h, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildCoursesList() {
    if (plannings.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: Text(
          'Aucun cours prévu pour aujourd\'hui.',
          style: TextStyle(color: textMedium),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: plannings.asMap().entries.map((entry) {
          int index = entry.key;
          var planning = entry.value;
          final bool isCurrentCourse = _isCurrentCourse(planning['heure'] ?? '');

          return Container(
            margin: EdgeInsets.only(
                top: index == 0 ? 12.h : 8.h
            ),
            decoration: BoxDecoration(
              gradient: isCurrentCourse
                  ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [blueColor, currentCourseEndColor])
                  : null,
              color: isCurrentCourse ? null : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: isCurrentCourse
                      ? primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isCurrentCourse ? 10.w : 6.w,
                  offset: Offset(0, 2.h),
                  spreadRadius: isCurrentCourse ? 1.w : 0,
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
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
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isCurrentCourse ? Colors.white : primaryColor,
                          ),
                        ),
                      ),
                      if (isCurrentCourse)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h
                          ),
                          decoration: BoxDecoration(
                            color: currentCourseBadgeColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow,
                                  color: Colors.white,
                                  size: 14.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'EN COURS',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16.sp,
                          color: isCurrentCourse ? Colors.white70 : amberColor),
                      SizedBox(width: 6.w),
                      Text(
                        planning['heure']?.replaceAll('-', ' - ') ?? '--:--',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isCurrentCourse ? Colors.white : textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 16.sp,
                                color: isCurrentCourse ? Colors.white70 : amberColor),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                planning['professeur'] ?? 'Non défini',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isCurrentCourse ? Colors.white : textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 16.sp,
                                color: isCurrentCourse ? Colors.white70 : amberColor),
                            SizedBox(width: 6.w),
                            Text(
                              'Salle ${planning['salle']?.toString().replaceAll('Salle ', '') ?? 'Non définie'}',
                              style: TextStyle(
                                fontSize: 13.sp,
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
      padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h
      ),
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
                    fontSize: 13.sp,
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
                    fontSize: 13.sp,
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

  Widget _buildStatisticsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // --- Widget Absences & Retards ---
          Expanded(
            child: _buildImprovedStatCard(
              title: 'ABSENCES',
              iconData: Icons.warning_amber_rounded,
              gradientColors: [Color(0xFFE53E3E), Color(0xFFFA7D7D)],
              items: [
                StatItemModel(label: 'Abs', value: totalAbsences, icon: Icons.cancel, color: Colors.white),
                StatItemModel(label: 'Rtrd', value: totalRetards, icon: Icons.schedule, color: Colors.white),
              ],
              onTap: () {},
            ),
          ),
          SizedBox(width: 16.w),
          // --- Widget Évaluations ---
          Expanded(
            child: _buildImprovedStatCard(
              title: 'ÉVALUATIONS',
              iconData: Icons.assessment,
              gradientColors: [Color(0xFF4299E1), Color(0xFF90CDF4)],
              items: [
                StatItemModel(
                    label: 'Total', value: totalEvaluations, icon: Icons.quiz, color: Color(0xFF006699)),
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisciplineListPage(semester: 1)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovedStatCard({
    required String title,
    required IconData iconData,
    required List<Color> gradientColors,
    required List<StatItemModel> items,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: onTap,
      child: AnimatedScale(
        duration: Duration(milliseconds: 150),
        scale: (_isPressed && onTap != null) ? 0.98 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.w,
                offset: Offset(0, 4.h),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(iconData, color: Colors.white, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (items.length == 1)
                  Row(
                    children: [
                      Icon(items[0].icon, size: 18.sp, color: items[0].color),
                      SizedBox(width: 10.w),
                      Text(
                        '${items[0].label}: ${items[0].value}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  )
                else if (items.length >= 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(items[0].icon, size: 18.sp, color: items[0].color),
                            SizedBox(width: 8.w),
                            Text(
                              '${items[0].label}: ${items[0].value}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(items[1].icon, size: 18.sp, color: items[1].color),
                            SizedBox(width: 8.w),
                            Text(
                              '${items[1].label}: ${items[1].value}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
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
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r), // ✅ CORRIGÉ
          topRight: Radius.circular(20.r), // ✅ CORRIGÉ
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.w, // ✅ CORRIGÉ
            offset: Offset(0, -2.h), // ✅ CORRIGÉ
          ),
        ],
      ),
      margin: EdgeInsets.zero,
      child: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
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