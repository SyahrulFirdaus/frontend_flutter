import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController authController = Get.find();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var nameError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () => authController.isLoading.value
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memproses registrasi...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ini Header
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
                            'Buat Akun Admin',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Isi data dengan lengkap',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Name Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        errorText: nameError.value.isEmpty
                            ? null
                            : nameError.value,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) => nameError.value = '',
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'contoh@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.blue),
                        errorText: emailError.value.isEmpty
                            ? null
                            : emailError.value,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) => emailError.value = '',
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimal 6 karakter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        errorText: passwordError.value.isEmpty
                            ? null
                            : passwordError.value,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) => passwordError.value = '',
                    ),

                    const SizedBox(height: 8),

                    // Password Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Password minimal 6 karakter dan akan dienkripsi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'REGISTER ADMIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Back to Login
                    Center(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Sudah punya akun? Login',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                            '• Ini adalah halaman register untuk membuat akun ADMIN',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Setelah register, silahkan login menggunakan akun yang baru dibuat',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Untuk membuat akun USER, Anda harus login sebagai ADMIN terlebih dahulu',
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

  void _register() {
    // Reset error
    nameError.value = '';
    emailError.value = '';
    passwordError.value = '';

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validasi
    bool isValid = true;

    if (name.isEmpty) {
      nameError.value = 'Nama wajib diisi';
      isValid = false;
    } else if (name.length < 3) {
      nameError.value = 'Nama minimal 3 karakter';
      isValid = false;
    }

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

    // Tampilkan konfirmasi
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Anda akan mendaftar sebagai ADMIN. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Panggil controller register
              authController
                  .register(
                    name,
                    email,
                    password,
                    'admin', // Role admin
                  )
                  .then((_) {
                    // Tampilkan snackbar hijau setelah berhasil register
                    Get.snackbar(
                      'Berhasil',
                      'Berhasil tambah admin baru',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 3),
                    );

                    // Clear form setelah berhasil
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                  });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Daftar'),
          ),
        ],
      ),
    );
  }
}
