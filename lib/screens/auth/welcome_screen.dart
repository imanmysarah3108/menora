// lib/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/app_router.dart';
import '../../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Find the book that you love',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.greyText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Placeholder for the book image
              Image.network(
                'https://placehold.co/200x200/BBDEFB/1E88E5?text=Books',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.book, size: 150, color: AppColors.primaryBlue);
                },
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Log In',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.loginRoute);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Sign Up',
                  backgroundColor: AppColors.lightBlue,
                  textColor: AppColors.darkBlue,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.signupRoute);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}