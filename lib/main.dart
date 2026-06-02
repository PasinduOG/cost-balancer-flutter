import 'package:cost_balancer_app/features/presentation/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cost Balancer",
      home: LoginPage(),
      theme: ThemeData(
        fontFamily: 'Manrope',
        primaryColor: Colors.green,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
        )
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
