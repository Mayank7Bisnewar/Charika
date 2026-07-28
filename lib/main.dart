import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
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
      home: const SplashScreen(),
    );
  }
}