// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:get/get.dart';
// import '../../../controllers/auth_controller.dart';
// import '../../../controllers/user_lokasi_controller.dart';
// import 'widget/user_header_widget.dart';
// import 'widget/status_card_widget.dart';
// import 'widget/menu_grid_widget.dart';
// import 'widget/info_card_widget.dart';

// class UserPage extends StatelessWidget {
//   const UserPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();

//     if (!Get.isRegistered<UserLokasiController>()) {
//       Get.put(UserLokasiController());
//     }

//     final lokasiController = Get.find<UserLokasiController>();

//     // CEK PLATFORM
//     final bool isWeb = kIsWeb;
//     final double maxWidth = isWeb
//         ? 500
//         : double.infinity; // Batasi lebar di web

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue.shade700, Colors.blue.shade300, Colors.white],
//             stops: isWeb
//                 ? const [0.0, 0.2, 0.4]
//                 : const [0.0, 0.3, 0.7], // Sesuaikan untuk web
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Container(
//               constraints: BoxConstraints(maxWidth: maxWidth),
//               child: Obx(() {
//                 final userData = Map<String, dynamic>.from(authController.user);

//                 return Column(
//                   children: [
//                     UserHeaderWidget(
//                       user: userData,
//                       lokasiController: lokasiController,
//                       onLogout: () => _showLogoutDialog(authController),
//                     ),
//                     const SizedBox(height: 20),
//                     StatusCardWidget(controller: lokasiController),
//                     const SizedBox(height: 20),
//                     Expanded(
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(30),
//                             topRight: Radius.circular(30),
//                           ),
//                           boxShadow: isWeb
//                               ? [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.1),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, -2),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Menu Utama',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               Expanded(
//                                 child: MenuGridWidget(
//                                   controller: lokasiController,
//                                   parentContext: context,
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               const InfoCardWidget(),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(AuthController authController) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text(
//           'Konfirmasi Logout',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: const Text('Apakah Anda yakin ingin keluar?'),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               authController.logout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend_flutter/controllers/auth_controller.dart';
import 'package:frontend_flutter/controllers/user_lokasi_controller.dart';
import 'package:frontend_flutter/pages/user/riwayatAbsensiPage/riwayat_absensi_page.dart';
import 'package:get/get.dart';

import 'absen_page.dart';
import 'profil_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // PASTIKAN CONTROLLER TERDAFTAR
    if (!Get.isRegistered<UserLokasiController>()) {
      Get.put(UserLokasiController());
    }

    // INISIALISASI CONTROLLER UNTUK BOTTOM NAV
    final bottomNavController = Get.put(UserBottomNavController());

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: bottomNavController.currentIndex.value,
          children: const [AbsenPage(), RiwayatAbsensiPage(), ProfilPage()],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(bottomNavController),
      ),
    );
  }

  Widget _buildBottomNavigationBar(UserBottomNavController controller) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fingerprint),
            label: 'Absen',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class UserBottomNavController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
