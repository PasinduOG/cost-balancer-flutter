import 'dart:convert';
import 'package:cost_balancer_app/features/presentation/login.dart';
import 'package:cost_balancer_app/main.dart';
import 'package:flutter/material.dart';
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

        if (data['fullName'] != null) {
          await prefs.setString('fullName', data['fullName']);
        }

        if (data['role'] != null) {
          await prefs.setString('role', data['role']);
        }

        if (data['familyName'] != null) {
          await prefs.setString('familyName', data['familyName']);
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
      } else if (response.statusCode == 401) {
        _handle401();
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
          'transactionTime': DateTime.now()
              .toIso8601String()
              .split('T')[1]
              .split('.')[0],
          'note': note,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        _handle401();
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

      print('--- REGISTER RESPONSE ---');
      print('Status: ${response.statusCode} | Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  static void _handle401() async {
    await logout();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
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
        } else if (decoded is Map && decoded.containsKey('data')) {
          var dataContent = decoded['data'];
          if (dataContent is List) {
            return dataContent;
          }
        } else if (decoded is List) {
          return decoded;
        }
      } else if (response.statusCode == 401) {
        _handle401();
      }
    } catch (e) {
      print('History Error: $e');
    }
    return [];
  }

  // --- 7. Add New Category ---
  static Future<bool> addCategory(String name, String type) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/api/categories/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name, 'type': type}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        _handle401();
      }
    } catch (e) {
      print('Add Category Error: $e');
    }
    return false;
  }

  // --- 8. Get Categories By Type ---
  static Future<List<dynamic>> getCategories(String type) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/categories?type=$type'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded.containsKey('content')) {
          return decoded['content'] ?? [];
        } else if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'] ?? [];
        } else if (decoded is List) {
          return decoded;
        }
      } else if (response.statusCode == 401) {
        _handle401();
      }
    } catch (e) {
      print('Get Categories Error: $e');
    }
    return [];
  }
}
