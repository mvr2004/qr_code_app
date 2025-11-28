import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Main entry point of the QR Code application
// This initializes the Flutter app and sets up the main material app
// with the HomeScreen as the initial route.

void main() => runApp(const QRApp());

// Root widget of the QR Code application
// Configures the material app with basic theme and sets HomeScreen
// as the initial screen. All navigation starts from here.

class QRApp extends StatelessWidget {
  const QRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RDS QR Code App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      themeMode: ThemeMode.system, // segue o tema do sistema
      home: const HomeScreen(),
    );
  }
}