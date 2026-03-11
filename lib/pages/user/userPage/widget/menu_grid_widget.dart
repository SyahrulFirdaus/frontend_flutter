import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../modals/daftar_lokasi_modal.dart';

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
    final bool isWeb = kIsWeb;

    return Column(
      children: [
        // GRID UNTUK 2 MENU (MASUK & PULANG) - LEBIH KECIL
        SizedBox(
          height: 130, // TINGGI FIX UNTUK GRID
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2, // ASPEK RATIO LEBIH LANDAI
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
                      !controller.sudahMasuk.value ||
                      controller.sudahPulang.value,
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
            ],
          ),
        ),
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
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ), // PADDING LEBIH KECIL
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(14), // RADIUS LEBIH KECIL
            border: Border.all(
              color: isDisabled ? Colors.grey[300]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon lebih kecil
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.grey[200]
                              : color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: isDisabled ? Colors.grey[400] : color,
                          size: 20, // ICON LEBIH KECIL
                        ),
                      ),
                      if (isSubmitting && !isDisabled)
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4), // JARAK LEBIH KECIL
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12, // FONT LEBIH KECIL
                      fontWeight: FontWeight.w500,
                      color: isDisabled ? Colors.grey[500] : Colors.grey[800],
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 8, // FONT BADGE LEBIH KECIL
                          color: Colors.green[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // Widget _buildInfoCard(UserLokasiController controller) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (controller.userLokasis.isNotEmpty) {
  //         DaftarLokasiModal.show(parentContext, controller);
  //       } else {
  //         Get.snackbar(
  //           'Info',
  //           'Belum ada lokasi tersedia',
  //           backgroundColor: Colors.orange,
  //           colorText: Colors.white,
  //           snackPosition: SnackPosition.TOP,
  //         );
  //       }
  //     },
  //     child: Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  //       decoration: BoxDecoration(
  //         color: Colors.blue[50],
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(color: Colors.blue[100]!),
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(6),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(Icons.location_on, color: Colors.blue[600], size: 16),
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Lokasi Tersedia',
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 2),
  //                 Obx(() {
  //                   final total = controller.userLokasis.length;
  //                   return Text(
  //                     total > 0 ? '$total Lokasi' : 'Belum ada lokasi',
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.w600,
  //                       color: total > 0 ? Colors.blue[700] : Colors.grey[600],
  //                     ),
  //                   );
  //                 }),
  //               ],
  //             ),
  //           ),
  //           Icon(Icons.chevron_right, color: Colors.blue[400], size: 18),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
