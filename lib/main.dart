import 'package:flutter/material.dart';
import 'views/auth/login_page.dart';
import 'views/home.dart';

void main() {
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
        "/home": (context) => const HomePage(), // Définir la route Home
      },
    );
  }
}
