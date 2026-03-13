// import 'package:flutter/material.dart';
// import 'package:frontend_flutter/controllers/user_controller.dart';
// import 'package:get/get.dart';

// class TambahUserModal {
//   static void show(BuildContext context, UserController userController) {
//     final nameC = TextEditingController();
//     final emailC = TextEditingController();
//     final passC = TextEditingController();
//     const String role = 'user';

//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.2),
//               blurRadius: 20,
//               offset: const Offset(0, -5),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHandle(),
//               const SizedBox(height: 20),
//               _buildHeader(),
//               const SizedBox(height: 24),
//               _buildFormFields(nameC, emailC, passC),
//               const SizedBox(height: 16),
//               _buildRoleInfo(),
//               const SizedBox(height: 24),
//               _buildRegisterButton(nameC, emailC, passC, userController),
//               const SizedBox(height: 12),
//               _buildCancelButton(),
//             ],
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//       enableDrag: false,
//     );
//   }

//   static Widget _buildHandle() {
//     return Center(
//       child: Container(
//         width: 50,
//         height: 5,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   static Widget _buildHeader() {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.person_add, color: Colors.blue, size: 24),
//         ),
//         const SizedBox(width: 16),
//         const Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Tambah User Baru',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Isi data dengan lengkap',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   static Widget _buildFormFields(
//     TextEditingController nameC,
//     TextEditingController emailC,
//     TextEditingController passC,
//   ) {
//     return Column(
//       children: [
//         TextField(
//           controller: nameC,
//           decoration: InputDecoration(
//             labelText: 'Nama Lengkap',
//             hintText: 'Masukkan nama lengkap',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//             prefixIcon: const Icon(Icons.person, color: Colors.blue),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//           ),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: emailC,
//           keyboardType: TextInputType.emailAddress,
//           decoration: InputDecoration(
//             labelText: 'Email',
//             hintText: 'contoh@email.com',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//             prefixIcon: const Icon(Icons.email, color: Colors.blue),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//           ),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: passC,
//           obscureText: true,
//           decoration: InputDecoration(
//             labelText: 'Password',
//             hintText: 'Minimal 6 karakter',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//             prefixIcon: const Icon(Icons.lock, color: Colors.blue),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//           ),
//         ),
//       ],
//     );
//   }

//   static Widget _buildRoleInfo() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.person, color: Colors.blue, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Role: USER',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   'User hanya dapat mengakses fitur terbatas',
//                   style: TextStyle(fontSize: 12, color: Colors.blue),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildRegisterButton(
//     TextEditingController nameC,
//     TextEditingController emailC,
//     TextEditingController passC,
//     UserController userController,
//   ) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () =>
//             _validateAndRegister(nameC, emailC, passC, userController),
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           elevation: 3,
//         ),
//         child: const Text(
//           'DAFTARKAN USER',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   static Widget _buildCancelButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: TextButton(
//         onPressed: () => Get.back(),
//         style: TextButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//         ),
//         child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
//       ),
//     );
//   }

//   static void _validateAndRegister(
//     TextEditingController nameC,
//     TextEditingController emailC,
//     TextEditingController passC,
//     UserController userController,
//   ) {
//     // Validasi
//     if (nameC.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Nama wajib diisi',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     if (emailC.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Email wajib diisi',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     if (!GetUtils.isEmail(emailC.text)) {
//       Get.snackbar(
//         'Error',
//         'Format email tidak valid',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     if (passC.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Password wajib diisi',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     if (passC.text.length < 6) {
//       Get.snackbar(
//         'Error',
//         'Password minimal 6 karakter',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     Get.back();

//     Get.dialog(
//       AlertDialog(
//         title: const Text(
//           'Konfirmasi',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: const Text('Daftarkan akun sebagai USER?'),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               userController.registerUser(
//                 name: nameC.text,
//                 email: emailC.text,
//                 password: passC.text,
//                 role: 'user',
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Ya, Daftar'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_controller.dart';

class TambahUserModal {
  static void show(BuildContext context, UserController userController) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();
    final confirmPassC = TextEditingController(); // TAMBAHKAN
    final formKey = GlobalKey<FormState>(); // TAMBAHKAN FORM KEY
    const String role = 'user';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey, // WRAP DENGAN FORM
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFormFields(nameC, emailC, passC, confirmPassC), // UPDATE
                const SizedBox(height: 16),
                _buildRoleInfo(),
                const SizedBox(height: 24),
                _buildRegisterButton(
                  nameC,
                  emailC,
                  passC,
                  confirmPassC,
                  userController,
                  formKey,
                ), // UPDATE
                const SizedBox(height: 12),
                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: false,
    );
  }

  static Widget _buildHandle() {
    return Center(
      child: Container(
        width: 50,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_add, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah User Baru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Isi data dengan lengkap',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildFormFields(
    TextEditingController nameC,
    TextEditingController emailC,
    TextEditingController passC,
    TextEditingController confirmPassC, // TAMBAHKAN
  ) {
    return Column(
      children: [
        // Nama Lengkap
        TextFormField(
          controller: nameC,
          decoration: InputDecoration(
            labelText: 'Nama Lengkap',
            hintText: 'Masukkan nama lengkap',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.person, color: Colors.blue),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama wajib diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: emailC,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'contoh@email.com',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.email, color: Colors.blue),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email wajib diisi';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password
        TextFormField(
          controller: passC,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Minimal 6 karakter',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.lock, color: Colors.blue),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password wajib diisi';
            }
            if (value.length < 6) {
              return 'Password minimal 6 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Konfirmasi Password (BARU)
        TextFormField(
          controller: confirmPassC,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Password',
            hintText: 'Ulangi password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konfirmasi password wajib diisi';
            }
            if (value != passC.text) {
              return 'Password tidak cocok';
            }
            return null;
          },
        ),
      ],
    );
  }

  static Widget _buildRoleInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.person, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role: USER',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'User hanya dapat mengakses fitur terbatas',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRegisterButton(
    TextEditingController nameC,
    TextEditingController emailC,
    TextEditingController passC,
    TextEditingController confirmPassC,
    UserController userController,
    GlobalKey<FormState> formKey,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            _validateAndRegister(nameC, emailC, passC, userController);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: const Text(
          'DAFTARKAN USER',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Get.back(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }

  static void _validateAndRegister(
    TextEditingController nameC,
    TextEditingController emailC,
    TextEditingController passC,
    UserController userController,
  ) {
    // Tutup bottom sheet
    Get.back();

    // Tampilkan dialog konfirmasi
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Konfirmasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Daftarkan akun sebagai USER?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              userController.registerUser(
                name: nameC.text,
                email: emailC.text,
                password: passC.text,
                role: 'user',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Daftar'),
          ),
        ],
      ),
    );
  }
}
