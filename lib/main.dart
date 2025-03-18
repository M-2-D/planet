import 'package:flutter/material.dart';
import 'views/auth/login_page.dart'; // Assure-toi que ce chemin est correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Supprime le bandeau "Debug"
      title: 'Planete Eleve',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Définir la page de connexion comme page d'accueil
    );
  }
}
