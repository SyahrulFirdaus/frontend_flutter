// lib/pages/admin/master_drawer.dart

import 'package:flutter/material.dart';
import 'package:frontend_flutter/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'list_akun.dart';
import 'lokasi_page.dart';
import 'riwayat_semua_user_page.dart'; // Import halaman baru
import '../../bindings/lokasi_binding.dart';

class MasterDrawer extends StatelessWidget {
  final String currentPage;

  const MasterDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Panel Administrator',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ===== LIST AKUN =====
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('List Akun'),
            selected: currentPage == 'admin',
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              Get.back();
              if (currentPage != 'admin') {
                Get.offAll(() => const ListAkunPage());
              }
            },
          ),

          // ===== LOKASI =====
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Lokasi'),
            selected: currentPage == 'lokasi',
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              Get.back();
              if (currentPage != 'lokasi') {
                Get.offAll(() => LokasiPage(), binding: LokasiBinding());
              }
            },
          ),

          // ===== RIWAYAT SEMUA USER =====
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Semua User'),
            selected: currentPage == 'riwayat_semua_user',
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              Get.back();
              if (currentPage != 'riwayat_semua_user') {
                Get.to(() => const RiwayatSemuaUserPage());
              }
            },
          ),

          const Divider(),

          // ===== LOGOUT =====
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Get.back();
              Get.defaultDialog(
                title: 'Konfirmasi Logout',
                middleText: 'Yakin ingin keluar?',
                textCancel: 'Batal',
                textConfirm: 'Logout',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  final auth = Get.find<AuthController>();
                  auth.logout();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
