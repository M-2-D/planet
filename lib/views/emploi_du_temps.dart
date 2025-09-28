import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.w,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (cours['discipline'] ?? 'Non définie').toString().toUpperCase(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 16.sp, color: amberColor),
              SizedBox(width: 6.w),
              Text(
                cours['heure']?.replaceAll('-', ' - ') ?? '--:--',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: textDark,
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
                    Icon(Icons.person_outline, size: 16.sp, color: amberColor),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        cours['professeur'] ?? 'Non défini',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: textDark,
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
                    Icon(Icons.place_outlined, size: 16.sp, color: amberColor),
                    SizedBox(width: 6.w),
                    Text(
                      'Salle ${cours['salle']?.toString().replaceAll('Salle ', '') ?? 'Non définie'}',
                      style: TextStyle(
                        fontSize: 13.sp,
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
    // INITIALISATION IMPORTANTE
    ScreenUtil.init(context, designSize: Size(393, 851));

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
      ),
      drawer: MenuDrawer(primaryColor: primaryColor),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header établissement
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  color: Colors.white,
                  child: Text(
                    'ETABLISSEMENT SIMEN FORMATION (2024-2025)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Section utilisateur
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  color: Colors.white,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: amberColor.withOpacity(0.2),
                        radius: 18.r,
                        child: Icon(Icons.person, color: amberColor, size: 22.sp),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${userInfo["prenom"] ??""} ${userInfo["nom"] ?? ""}',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: textDark),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.chevron_right,
                                  size: 18.sp,
                                  color: textMedium
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${userInfo["classe"] ?? "Classe ?"}',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: textDark),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${userInfo["ien"] ?? ""}',
                            style: TextStyle(
                              color: textMedium,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                // Container principal
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6.w,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header "EMPLOI DU TEMPS"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: primaryColor, size: 22.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'EMPLOI DU TEMPS',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Navigation date
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left, color: primaryColor, size: 20.sp),
                              onPressed: () => _changeDate(-1),
                              padding: EdgeInsets.all(4.w),
                              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                            ),
                            Expanded(
                              child: Text(
                                displayDateFormat.format(currentDate),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right, color: primaryColor, size: 20.sp),
                              onPressed: () => _changeDate(1),
                              padding: EdgeInsets.all(4.w),
                              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      if (filteredCours.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Text(
                            'Aucun cours prévu pour ce jour',
                            style: TextStyle(
                              color: textLight,
                              fontSize: 15.sp,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: filteredCours
                              .map((cours) => _buildCoursItem(cours))
                              .toList(),
                        ),
                      SizedBox(height: 60.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.w,
              offset: Offset(0, -2.h),
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