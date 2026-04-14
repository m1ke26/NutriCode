import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Mobile if width < 600px, otherwise desktop/web
    final isMobile = screenWidth < 600;
    final bgImage = isMobile
        ? 'assets/images/NUTRICODE_LOGIN.png'
        : 'assets/images/NUTRICODE_LOGIN_WEB.png';

    return Scaffold(
      backgroundColor: const Color(0xFFBDD5EA), // matches sky color
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            bgImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Get Started button at the bottom
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 32 : screenWidth * 0.3,
              ),
              child: Column(
                children: [
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B998B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF1B998B).withOpacity(0.4),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
