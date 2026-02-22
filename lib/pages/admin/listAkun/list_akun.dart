// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controllers/auth_controller.dart';
// import '../../../controllers/user_controller.dart';
// import '../master_drawer.dart';

// class ListAkunPage extends GetView<AuthController> {
//   const ListAkunPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final UserController userController = Get.find<UserController>();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       userController.fetchUsers();
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'List Akun',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               Get.defaultDialog(
//                 title: 'Konfirmasi Logout',
//                 middleText: 'Yakin ingin logout?',
//                 textCancel: 'Batal',
//                 textConfirm: 'Logout',
//                 confirmTextColor: Colors.white,
//                 buttonColor: Colors.red,
//                 onConfirm: () {
//                   Get.back();
//                   controller.logout();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: const MasterDrawer(currentPage: 'admin'),
//       body: Obx(() {
//         if (userController.isLoading.value) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text('Memuat data...'),
//               ],
//             ),
//           );
//         }

//         // Hitung jumlah admin dan user
//         final int totalUsers = userController.users.length;
//         final int totalAdmins = userController.users
//             .where((u) => u.role == 'admin')
//             .length;
//         final int totalRegularUsers = userController.users
//             .where((u) => u.role == 'user')
//             .length;

//         return Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.blue.shade50, Colors.white],
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 // Header dengan ikon dan info (TETAP)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.1),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue.shade50,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.people,
//                                 color: Colors.blue,
//                                 size: 30,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Manajemen User',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Total: $totalUsers akun terdaftar',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.purple.shade50,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.admin_panel_settings,
//                                     size: 14,
//                                     color: Colors.purple.shade700,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     'Admin',
//                                     style: TextStyle(
//                                       color: Colors.purple.shade700,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         // Statistik Admin dan User
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.purple.shade50,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: Colors.purple.shade200,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Icon(
//                                       Icons.admin_panel_settings,
//                                       color: Colors.purple.shade700,
//                                       size: 24,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       '$totalAdmins',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.purple.shade700,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Admin',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.purple.shade700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade50,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: Colors.blue.shade200,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Icon(
//                                       Icons.person,
//                                       color: Colors.blue.shade700,
//                                       size: 24,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       '$totalRegularUsers',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.blue.shade700,
//                                       ),
//                                     ),
//                                     Text(
//                                       'User',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.blue.shade700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Tabel Data User (BISA DI SCROLL VERTIKAL)
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.1),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: userController.users.isEmpty
//                           ? Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.people_outline,
//                                     size: 64,
//                                     color: Colors.grey.shade400,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     'Data user kosong',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Tambahkan user baru dengan tombol di bawah',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey.shade500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.vertical,
//                                 child: DataTable(
//                                   headingRowColor: MaterialStateProperty.all(
//                                     Colors.blue.shade50,
//                                   ),
//                                   headingTextStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue.shade700,
//                                   ),
//                                   columnSpacing: 20,
//                                   horizontalMargin: 16,
//                                   columns: const [
//                                     DataColumn(label: Text('No')),
//                                     DataColumn(label: Text('Nama')),
//                                     DataColumn(label: Text('Email')),
//                                     DataColumn(label: Text('Role')),
//                                     DataColumn(label: Text('Aksi')),
//                                   ],
//                                   rows: List.generate(userController.users.length, (
//                                     index,
//                                   ) {
//                                     final user = userController.users[index];
//                                     return DataRow(
//                                       cells: [
//                                         DataCell(
//                                           Container(
//                                             width: 24,
//                                             height: 24,
//                                             decoration: BoxDecoration(
//                                               color: Colors.blue.shade100,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 '${index + 1}',
//                                                 style: TextStyle(
//                                                   color: Colors.blue.shade700,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Text(
//                                             user.name,
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(Text(user.email)),
//                                         DataCell(
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 8,
//                                               vertical: 4,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: user.role == 'admin'
//                                                   ? Colors.purple.shade50
//                                                   : Colors.blue.shade50,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Icon(
//                                                   user.role == 'admin'
//                                                       ? Icons
//                                                             .admin_panel_settings
//                                                       : Icons.person,
//                                                   size: 12,
//                                                   color: user.role == 'admin'
//                                                       ? Colors.purple
//                                                       : Colors.blue,
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   user.role,
//                                                   style: TextStyle(
//                                                     color: user.role == 'admin'
//                                                         ? Colors.purple
//                                                         : Colors.blue,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           IconButton(
//                                             icon: Container(
//                                               padding: const EdgeInsets.all(4),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.red.shade50,
//                                                 shape: BoxShape.circle,
//                                               ),
//                                               child: const Icon(
//                                                 Icons.delete,
//                                                 color: Colors.red,
//                                                 size: 18,
//                                               ),
//                                             ),
//                                             onPressed: () {
//                                               Get.dialog(
//                                                 AlertDialog(
//                                                   title: const Text(
//                                                     'Hapus User',
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   content: Text(
//                                                     'Yakin ingin menghapus user "${user.name}"?',
//                                                   ),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           20,
//                                                         ),
//                                                   ),
//                                                   actions: [
//                                                     TextButton(
//                                                       onPressed: () =>
//                                                           Get.back(),
//                                                       child: const Text(
//                                                         'Batal',
//                                                       ),
//                                                     ),
//                                                     ElevatedButton(
//                                                       onPressed: () async {
//                                                         Get.back();
//                                                         await userController
//                                                             .deleteUser(
//                                                               user.id,
//                                                             );
//                                                       },
//                                                       style: ElevatedButton.styleFrom(
//                                                         backgroundColor:
//                                                             Colors.red,
//                                                         foregroundColor:
//                                                             Colors.white,
//                                                         shape: RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius.circular(
//                                                                 8,
//                                                               ),
//                                                         ),
//                                                       ),
//                                                       child: const Text(
//                                                         'Hapus',
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   }),
//                                 ),
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),

//                 // Tombol Aksi dan Info Card (TETAP)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton.icon(
//                               onPressed: userController.fetchUsers,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Refresh'),
//                               style: OutlinedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 14,
//                                 ),
//                                 backgroundColor: Colors.white,
//                                 foregroundColor: Colors.blue,
//                                 side: BorderSide(color: Colors.blue.shade200),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () =>
//                                   _showAddUserModal(userController),
//                               icon: const Icon(Icons.person_add),
//                               label: const Text('Tambah User'),
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 14,
//                                 ),
//                                 backgroundColor: Colors.blue,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 elevation: 3,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 10),

//                       // Info Card
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade50,
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: Colors.blue.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               size: 18,
//                               color: Colors.blue.shade700,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'Anda login sebagai admin. Dapat mengelola semua user.',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.blue.shade700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   // ================= MODAL TAMBAH USER =================
//   void _showAddUserModal(UserController userController) {
//     final nameC = TextEditingController();
//     final emailC = TextEditingController();
//     final passC = TextEditingController();
//     // Role sudah fixed sebagai 'user'
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
//               // Handle
//               Center(
//                 child: Container(
//                   width: 50,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Header dengan ikon
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.person_add,
//                       color: Colors.blue,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Tambah User Baru',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Isi data dengan lengkap',
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Form Fields
//               TextField(
//                 controller: nameC,
//                 decoration: InputDecoration(
//                   labelText: 'Nama Lengkap',
//                   hintText: 'Masukkan nama lengkap',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   prefixIcon: const Icon(Icons.person, color: Colors.blue),
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               TextField(
//                 controller: emailC,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   hintText: 'contoh@email.com',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   prefixIcon: const Icon(Icons.email, color: Colors.blue),
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               TextField(
//                 controller: passC,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Minimal 6 karakter',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   prefixIcon: const Icon(Icons.lock, color: Colors.blue),
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Informasi Role
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.person, color: Colors.blue, size: 20),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Role: USER',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                           Text(
//                             'User hanya dapat mengakses fitur terbatas',
//                             style: TextStyle(fontSize: 12, color: Colors.blue),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Tombol Register
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Validasi
//                     if (nameC.text.isEmpty) {
//                       Get.snackbar(
//                         'Error',
//                         'Nama wajib diisi',
//                         backgroundColor: Colors.red,
//                         colorText: Colors.white,
//                         snackPosition: SnackPosition.BOTTOM,
//                       );
//                       return;
//                     }
//                     if (emailC.text.isEmpty) {
//                       Get.snackbar(
//                         'Error',
//                         'Email wajib diisi',
//                         backgroundColor: Colors.red,
//                         colorText: Colors.white,
//                         snackPosition: SnackPosition.BOTTOM,
//                       );
//                       return;
//                     }
//                     if (!GetUtils.isEmail(emailC.text)) {
//                       Get.snackbar(
//                         'Error',
//                         'Format email tidak valid',
//                         backgroundColor: Colors.red,
//                         colorText: Colors.white,
//                         snackPosition: SnackPosition.BOTTOM,
//                       );
//                       return;
//                     }
//                     if (passC.text.isEmpty) {
//                       Get.snackbar(
//                         'Error',
//                         'Password wajib diisi',
//                         backgroundColor: Colors.red,
//                         colorText: Colors.white,
//                         snackPosition: SnackPosition.BOTTOM,
//                       );
//                       return;
//                     }
//                     if (passC.text.length < 6) {
//                       Get.snackbar(
//                         'Error',
//                         'Password minimal 6 karakter',
//                         backgroundColor: Colors.red,
//                         colorText: Colors.white,
//                         snackPosition: SnackPosition.BOTTOM,
//                       );
//                       return;
//                     }

//                     // Tutup bottom sheet
//                     Get.back();

//                     // Tampilkan dialog konfirmasi
//                     Get.dialog(
//                       AlertDialog(
//                         title: const Text(
//                           'Konfirmasi',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         content: const Text('Daftarkan akun sebagai USER?'),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Get.back(),
//                             child: const Text('Batal'),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               Get.back();
//                               userController.registerUser(
//                                 name: nameC.text,
//                                 email: emailC.text,
//                                 password: passC.text,
//                                 role: role,
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text('Ya, Daftar'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     elevation: 3,
//                   ),
//                   child: const Text(
//                     'DAFTARKAN USER',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Tombol Batal
//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed: () => Get.back(),
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: Text(
//                     'Batal',
//                     style: TextStyle(color: Colors.grey.shade600),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//       enableDrag: false,
//     );
//   }
// }
// lib/pages/admin/list_akun_page.dart

import 'package:flutter/material.dart';
import 'package:frontend_flutter/controllers/auth_controller.dart';
import 'package:frontend_flutter/controllers/user_controller.dart';
import 'package:frontend_flutter/pages/admin/listAkun/widget/akun_action_buttons.dart';
import 'package:frontend_flutter/pages/admin/listAkun/widget/akun_header_widget.dart';
import 'package:frontend_flutter/pages/admin/listAkun/widget/akun_info_card.dart';
import 'package:frontend_flutter/pages/admin/listAkun/widget/akun_table_widget.dart';
import 'package:frontend_flutter/pages/admin/master_drawer.dart';
import 'package:get/get.dart';

class ListAkunPage extends GetView<AuthController> {
  const ListAkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.fetchUsers();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'Konfirmasi Logout',
                middleText: 'Yakin ingin logout?',
                textCancel: 'Batal',
                textConfirm: 'Logout',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
          ),
        ],
      ),
      drawer: const MasterDrawer(currentPage: 'admin'),
      body: Obx(() {
        if (userController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat data...'),
              ],
            ),
          );
        }

        // Hitung jumlah admin dan user
        final int totalUsers = userController.users.length;
        final int totalAdmins = userController.users
            .where((u) => u.role == 'admin')
            .length;
        final int totalRegularUsers = userController.users
            .where((u) => u.role == 'user')
            .length;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header dengan statistik
                AkunHeaderWidget(
                  totalUsers: totalUsers,
                  totalAdmins: totalAdmins,
                  totalRegularUsers: totalRegularUsers,
                ),

                // Tabel Data User
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: AkunTableWidget(userController: userController),
                  ),
                ),

                // Tombol Aksi dan Info Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AkunActionButtons(userController: userController),
                      const SizedBox(height: 10),
                      const AkunInfoCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
