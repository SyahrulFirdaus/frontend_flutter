// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final AuthController authController = Get.find<AuthController>();

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   var emailError = ''.obs;
//   var passwordError = ''.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//       ),
//       body: Obx(
//         () => authController.isLoading.value
//             ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Memproses login...'),
//                   ],
//                 ),
//               )
//             : SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 20),

//                     // Header
//                     Center(
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.admin_panel_settings,
//                               size: 40,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Selamat Datang',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Silahkan login untuk melanjutkan',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // Email Field
//                     Obx(
//                       () => TextField(
//                         controller: emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText: 'Email',
//                           hintText: 'contoh@email.com',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           prefixIcon: const Icon(
//                             Icons.email,
//                             color: Colors.blue,
//                           ),
//                           errorText: emailError.value.isEmpty
//                               ? null
//                               : emailError.value,
//                           filled: true,
//                           fillColor: Colors.grey.shade50,
//                         ),
//                         onChanged: (value) => emailError.value = '',
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Password Field
//                     Obx(
//                       () => TextField(
//                         controller: passwordController,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           hintText: 'Masukkan password',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           prefixIcon: const Icon(
//                             Icons.lock,
//                             color: Colors.blue,
//                           ),
//                           errorText: passwordError.value.isEmpty
//                               ? null
//                               : passwordError.value,
//                           filled: true,
//                           fillColor: Colors.grey.shade50,
//                         ),
//                         onChanged: (value) => passwordError.value = '',
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     // Forgot Password Link
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           Get.snackbar(
//                             'Informasi',
//                             'Fitur lupa password sedang dalam pengembangan',
//                             backgroundColor: Colors.orange,
//                             colorText: Colors.white,
//                             snackPosition: SnackPosition.BOTTOM,
//                           );
//                         },
//                         child: Text(
//                           'Lupa Password?',
//                           style: TextStyle(
//                             color: Colors.blue.shade700,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // Login Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 55,
//                       child: ElevatedButton(
//                         onPressed: _login,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 3,
//                         ),
//                         child: const Text(
//                           'LOGIN',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),

//                     // HAPUS BAGIAN REGISTER LINK
//                     const SizedBox(height: 30),

//                     // Info Card
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.info,
//                                 color: Colors.blue.shade700,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'Informasi',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             '• Gunakan akun yang sudah terdaftar',
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             '• Hubungi administrator jika mengalami kendala',
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   void _login() {
//     // Reset error
//     emailError.value = '';
//     passwordError.value = '';

//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     // Validasi
//     bool isValid = true;

//     if (email.isEmpty) {
//       emailError.value = 'Email wajib diisi';
//       isValid = false;
//     } else if (!GetUtils.isEmail(email)) {
//       emailError.value = 'Format email tidak valid';
//       isValid = false;
//     }

//     if (password.isEmpty) {
//       passwordError.value = 'Password wajib diisi';
//       isValid = false;
//     } else if (password.length < 6) {
//       passwordError.value = 'Password minimal 6 karakter';
//       isValid = false;
//     }

//     if (!isValid) return;

//     // Panggil controller login
//     authController.login(email, password);
//   }
// }
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
  final obscurePassword = true.obs;

  var emailError = ''.obs;
  var passwordError = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => authController.isLoading.value
            ? _buildLoadingScreen()
            : _buildLoginScreen(),
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
  Widget _buildLoginScreen() {
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
              _buildEmailField(),
              const SizedBox(height: 16),

              _buildPasswordField(),
              const SizedBox(height: 8),

              // HAPUS LINK LUPA PASSWORD
              const SizedBox(height: 24),

              // Login Button
              _buildLoginButton(),

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
  Widget _buildEmailField() {
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
  Widget _buildPasswordField() {
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
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _login,
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
