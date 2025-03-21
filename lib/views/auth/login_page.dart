import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController ienController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Gestion du chargement

  // Fonction de connexion
  Future<void> _login() async {
    setState(() => isLoading = true);

    final response = await ApiService.login(
      ienController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (response != null) {
      // Redirection après succès
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'authentification")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF4666DB),
      body: Stack(
        children: [
          // Partie blanche (Formulaire)
          //const SizedBox(height: 15),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),

                  // Champ IEN
                  TextField(
                    controller: ienController,
                    decoration: InputDecoration(
                      hintText: "Votre IEN",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Champ Code Temporaire
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Votre Code Temporaire",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Bouton de connexion
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login, // Désactive pendant le chargement
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4666DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Se Connecter",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Texte en haut (Planète Élève)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "PLANETE ELEVE",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
