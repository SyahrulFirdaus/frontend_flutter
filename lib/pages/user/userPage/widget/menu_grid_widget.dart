import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../riwayatAbsensiPage/riwayat_absensi_page.dart';
import '../../modals/daftar_lokasi_modal.dart'; // IMPORT MODAL

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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Absen Masuk
        Obx(
          () => _buildMenuCard(
            icon: Icons.login,
            label: 'Masuk',
            color: Colors.blue,
            isDisabled: controller.sudahMasuk.value,
            badge: controller.sudahMasuk.value ? 'Selesai' : null,
            onTap: () {
              if (controller.sudahMasuk.value) {
                Get.snackbar(
                  'Info',
                  'Anda sudah absen masuk',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              controller.prosesAbsensi('masuk');
            },
          ),
        ),

        // Absen Pulang
        Obx(
          () => _buildMenuCard(
            icon: Icons.logout,
            label: 'Pulang',
            color: Colors.orange,
            isDisabled:
                !controller.sudahMasuk.value || controller.sudahPulang.value,
            badge: controller.sudahPulang.value ? 'Selesai' : null,
            onTap: () {
              if (!controller.sudahMasuk.value) {
                Get.snackbar(
                  'Info',
                  'Absen masuk dulu',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              if (controller.sudahPulang.value) {
                Get.snackbar(
                  'Info',
                  'Sudah absen pulang',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              controller.prosesAbsensi('pulang');
            },
          ),
        ),

        // Riwayat Absensi
        _buildMenuCard(
          icon: Icons.history,
          label: 'Riwayat',
          color: Colors.green,
          isDisabled: false,
          badge: null,
          onTap: () {
            controller.fetchRiwayatAbsensi();
            Get.to(() => const RiwayatAbsensiPage());
          },
        ),

        // Info Lokasi (BISA DI KLIK)
        _buildInfoCard(controller),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDisabled,
    required String? badge,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;

      return GestureDetector(
        onTap: isDisabled || isSubmitting ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDisabled ? Colors.grey[300]! : Colors.grey[200]!,
            ),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon dengan efek loading
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDisabled
                                ? Colors.grey[200]
                                : color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: isDisabled ? Colors.grey[400] : color,
                            size: 24,
                          ),
                        ),
                        if (isSubmitting && !isDisabled)
                          const Positioned.fill(
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDisabled ? Colors.grey[500] : Colors.grey[800],
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoCard(UserLokasiController controller) {
    return GestureDetector(
      onTap: () {
        // PANGGIL MODAL DAFTAR LOKASI
        DaftarLokasiModal.show(Get.context!, controller);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Lokasi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: Colors.blue[400]),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.userLokasis.isEmpty) {
                  return Text(
                    'Belum ada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.userLokasis.length} tersedia',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      if (controller.lokasiTerpilih.value == null) {
                        return const SizedBox.shrink();
                      }
                      final isInRange = controller.isInRange.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isInRange
                              ? Colors.green[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isInRange ? Icons.check_circle : Icons.warning,
                              size: 10,
                              color: isInRange
                                  ? Colors.green[600]
                                  : Colors.orange[600],
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                isInRange ? 'Dalam radius' : 'Luar radius',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isInRange
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
