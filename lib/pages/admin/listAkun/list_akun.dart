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
