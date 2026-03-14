import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX Controllers
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final obscurePassword = true.obs;
    final emailError = ''.obs;
    final passwordError = ''.obs;

    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? _buildLoadingScreen()
            : _buildLoginScreen(
                context,
                emailController,
                passwordController,
                obscurePassword,
                emailError,
                passwordError,
              ),
      ),
    );
  }

  // ========== LOADING SCREEN ==========
  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Memproses login...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== LOGIN SCREEN ==========
  Widget _buildLoginScreen(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    RxBool obscurePassword,
    RxString emailError,
    RxString passwordError,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header dengan ilustrasi
              _buildHeader(),
              const SizedBox(height: 40),

              // Form Title
              const Text(
                'Masuk ke Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silahkan masuk untuk melanjutkan',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Form
              _buildEmailField(emailController, emailError),
              const SizedBox(height: 16),

              _buildPasswordField(
                passwordController,
                obscurePassword,
                passwordError,
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 24),

              // Login Button
              _buildLoginButton(
                emailController,
                passwordController,
                emailError,
                passwordError,
              ),

              const SizedBox(height: 24),

              // Info Card
              _buildInfoCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ========== HEADER DENGAN ILUSTRASI ==========
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade300, Colors.blue.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.fingerprint, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Absensi App',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Absensi Berbasis Lokasi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== EMAIL FIELD ==========
  Widget _buildEmailField(
    TextEditingController emailController,
    RxString emailError,
  ) {
    return Obx(
      () => TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'contoh@email.com',
          errorText: emailError.value.isEmpty ? null : emailError.value,
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.email_outlined,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) => emailError.value = '',
      ),
    );
  }

  // ========== PASSWORD FIELD ==========
  Widget _buildPasswordField(
    TextEditingController passwordController,
    RxBool obscurePassword,
    RxString passwordError,
  ) {
    return Obx(
      () => TextField(
        controller: passwordController,
        obscureText: obscurePassword.value,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Minimal 6 karakter',
          errorText: passwordError.value.isEmpty ? null : passwordError.value,
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.lock_outline,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword.value ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade600,
              size: 20,
            ),
            onPressed: () => obscurePassword.toggle(),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) => passwordError.value = '',
      ),
    );
  }

  // ========== LOGIN BUTTON ==========
  Widget _buildLoginButton(
    TextEditingController emailController,
    TextEditingController passwordController,
    RxString emailError,
    RxString passwordError,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _login(
          emailController,
          passwordController,
          emailError,
          passwordError,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Colors.blue.withOpacity(0.5),
        ),
        child: const Text(
          'MASUK',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ========== INFO CARD ==========
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Informasi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: Colors.blue.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gunakan akun yang sudah terdaftar',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: Colors.blue.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hubungi admin jika ada kendala',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== LOGIN VALIDATION ==========
  void _login(
    TextEditingController emailController,
    TextEditingController passwordController,
    RxString emailError,
    RxString passwordError,
  ) {
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
    Get.find<AuthController>().login(email, password);
  }
}
