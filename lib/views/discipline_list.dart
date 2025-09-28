import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/api_service.dart';
import '../../views/dashboard.dart';
import '../../views/menu_drawer.dart';
import 'Evaluation.dart';
import 'emploi_du_temps.dart';

class DisciplineListPage extends StatefulWidget {
  final int semester;

  const DisciplineListPage({Key? key, required this.semester}) : super(key: key);

  @override
  _DisciplineListPageState createState() => _DisciplineListPageState();
}

class _DisciplineListPageState extends State<DisciplineListPage> {
  List<dynamic> disciplines = [];
  bool isLoading = true;
  Map<String, dynamic> userInfo = {};

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      userInfo = await ApiService.getUserInfo();
      final ien = userInfo['ien'];
      if (ien != null) {
        final data = await ApiService.getDisciplines(widget.semester);
        setState(() {
          disciplines = data;
          isLoading = false;
        });
      } else {
        throw Exception('IEN non disponible');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  String _formatDisciplineName(String rawName) {
    final acronyms = ['SVT', 'PC', 'HG', 'EPS'];
    final upperName = rawName.toUpperCase();

    if (acronyms.any((acronym) => upperName == acronym)) {
      return upperName;
    }

    return rawName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // ✅ INITIALISATION IMPORTANTE
    ScreenUtil.init(context, designSize: Size(393, 851));

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: MenuDrawer(primaryColor: primaryColor),
      appBar: _buildAppBar(),
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
          height: 32.h, // ✅ CORRIGÉ
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: Colors.white,
              size: 24.sp), // ✅ CORRIGÉ
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifications')),
            );
          },
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
          SizedBox(height: 8.h), // ✅ CORRIGÉ
          _buildSemesterHeader(),
          _buildDisciplinesList(),
        ],
      ),
    );
  }

  Widget _buildSchoolHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h), // ✅ CORRIGÉ
      color: Colors.white,
      child: Text(
        'ETABLISSEMENT SIMEN FORMATION (2024-2025)',
        style: TextStyle(
          fontSize: 12.sp, // ✅ CORRIGÉ
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // ✅ CORRIGÉ
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: amberColor.withOpacity(0.2),
            radius: 18.r, // ✅ CORRIGÉ
            child: Icon(Icons.person, color: amberColor, size: 22.sp), // ✅ CORRIGÉ
          ),
          SizedBox(width: 10.w), // ✅ CORRIGÉ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${userInfo["prenom"] ??""} ${userInfo["nom"] ?? ""}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: textDark), // ✅ CORRIGÉ
                    ),
                    SizedBox(width: 4.w), // ✅ CORRIGÉ
                    Icon(Icons.chevron_right,
                        size: 18.sp, // ✅ CORRIGÉ
                        color: textMedium
                    ),
                    SizedBox(width: 4.w), // ✅ CORRIGÉ
                    Text(
                      '${userInfo["classe"] ?? "Classe ?"}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: textDark), // ✅ CORRIGÉ
                    ),
                  ],
                ),
                SizedBox(height: 2.h), // ✅ CORRIGÉ
                Text(
                  '${userInfo["ien"] ?? ""}',
                  style: TextStyle(
                    color: textMedium,
                    fontSize: 13.sp, // ✅ CORRIGÉ
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h), // ✅ CORRIGÉ
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assessment, color: primaryColor, size: 20.sp), // ✅ CORRIGÉ
              SizedBox(width: 8.w), // ✅ CORRIGÉ
              Text(
                'EVALUATIONS PAR DISCIPLINES',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp, // ✅ CORRIGÉ
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplinesList() {
    if (disciplines.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16.w), // ✅ CORRIGÉ
        padding: EdgeInsets.all(14.w), // ✅ CORRIGÉ
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r), // ✅ CORRIGÉ
        ),
        child: Text(
          'Aucune discipline disponible pour ce semestre',
          style: TextStyle(color: textMedium, fontSize: 14.sp), // ✅ CORRIGÉ
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // ✅ CORRIGÉ
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r), // ✅ CORRIGÉ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.w, // ✅ CORRIGÉ
            offset: Offset(0, 2.h), // ✅ CORRIGÉ
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: disciplines.length,
        itemBuilder: (context, index) {
          final discipline = disciplines[index];
          final displayName = _formatDisciplineName(discipline['nom'] ?? 'Discipline inconnue');

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EvaluationsPage(
                    ien: userInfo['ien'] ?? '',
                    disciplineName: displayName,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(14.w), // ✅ CORRIGÉ
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == disciplines.length - 1
                        ? Colors.transparent
                        : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w, // ✅ CORRIGÉ
                    height: 36.h, // ✅ CORRIGÉ
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.school, color: blueColor, size: 20.sp), // ✅ CORRIGÉ
                  ),
                  SizedBox(width: 10.w), // ✅ CORRIGÉ
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textDark,
                        fontSize: 15.sp, // ✅ CORRIGÉ
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: blueColor, size: 22.sp), // ✅ CORRIGÉ
                ],
              ),
            ),
          );
        },
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
        currentIndex: 2,
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
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          }
        },
      ),
    );
  }
}