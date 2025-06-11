import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/auth/login_page.dart';
import 'views/dashboard.dart';

void main() async {
  // S'assurer que Flutter est initialisé avant d'utiliser des plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la localisation française
  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planete Eleve',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        "/dashboard": (context) => DashboardScreen(),
      },
    );
  }
}