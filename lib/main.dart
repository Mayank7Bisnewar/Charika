import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart'; 
import 'screens/auth/login_screen.dart'; 
import 'screens/common/location_permission_screen.dart';
import 'screens/main/main_screen.dart'; // Naya import MainScreen ke liye
import 'core/theme/app_theme.dart';

void main() {
  runApp(const CarikaApp());
}

class CarikaApp extends StatelessWidget {
  const CarikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carika',
      theme: AppTheme.lightTheme,
      home: const MainScreen(), // Ise temporarily MainScreen testing ke liye change kiya
    );
  }
}