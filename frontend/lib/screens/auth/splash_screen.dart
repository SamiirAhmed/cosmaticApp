import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              FadeInDown(
                duration: const Duration(seconds: 1),
                child: Image.asset('assets/images/logo.png', height: 200),
              ),
              const SizedBox(height: 20),

              // Animated Business Name
              FadeInUp(
                duration: const Duration(seconds: 1),
                delay: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    const Text(
                      "MAA'IDO COSMATICS",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 1,
                          width: 30,
                          color: AppColors.primaryPeach,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "home of beuaty",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryPeach,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          width: 30,
                          color: AppColors.primaryPeach,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Get Started Button
              FadeIn(
                duration: const Duration(seconds: 1),
                delay: const Duration(milliseconds: 1000),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("let's Get Started"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
