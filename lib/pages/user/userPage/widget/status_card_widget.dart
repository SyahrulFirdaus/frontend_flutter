// lib/pages/user/widgets/status_card_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../../../utils/formatter_util.dart';

class StatusCardWidget extends StatelessWidget {
  final UserLokasiController controller;

  const StatusCardWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          // BUNGKUS ROW DENGAN Obx AGAR UPDATE OTOMATIS
          Obx(() => _buildStatusRow()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Status Absen Hari Ini',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        InkWell(
          onTap: () {
            controller.cekStatusHariIni();
            Get.snackbar(
              'Sukses',
              'Status diperbarui',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 1),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.refresh, color: Colors.blue, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusItem(
          icon: Icons.login,
          label: 'Masuk',
          status: controller.sudahMasuk.value,
          waktu: controller.dataMasuk.value != null
              ? FormatterUtil.formatWaktuSimple(
                  controller.dataMasuk.value!['waktu_absen']?.toString() ?? '',
                )
              : null,
          color: Colors.blue,
        ),
        Container(height: 30, width: 1, color: Colors.grey.shade300),
        _buildStatusItem(
          icon: Icons.logout,
          label: 'Pulang',
          status: controller.sudahPulang.value,
          waktu: controller.dataPulang.value != null
              ? FormatterUtil.formatWaktuSimple(
                  controller.dataPulang.value!['waktu_absen']?.toString() ?? '',
                )
              : null,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool status,
    String? waktu,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: status ? color.withOpacity(0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: status ? color : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: status ? color : Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (status && waktu != null) ...[
            const SizedBox(height: 2),
            Text(
              waktu,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (!status) ...[
            const SizedBox(height: 2),
            Text(
              'Belum',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
