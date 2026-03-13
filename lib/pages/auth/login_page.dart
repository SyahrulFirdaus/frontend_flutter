import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = Get.find<AuthController>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var emailError = ''.obs;
  var passwordError = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => authController.isLoading.value
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memproses login...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Selamat Datang',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silahkan login untuk melanjutkan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email Field
                    Obx(
                      () => TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'contoh@email.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.blue,
                          ),
                          errorText: emailError.value.isEmpty
                              ? null
                              : emailError.value,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => emailError.value = '',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    Obx(
                      () => TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.blue,
                          ),
                          errorText: passwordError.value.isEmpty
                              ? null
                              : passwordError.value,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) => passwordError.value = '',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.snackbar(
                            'Informasi',
                            'Fitur lupa password sedang dalam pengembangan',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // HAPUS BAGIAN REGISTER LINK
                    const SizedBox(height: 30),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.blue.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Informasi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Gunakan akun yang sudah terdaftar',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Hubungi administrator jika mengalami kendala',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _login() {
    // Reset error
    emailError.value = '';
    passwordError.value = '';

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validasi
    bool isValid = true;

    if (email.isEmpty) {
      emailError.value = 'Email wajib diisi';
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Format email tidak valid';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Password wajib diisi';
      isValid = false;
    } else if (password.length < 6) {
      passwordError.value = 'Password minimal 6 karakter';
      isValid = false;
    }

    if (!isValid) return;

    // Panggil controller login
    authController.login(email, password);
  }
}
