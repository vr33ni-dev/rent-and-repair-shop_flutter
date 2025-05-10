import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const SurfShopApp());
}

class SurfShopApp extends StatelessWidget {
  const SurfShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent and Repair Shop Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}
