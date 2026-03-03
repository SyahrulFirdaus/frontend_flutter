import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/user_lokasi_controller.dart';
import 'widget/user_header_widget.dart';
import 'widget/status_card_widget.dart';
import 'widget/menu_grid_widget.dart';
import 'widget/info_card_widget.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // PASTIKAN CONTROLLER TERDAFTAR
    if (!Get.isRegistered<UserLokasiController>()) {
      Get.put(UserLokasiController());
    }

    final lokasiController = Get.find<UserLokasiController>();

    return Scaffold(
      body: Obx(() {
        // TAMPILKAN ERROR JIKA ADA
        if (lokasiController.errorMessage.isNotEmpty) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade700, Colors.blue.shade300],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 64),
                    const SizedBox(height: 20),
                    Text(
                      lokasiController.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        lokasiController.fetchUserLokasi();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => authController.logout(),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // TAMPILKAN LOADING MAX 5 DETIK, LALU TAMPILKAN PESAN
        if (lokasiController.userLokasis.isEmpty) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              // Jika sudah lebih dari 5 detik dan masih loading, tampilkan opsi
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade700, Colors.blue.shade300],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_off, color: Colors.white, size: 64),
                          const SizedBox(height: 20),
                          const Text(
                            'Memuat data terlalu lama',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Periksa koneksi internet Anda',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              lokasiController.fetchUserLokasi();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Loading normal
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade700, Colors.blue.shade300],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Memuat data lokasi...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // TAMPILKAN HALAMAN UTAMA
        final userData = Map<String, dynamic>.from(authController.user);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade300,
                Colors.white,
              ],
              stops: const [0.0, 0.3, 0.7],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                UserHeaderWidget(
                  user: userData,
                  lokasiController: lokasiController,
                  onLogout: () => _showLogoutDialog(authController),
                ),
                const SizedBox(height: 20),
                StatusCardWidget(controller: lokasiController),
                const SizedBox(height: 20),
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
                          Expanded(
                            child: MenuGridWidget(
                              controller: lokasiController,
                              parentContext: context,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const InfoCardWidget(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
