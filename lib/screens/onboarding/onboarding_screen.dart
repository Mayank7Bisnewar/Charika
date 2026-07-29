import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const Spacer(),

              const Icon(
                Icons.local_taxi,
                size: 120,
              ),

              const SizedBox(height: 30),

              Text(
                "Ride Smarter with Carika",
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                "Book rides quickly, track your driver in real time and travel safely.",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              PrimaryButton(
                text: "Get Started",
                onPressed: () {},
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}