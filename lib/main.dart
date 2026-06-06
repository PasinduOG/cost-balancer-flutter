import 'package:flutter/material.dart';

// ඔයාගේ Screens ටික
import 'package:cost_balancer_app/features/presentation/add_cash.dart';
import 'package:cost_balancer_app/features/presentation/dashboard.dart';
import 'package:cost_balancer_app/features/presentation/get_cash.dart';
import 'package:cost_balancer_app/features/presentation/settings.dart';
import 'package:cost_balancer_app/features/presentation/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cost Balancer',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginScreen(), 
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    AddCashScreen(),
    GetCashScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_upward), label: 'Add Cash'),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_downward), label: 'Get Cash'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}