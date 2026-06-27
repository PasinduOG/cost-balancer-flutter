import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cost_balancer_app/features/presentation/add_cash.dart';
import 'package:cost_balancer_app/features/presentation/dashboard.dart';
import 'package:cost_balancer_app/features/presentation/get_cash.dart';
import 'package:cost_balancer_app/features/presentation/settings.dart';
import 'package:cost_balancer_app/features/presentation/login.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Cost Balancer',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
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
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role');
    });
  }

  List<Widget> _getScreens() {
    List<Widget> screens = [
      const DashboardScreen(),
    ];

    if (_role != 'CHILD') {
      screens.add(const AddCashScreen());
    }

    screens.add(const GetCashScreen());
    screens.add(const SettingsScreen());
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    // Only build the UI once role is loaded to avoid index flickering
    if (_role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = _getScreens();

    return Scaffold(
      body: screens[_currentIndex],
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
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          if (_role != 'CHILD')
            const BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward),
              label: 'Add Cash',
            ),
          const BottomNavigationBarItem(icon: Icon(Icons.arrow_downward), label: 'Get Cash'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
