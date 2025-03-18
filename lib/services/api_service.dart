import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static const String baseUrl = "http://localhost:8000/api";
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // Fonction de connexion
  static Future<Map<String, dynamic>?> login(String ien, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ien": ien,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']); // Sauvegarde le token
        return data; // Retourne les données de l'utilisateur
      } else {
        return null; // Échec de l'authentification
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");
      return null;
    }
  }

  // Fonction pour sauvegarder le token
  static Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // Fonction pour récupérer le token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }


}
