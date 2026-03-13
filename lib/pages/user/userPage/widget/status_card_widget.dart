import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../../../utils/formatter_util.dart';

class StatusCardWidget extends StatelessWidget {
  final UserLokasiController controller;

  const StatusCardWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Hari Ini',
                style: TextStyle(
                  fontSize: isWeb ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.refresh, color: Colors.grey[600], size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.login,
                    label: 'Masuk',
                    status: controller.sudahMasuk.value,
                    waktu: controller.dataMasuk.value != null
                        ? FormatterUtil.formatWaktuSimple(
                            controller.dataMasuk.value!['waktu_absen']
                                    ?.toString() ??
                                '',
                          )
                        : null,
                    color: Colors.blue,
                    isWeb: isWeb,
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.logout,
                    label: 'Pulang',
                    status: controller.sudahPulang.value,
                    waktu: controller.dataPulang.value != null
                        ? FormatterUtil.formatWaktuSimple(
                            controller.dataPulang.value!['waktu_absen']
                                    ?.toString() ??
                                '',
                          )
                        : null,
                    color: Colors.orange,
                    isWeb: isWeb,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool status,
    String? waktu,
    required Color color,
    required bool isWeb,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: status ? color.withValues(alpha: 0.1) : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: status ? color : Colors.grey[400],
            size: isWeb ? 28 : 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isWeb ? 14 : 12,
            color: status ? color : Colors.grey[500],
            fontWeight: status ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        if (status && waktu != null) ...[
          const SizedBox(height: 2),
          Text(
            waktu,
            style: TextStyle(
              fontSize: isWeb ? 13 : 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else ...[
          const SizedBox(height: 2),
          Text(
            '--:--',
            style: TextStyle(
              fontSize: isWeb ? 13 : 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ],
    );
  }
}
