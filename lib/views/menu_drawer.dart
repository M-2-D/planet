import 'package:flutter/material.dart';
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Container(
              height: 100,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/planet.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          _buildMenuItem(context, Icons.dashboard, 'Tableau de bord', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          }),
          _buildMenuItem(context, Icons.calendar_today, 'Emploi du temps', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmploiDuTempsPage()),
            );
          }),
          _buildMenuItem(context, Icons.assessment, 'Évaluations', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DisciplineListPage(semester: 1)),
            );
          }),
          _buildMenuItem(context, Icons.access_time, 'Absences et retards', () {
            Navigator.pop(context);
          }),
          _buildMenuItem(context, Icons.bar_chart, 'Moyennes semestrielles', () {
            Navigator.pop(context);
          }),
          _buildMenuItem(context, Icons.description, 'Bulletins semestriels', () {
            Navigator.pop(context);

          }),
          Divider(),
          _buildMenuItem(context, Icons.lock, 'Changer mot de passe', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChangerMotDePasse()),
            );
          }),
          _buildMenuItem(context, Icons.logout, 'Déconnexion', () async {
            Navigator.pop(context);

            final navigator = Navigator.of(context);

            await ApiService.logout();

            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
            );

            navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}