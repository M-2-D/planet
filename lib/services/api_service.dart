import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ApiService {
  //static const String baseUrl = "http://localhost:8000/api";
  static const String baseUrl = "http://10.0.2.2:8000/api";

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
        await _saveToken(data['token']);
        await _saveUserInfo(
          data['user']['ien'],
          data['user']['nom'],
          data['user']['prenom'],
          data['user']['classe'],


        );
        return data;
      } else {
        throw Exception("Échec de la connexion : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");
      return null;
    }
  }


  static Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }


  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Fonction pour sauvegarder les informations de l'utilisateur
  static Future<void> _saveUserInfo(String ien, String nom, String prenom, String classe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("ien", ien);
    await prefs.setString("nom", nom);
    await prefs.setString("prenom", prenom);
    await prefs.setString("classe", classe ?? '');

  }

  // Fonction pour récupérer les infos de l'utilisateur
  static Future<Map<String, String?>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "ien": prefs.getString("ien"),
      "nom": prefs.getString("nom"),
      "prenom": prefs.getString("prenom"),
      "classe":prefs.getString("classe")

    };
  }


  // Fonction pour récupérer le planning d'un élève à une date donnée
  static Future<List<dynamic>?> getPlanning(String date) async {
    try {
      String? token = await getToken();
      Map<String, String?> userInfo = await getUserInfo();
      String? ien = userInfo["ien"];

      if (token == null || ien == null) {
        print("Token ou IEN manquant !");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/planning/$ien/$date"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('plannings')) {
          return data['plannings'];
        } else {
          print("Format de données innatendu inattendu: $data");
          return null;
        }
      } else {
        print("Erreur lors de la récupération du planning");
        return null;
      }
    } catch (e) {
      print("Erreur: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> getEmploiDuTemps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userInfo = await getUserInfo();

      if (token == null || userInfo['ien'] == null) {
        throw Exception('Authentification requise - IEN non disponible');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/emploi_du_temps/${userInfo['ien']}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> changerMotDePasse(String oldPassword, String newPassword) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Authentification requise');
      }

      final response = await http.post(
        Uri.parse("$baseUrl/changer_mdp"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "ancien_mdp": oldPassword,
          "nouveau_mdp": newPassword,
        }),
      );

      print("Réponse brute: ${response.body}");

      if (response.statusCode == 200) {
        try {
          return json.decode(response.body);
        } catch (e) {
          throw Exception("Réponse API invalide: ${response.body}");
        }
      } else {
        throw Exception("Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors du changement de mot de passe: $e");
      rethrow;
    }
  }



  static Future<List<dynamic>> getDisciplines(int semester) async {
    try {
      final token = await getToken();
      final userInfo = await getUserInfo();
      final ien = userInfo['ien'];

      if (token == null || ien == null) {
        throw Exception('Authentification requise');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/liste_disciplines/$ien'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('disciplines')) {
          return data['disciplines'];
        }
        throw Exception('Format de réponse inattendu');
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur chargement disciplines: ${e.toString()}');
    }
  }

  static Future<List<dynamic>> getEvaluations(String ien) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Authentification requise');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/evaluation/$ien'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('evaluations')) {
          return data['evaluations'];
        }
        throw Exception('Format de réponse inattendu');
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur chargement évaluations: ${e.toString()}');
    }
  }

  static Future<bool> logout() async {
    try {

      final token = await getToken();


      if (token != null) {
        final response = await http.post(
          Uri.parse("$baseUrl/logout"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode != 200) {
          print("Erreur lors de la déconnexion API: ${response.statusCode}");
        }
      }

      await _clearLocalData();

      return true;
    } catch (e) {
      print("Erreur lors de la connexion: $e");
      return false;
    }
  }

  static Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}







