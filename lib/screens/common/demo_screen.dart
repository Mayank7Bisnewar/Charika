import 'package:flutter/material.dart';

import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../auth/otp_screen.dart';
import '../common/location_permission_screen.dart';
import '../main/main_screen.dart';
import '../ride/search_destination_screen.dart';
import '../ride/map_screen.dart';
import '../ride/confirm_ride_screen.dart';
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carika Demo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _demoButton(
            context,
            "Splash Screen",
            const SplashScreen(),
          ),
          _demoButton(
            context,
            "Onboarding Screen",
            const OnboardingScreen(),
          ),
          _demoButton(
            context,
            "Login Screen",
            const LoginScreen(),
          ),
          _demoButton(
            context,
            "OTP Screen",
            const OtpScreen(),
          ),
          _demoButton(
            context,
            "Location Permission",
            const LocationPermissionScreen(),
          ),
          _demoButton(
            context,
            "Main Screen",
            const MainScreen(),
          ),
          _demoButton(
            context,
            "Search Destination",
            const SearchDestinationScreen(),
            
          ),
             _demoButton(
             context,
              "Map Screen",
             const MapScreen(),
             ),
             _demoButton(
               context,
              "Confirm Ride",
              const ConfirmRideScreen(),
              ),
        ],
      ),
    );
  }

  Widget _demoButton(
      BuildContext context,
      String title,
      Widget screen,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Text(title),
      ),
    );
  }
}