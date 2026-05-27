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
      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.grey,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
        )
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
