// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final AuthController authController = Get.find();

//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   String selectedRole = 'user';

//   var nameKosong = false.obs;
//   var emailKosong = false.obs;
//   var passwordKosong = false.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Obx(
//         () => authController.isLoading.value
//             ? const Center(child: CircularProgressIndicator())
//             : Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: ListView(
//                   children: [
//                     // 🔹 TEKS TAMBAHAN
//                     const Text(
//                       'Silahkan Register',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 30),

//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         labelText: 'Name',
//                         border: const OutlineInputBorder(),
//                         errorText: nameKosong.value
//                             ? 'Nama tidak boleh kosong'
//                             : null,
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     TextField(
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         border: const OutlineInputBorder(),
//                         errorText: emailKosong.value
//                             ? 'Email tidak boleh kosong'
//                             : null,
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     TextField(
//                       controller: passwordController,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         border: const OutlineInputBorder(),
//                         errorText: passwordKosong.value
//                             ? 'Password tidak boleh kosong'
//                             : null,
//                       ),
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 20),

//                     DropdownButtonFormField<String>(
//                       value: selectedRole,
//                       decoration: const InputDecoration(
//                         labelText: 'Role',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: const [
//                         DropdownMenuItem(value: 'admin', child: Text('Admin')),
//                         DropdownMenuItem(value: 'user', child: Text('User')),
//                       ],
//                       onChanged: (val) {
//                         setState(() {
//                           selectedRole = val!;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     ElevatedButton(
//                       onPressed: () {
//                         final name = nameController.text.trim();
//                         final email = emailController.text.trim();
//                         final password = passwordController.text.trim();

//                         nameKosong.value = name.isEmpty;
//                         emailKosong.value = email.isEmpty;
//                         passwordKosong.value = password.isEmpty;

//                         if (name.isEmpty || email.isEmpty || password.isEmpty) {
//                           Get.snackbar(
//                             'Error',
//                             'Anda belum input data',
//                             backgroundColor: Colors.red,
//                             colorText: Colors.white,
//                           );
//                           return;
//                         }

//                         authController.register(
//                           name,
//                           email,
//                           password,
//                           selectedRole,
//                         );
//                       },
//                       child: const Text('Register'),
//                     ),

//                     TextButton(
//                       onPressed: () => Get.back(),
//                       child: const Text('Back to Login'),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

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

  var nameKosong = false.obs;
  var emailKosong = false.obs;
  var passwordKosong = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Admin')),
      body: Obx(
        () => authController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    const Text(
                      'Register Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: const OutlineInputBorder(),
                        errorText: nameKosong.value ? 'Nama wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        errorText: emailKosong.value
                            ? 'Email wajib diisi'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        errorText: passwordKosong.value
                            ? 'Password wajib diisi'
                            : null,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        nameKosong.value = name.isEmpty;
                        emailKosong.value = email.isEmpty;
                        passwordKosong.value = password.isEmpty;

                        if (name.isEmpty || email.isEmpty || password.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Lengkapi semua field',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        authController.register(
                          name,
                          email,
                          password,
                          'admin', // 🔥 ROLE FIX ADMIN
                        );
                      },
                      child: const Text('Register Admin'),
                    ),

                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
