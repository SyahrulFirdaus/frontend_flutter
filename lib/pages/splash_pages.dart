import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // CEK SESSION SETELAH 2 DETIK
    Future.delayed(const Duration(seconds: 2), () {
      final auth = Get.find<AuthController>();

      if (auth.isLoggedIn) {
        Get.offAllNamed(auth.isAdmin ? '/admin' : '/user');
      } else {
        Get.offAllNamed('/login');
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade300],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Absensi App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Memeriksa session...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
