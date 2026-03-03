import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../riwayatAbsensiPage/riwayat_absensi_page.dart';

class HorizontalMenuWidget extends StatelessWidget {
  final UserLokasiController controller;
  final BuildContext parentContext;

  const HorizontalMenuWidget({
    super.key,
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        // ABSEN MASUK
        Obx(
          () => _buildMenuItem(
            icon: Icons.login,
            label: 'Absen Masuk',
            color: Colors.blue,
            isDisabled: controller.sudahMasuk.value,
            isSubmitting: controller.isSubmitting.value,
            onTap: () {
              if (controller.sudahMasuk.value) {
                Get.snackbar(
                  'Info',
                  'Anda sudah absen masuk hari ini',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              controller.prosesAbsensi('masuk');
            },
          ),
        ),

        const SizedBox(width: 12),

        // ABSEN PULANG
        Obx(
          () => _buildMenuItem(
            icon: Icons.logout,
            label: 'Absen Pulang',
            color: Colors.orange,
            isDisabled:
                !controller.sudahMasuk.value || controller.sudahPulang.value,
            isSubmitting: controller.isSubmitting.value,
            onTap: () {
              if (!controller.sudahMasuk.value) {
                Get.snackbar(
                  'Info',
                  'Anda harus absen masuk terlebih dahulu',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              if (controller.sudahPulang.value) {
                Get.snackbar(
                  'Info',
                  'Anda sudah absen pulang hari ini',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              controller.prosesAbsensi('pulang');
            },
          ),
        ),

        const SizedBox(width: 12),

        // RIWAYAT ABSENSI
        _buildMenuItem(
          icon: Icons.history,
          label: 'Riwayat',
          color: Colors.green,
          isDisabled: false,
          isSubmitting: false,
          onTap: () {
            controller.fetchRiwayatAbsensi();
            Get.to(() => const RiwayatAbsensiPage());
          },
        ),

        const SizedBox(width: 12),

        // INFO LOKASI (MENAMPILKAN JUMLAH LOKASI)
        _buildInfoMenuItem(controller),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDisabled,
    required bool isSubmitting,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDisabled ? Colors.grey[300]! : Colors.grey[200]!,
        ),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? Colors.grey[200]
                            : color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: isSubmitting && !isDisabled
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                              ),
                            )
                          : Icon(
                              icon,
                              color: isDisabled ? Colors.grey[400] : color,
                              size: 24,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDisabled ? Colors.grey[500] : Colors.grey[800],
                      ),
                    ),
                    if (isDisabled) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSubmitting && !isDisabled)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoMenuItem(UserLokasiController controller) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, color: Colors.blue[700], size: 20),
            ),
            const SizedBox(height: 4),
            Obx(() {
              final totalLokasi = controller.userLokasis.length;
              return Text(
                '$totalLokasi Lokasi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              );
            }),
            const SizedBox(height: 2),
            Obx(() {
              if (controller.lokasiTerpilih.value == null) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: controller.isInRange.value
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  controller.isInRange.value
                      ? '✓ Dalam radius'
                      : '✗ Luar radius',
                  style: TextStyle(
                    fontSize: 8,
                    color: controller.isInRange.value
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
