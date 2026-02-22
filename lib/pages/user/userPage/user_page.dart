// lib/pages/user/user_page.dart

import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/user/userPage/widget/info_card_widget.dart';
import 'package:frontend_flutter/pages/user/userPage/widget/menu_grid_widget.dart';
import 'package:frontend_flutter/pages/user/userPage/widget/status_card_widget.dart';
import 'package:frontend_flutter/pages/user/userPage/widget/user_header_widget.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/user_lokasi_controller.dart';

class UserPage extends GetView<AuthController> {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil cek status setiap kali halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lokasiController = Get.find<UserLokasiController>();
      lokasiController.cekStatusHariIni();
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade300, Colors.white],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final userData = Map<String, dynamic>.from(controller.user);
            final lokasiController = Get.find<UserLokasiController>();

            return Column(
              children: [
                // Header dengan Profile dan Logout
                UserHeaderWidget(
                  user: userData,
                  lokasiController: lokasiController,
                  onLogout: () => _showLogoutDialog(),
                ),

                const SizedBox(height: 20),

                // Status Absen Hari Ini
                StatusCardWidget(controller: lokasiController),

                const SizedBox(height: 20),

                // Menu Utama
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Menu Utama',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Grid Menu
                          Expanded(
                            child: MenuGridWidget(
                              controller: lokasiController,
                              parentContext: context,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Info Card
                          const InfoCardWidget(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Konfirmasi Logout",
      middleText: "Apakah anda yakin ingin logout?",
      textCancel: "Batal",
      textConfirm: "Ya",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }
}
