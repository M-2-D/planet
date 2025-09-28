import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../views/emploi_du_temps.dart';
import '../../views/dashboard.dart';
import '../../views/discipline_list.dart';
import '../../views/changer_mot_de_passe.dart';
import '../../views/auth/login_page.dart';
import '../../services/api_service.dart';

class MenuDrawer extends StatelessWidget {
  final Color primaryColor;

  const MenuDrawer({required this.primaryColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(393, 851));

    return Drawer(
      width: 280.w,
      child: Column(
        children: [
          // HEADER AVEC HAUTEUR ADAPTATIVE
          Container(
            height: 130.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/logo_white_eleve.png',
                height: 55.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // CONTENU SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 8.h),

                  // SECTION PRINCIPALE
                  _buildMenuSection(
                    context,
                    [
                      _buildMenuTile(context, Icons.dashboard, 'Tableau de bord', DashboardScreen()),
                      _buildMenuTile(context, Icons.calendar_today, 'Emploi du temps', EmploiDuTempsPage()),
                      _buildMenuTile(context, Icons.assessment, 'Évaluations', DisciplineListPage(semester: 1)),
                      _buildMenuTileWithAction(context, Icons.access_time, 'Absences et retards', () => Navigator.pop(context)),
                      _buildMenuTileWithAction(context, Icons.bar_chart, 'Moyennes semestrielles', () => Navigator.pop(context)),
                      _buildMenuTileWithAction(context, Icons.description, 'Bulletins semestriels', () => Navigator.pop(context)),
                    ],
                  ),

                  Divider(height: 24.h, thickness: 1.h),

                  // SECTION SECONDaire
                  _buildMenuSection(
                    context,
                    [
                      _buildMenuTile(context, Icons.lock, 'Changement mot de passe', ChangerMotDePasse()),
                      _buildLogoutTile(context),
                    ],
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, List<Widget> children) {
    return Column(
      children: children,
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, Widget page) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryColor,
          size: 22.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        minLeadingWidth: 20.w,
        visualDensity: VisualDensity.compact,
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  Widget _buildMenuTileWithAction(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryColor,
          size: 22.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        minLeadingWidth: 20.w,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: ListTile(
        leading: Icon(
          Icons.logout,
          color: Colors.red,
          size: 22.sp,
        ),
        title: Text(
          'Déconnexion',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        minLeadingWidth: 20.w,
        visualDensity: VisualDensity.compact,
        onTap: () async {
          Navigator.pop(context);
          final navigator = Navigator.of(context);
          await ApiService.logout();
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
          );
        },
      ),
    );
  }
}