// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../controllers/user_lokasi_controller.dart';
// import '../../riwayatAbsensiPage/riwayat_absensi_page.dart';

// class MenuGridWidget extends StatelessWidget {
//   final UserLokasiController controller;
//   final BuildContext parentContext;

//   const MenuGridWidget({
//     super.key,
//     required this.controller,
//     required this.parentContext,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       crossAxisCount: 2,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: 1.1,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: [
//         // Absen Masuk
//         Obx(
//           () => _buildMenuCard(
//             icon: Icons.login,
//             label: 'Absen Masuk',
//             color: Colors.blue,
//             isDisabled: controller.sudahMasuk.value,
//             onTap: () {
//               if (controller.sudahMasuk.value) {
//                 Get.snackbar(
//                   'Info',
//                   'Anda sudah absen masuk hari ini',
//                   backgroundColor: Colors.orange,
//                   colorText: Colors.white,
//                 );
//                 return;
//               }
//               // PANGGIL PROSES ABSENSI
//               controller.prosesAbsensi('masuk');
//             },
//           ),
//         ),

//         // Absen Pulang
//         Obx(
//           () => _buildMenuCard(
//             icon: Icons.logout,
//             label: 'Absen Pulang',
//             color: Colors.orange,
//             isDisabled:
//                 !controller.sudahMasuk.value || controller.sudahPulang.value,
//             onTap: () {
//               if (!controller.sudahMasuk.value) {
//                 Get.snackbar(
//                   'Info',
//                   'Anda harus absen masuk terlebih dahulu',
//                   backgroundColor: Colors.orange,
//                   colorText: Colors.white,
//                 );
//                 return;
//               }
//               if (controller.sudahPulang.value) {
//                 Get.snackbar(
//                   'Info',
//                   'Anda sudah absen pulang hari ini',
//                   backgroundColor: Colors.orange,
//                   colorText: Colors.white,
//                 );
//                 return;
//               }
//               // PANGGIL PROSES ABSENSI
//               controller.prosesAbsensi('pulang');
//             },
//           ),
//         ),

//         // Riwayat Absensi
//         _buildMenuCard(
//           icon: Icons.history,
//           label: 'Riwayat Absenssi',
//           color: Colors.green,
//           isDisabled: false,
//           onTap: () {
//             controller.fetchRiwayatAbsensi();
//             Get.to(() => const RiwayatAbsensiPage());
//           },
//         ),

//         // Info Card (menampilkan status)
//         _buildInfoCard(controller),
//       ],
//     );
//   }

//   Widget _buildMenuCard({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required bool isDisabled,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: isDisabled ? null : onTap,
//       borderRadius: BorderRadius.circular(15),
//       child: Obx(() {
//         final isSubmitting = controller.isSubmitting.value;

//         return Container(
//           decoration: BoxDecoration(
//             color: isDisabled ? Colors.grey.shade100 : Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(
//               color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade200,
//             ),
//             boxShadow: isDisabled
//                 ? []
//                 : [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 3,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//           ),
//           child: Stack(
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: isDisabled
//                           ? Colors.grey.shade200
//                           : color.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: isSubmitting && !isDisabled
//                         ? SizedBox(
//                             width: 30,
//                             height: 30,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(color),
//                             ),
//                           )
//                         : Icon(
//                             icon,
//                             color: isDisabled ? Colors.grey.shade400 : color,
//                             size: 30,
//                           ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: isDisabled
//                           ? Colors.grey.shade500
//                           : Colors.grey.shade800,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   if (isDisabled) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       'Selesai',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green.shade400,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               if (isSubmitting && !isDisabled)
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildInfoCard(UserLokasiController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
//                 const SizedBox(width: 4),
//                 Text(
//                   'Info Absensi',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Obx(() {
//               if (controller.userLokasis.isEmpty) {
//                 return const Text(
//                   'Belum ada lokasi',
//                   style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
//                 );
//               }
//               return Text(
//                 'Lokasi tersedia: ${controller.userLokasis.length}',
//                 style: const TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               );
//             }),
//             const SizedBox(height: 4),
//             Obx(() {
//               if (controller.lokasiTerpilih.value == null) {
//                 return const SizedBox.shrink();
//               }
//               return Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: controller.isInRange.value
//                       ? Colors.green.shade50
//                       : Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       controller.isInRange.value
//                           ? Icons.check_circle
//                           : Icons.info,
//                       size: 12,
//                       color: controller.isInRange.value
//                           ? Colors.green
//                           : Colors.orange,
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         'Terdekat: ${controller.lokasiTerpilih.value!['lokasi']}',
//                         style: TextStyle(
//                           fontSize: 9,
//                           color: controller.isInRange.value
//                               ? Colors.green.shade700
//                               : Colors.orange.shade700,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../riwayatAbsensiPage/riwayat_absensi_page.dart';

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

        // Info Lokasi
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
    return Container(
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
                Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
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
                        color: isInRange ? Colors.green[50] : Colors.orange[50],
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
    );
  }
}
