import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Perbaikan: Gunakan Get.find dengan benar
  final AuthController authController = Get.find<AuthController>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailKosong = false.obs;
  final passwordKosong = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Obx(
        () => authController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Silahkan Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    Obx(
                      () => TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                          errorText: emailKosong.value
                              ? 'Email tidak boleh kosong'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Obx(
                      () => TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          errorText: passwordKosong.value
                              ? 'Password tidak boleh kosong'
                              : null,
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        emailKosong.value = email.isEmpty;
                        passwordKosong.value = password.isEmpty;

                        if (email.isEmpty || password.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Anda belum input data email atau password',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        authController.login(email, password);
                      },
                      child: const Text('Login'),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
