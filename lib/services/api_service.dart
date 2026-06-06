import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // --- 1. Login API Call ---
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final data = responseJson['data'] ?? responseJson;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        if (data['familyId'] != null) {
          await prefs.setInt('familyId', data['familyId']);
        }

        if (data['userId'] != null) {
          await prefs.setInt('userId', data['userId']);
        }

        return true;
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return false;
  }

  // --- 2. Get Balance API Call ---
  static Future<String> getBalance() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? familyId = prefs.getInt('familyId');

      if (token == null || familyId == null) return "0.00";

      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/balance/$familyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'].toString();
        } else {
          return decoded.toString();
        }
      }
    } catch (e) {
      print('Balance Error: $e');
    }
    return "0.00";
  }

  // --- 3. Add Transaction (Income/Expense) API Call ---
  static Future<bool> addTransaction(
    int categoryId,
    double amount,
    String note,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('userId');

      if (token == null || userId == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/transactions/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'categoryId': categoryId,
          'amount': amount,
          'transactionDate': DateTime.now().toIso8601String().split('T')[0],
          'note': note,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Add Transaction Error: $e');
    }
    return false;
  }

  // --- 4. Register API Call ---
  static Future<bool> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
    required bool isCreatingNewFamily,
    String? familyName,
    int? joinFamilyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'fullName': fullName,
          'email': email,
          'password': password,
          'isCreatingNewFamily': isCreatingNewFamily,
          'familyName': familyName,
          'joinFamilyId': joinFamilyId,
          'role': isCreatingNewFamily ? 'PARENT' : 'MEMBER',
        }),
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        return responseJson['data'] == true || response.body == 'true';
      }
      return false;
    } catch (e) {
      print('Register Error: $e');
      return false;
    }
  }

  // --- 5. Logout Function ---
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --- 6. Get Transaction History ---
  static Future<List<dynamic>> getTransactionHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? familyId = prefs.getInt('familyId');

      if (token == null || familyId == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/history/$familyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded.containsKey('content')) {
          var dataContent = decoded['content'];
          if (dataContent is List) {
            return dataContent;
          }
        }
        else if (decoded is Map && decoded.containsKey('data')) {
          var dataContent = decoded['data'];
          if (dataContent is List) {
            return dataContent;
          }
        } else if (decoded is List) {
          return decoded;
        }
      }
    } catch (e) {
      print('History Error: $e');
    }
    return [];
  }
}
