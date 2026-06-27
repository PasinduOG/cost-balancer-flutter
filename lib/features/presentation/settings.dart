import 'package:cost_balancer_app/features/presentation/login.dart';
import 'package:cost_balancer_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _fullName = 'Loading...';
  String _role = 'Loading...';
  String _familyName = 'Loading...';
  int _familyId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? 'Unknown User';
      _role = prefs.getString('role') ?? 'Unknown Role';
      _familyName = prefs.getString('familyName') ?? 'Unknown Family';
      _familyId = prefs.getInt('familyId') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(_role, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.family_restroom, color: Colors.green),
            title: const Text('Family Group'),
            subtitle: Text('$_familyName (ID: $_familyId)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),

          // 🔒 Protected Feature: Only for PARENTS
          if (_role == 'PARENT') ...[
            ListTile(
              leading: const Icon(Icons.pie_chart, color: Colors.green),
              title: const Text('Monthly Budgets'),
              subtitle: const Text('Manage limits and goals'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // This matches .requestMatchers("/api/budgets/**").hasAuthority(ROLE_PARENT)
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.group_add, color: Colors.green),
              title: const Text('Manage Family Members'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
          ],

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await ApiService.logout();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
