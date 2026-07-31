import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart'; 
import 'screens/auth/login_screen.dart'; 
import 'screens/auth/otp_screen.dart'; // OTP screen ka import
import 'screens/common/location_permission_screen.dart';
import 'screens/main/main_screen.dart'; 
import 'core/theme/app_theme.dart';
import 'screens/common/demo_screen.dart';
import 'screens/ride/confirm_ride_screen.dart';

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
      
      // 👇 TESTING KE LIYE COMMENTS 👇
      // Jis screen ko test karna hai use uncomment karein aur baaki ko comment kar dein.

      // 1. Splash (Run karo -> dikhao)
      //home: const SplashScreen(),

      // 2. Onboarding (Run karo -> dikhao)
      // home: const OnboardingScreen(),

      // 3. Login (Run karo -> dikhao)
      //home: const LoginScreen(),

      // 4. OTP (Run karo -> dikhao)
      // home: const OtpScreen(),

      // 5. Location Permission (Run karo -> dikhao)
      // home: const LocationPermissionScreen(),

       //6. Main App (Ye dikhate hi Home, Activity aur Profile teenon dikh jayenge)
     // home: const MainScreen(), 
     
     //Search Destination
      home: const DemoScreen(),
     //home: const ConfirmRideScreen(),
    );
  }
}