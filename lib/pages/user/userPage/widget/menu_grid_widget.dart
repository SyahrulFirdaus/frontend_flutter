// lib/pages/user/widgets/menu_grid_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../riwayatAbsensiPage/riwayat_absensi_page.dart';
import '../../modals/absensi_modal.dart';

class MenuGridWidget extends StatelessWidget {
  final UserLokasiController controller;
  final BuildContext parentContext;

  const MenuGridWidget({
    super.key,
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Absen Masuk - BUNGKUS DENGAN Obx
        Obx(
          () => _buildMenuCard(
            icon: Icons.login,
            label: 'Absen Masuk',
            color: Colors.blue,
            isDisabled: controller.sudahMasuk.value,
            onTap: () {
              if (controller.sudahMasuk.value) {
                Get.snackbar(
                  'Info',
                  'Anda sudah absen masuk hari ini',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              _openAbsensiModal('masuk');
            },
          ),
        ),

        // Absen Pulang - BUNGKUS DENGAN Obx
        Obx(
          () => _buildMenuCard(
            icon: Icons.logout,
            label: 'Absen Pulang',
            color: Colors.orange,
            isDisabled:
                !controller.sudahMasuk.value || controller.sudahPulang.value,
            onTap: () {
              if (!controller.sudahMasuk.value) {
                Get.snackbar(
                  'Info',
                  'Anda harus absen masuk terlebih dahulu',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              if (controller.sudahPulang.value) {
                Get.snackbar(
                  'Info',
                  'Anda sudah absen pulang hari ini',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }

              _openAbsensiModal('pulang');
            },
          ),
        ),

        // Riwayat Absensi
        _buildMenuCard(
          icon: Icons.history,
          label: 'Riwayat Absensi',
          color: Colors.green,
          isDisabled: false,
          onTap: () {
            controller.fetchRiwayatAbsensi();
            Get.to(() => const RiwayatAbsensiPage());
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade200
                    : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDisabled ? Colors.grey.shade400 : color,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDisabled ? Colors.grey.shade500 : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            if (isDisabled) ...[
              const SizedBox(height: 4),
              Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openAbsensiModal(String tipe) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AbsensiModal(tipe: tipe),
    );
  }
}
