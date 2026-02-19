// // lib/pages/user/user_page.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../controllers/user_lokasi_controller.dart';

// class UserPage extends GetView<AuthController> {
//   const UserPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = controller.user;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Page'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               Get.defaultDialog(
//                 title: "Konfirmasi Logout",
//                 middleText: "Apakah anda mau logout ?",
//                 textCancel: "Batal",
//                 textConfirm: "Yes",
//                 confirmTextColor: Colors.white,
//                 onConfirm: () {
//                   controller.logout();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Selamat datang, ${user['name']}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.fingerprint, size: 26),
//                   label: const Text(
//                     'Absen Kehadiran',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(20),
//                         ),
//                       ),
//                       builder: (_) => const AbsensiModal(),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /* ============================
//    MODAL ABSENSI (DROPDOWN)
// ============================ */
// class AbsensiModal extends StatefulWidget {
//   const AbsensiModal({super.key});

//   @override
//   State<AbsensiModal> createState() => _AbsensiModalState();
// }

// class _AbsensiModalState extends State<AbsensiModal> {
//   String? selectedLokasiId;
//   String? selectedLokasiNama;

//   late final UserLokasiController lokasiController;

//   @override
//   void initState() {
//     super.initState();

//     // Cek apakah controller sudah terdaftar
//     if (Get.isRegistered<UserLokasiController>()) {
//       lokasiController = Get.find<UserLokasiController>();
//       print('✅ UserLokasiController sudah terdaftar');
//     } else {
//       // Jika belum, put manual
//       lokasiController = Get.put(UserLokasiController());
//       print('🆕 UserLokasiController dibuat manual');
//     }

//     // Panggil fetch data setelah modal dibuka
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       lokasiController.fetchUserLokasi();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.6, // Kurangi height
//       padding: EdgeInsets.only(
//         left: 16,
//         right: 16,
//         top: 16,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // indikator drag
//           Center(
//             child: Container(
//               width: 40,
//               height: 5,
//               margin: const EdgeInsets.only(bottom: 20),
//               decoration: BoxDecoration(
//                 color: Colors.grey[400],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),

//           const Text(
//             'Absen Kehadiran',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 20),

//           const Text(
//             'Lokasi Absensi',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 8),

//           // Dropdown lokasi
//           Obx(() {
//             if (lokasiController.isLoading.value) {
//               return const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }

//             if (lokasiController.errorMessage.isNotEmpty) {
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(Icons.error, color: Colors.red.shade700, size: 32),
//                     const SizedBox(height: 8),
//                     Text(
//                       lokasiController.errorMessage.value,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         lokasiController.fetchUserLokasi();
//                       },
//                       child: const Text('Coba Lagi'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             if (lokasiController.userLokasis.isEmpty) {
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(Icons.info, color: Colors.orange.shade700, size: 32),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Belum ada lokasi absensi',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.orange),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Silahkan hubungi admin',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 12),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//               ),
//               hint: const Text('Pilih lokasi'),
//               value: selectedLokasiId,
//               items: lokasiController.userLokasis.map((lokasi) {
//                 return DropdownMenuItem<String>(
//                   value: lokasi['id'].toString(),
//                   child: Text(lokasi['lokasi']),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   final selected = lokasiController.userLokasis.firstWhere(
//                     (l) => l['id'].toString() == value,
//                   );
//                   setState(() {
//                     selectedLokasiId = value;
//                     selectedLokasiNama = selected['lokasi'];
//                   });
//                 }
//               },
//             );
//           }),

//           const SizedBox(height: 20),

//           if (selectedLokasiNama != null)
//             Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.blue.shade700),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Absen di: $selectedLokasiNama',
//                       style: TextStyle(color: Colors.blue.shade700),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: Obx(() {
//               final isLoading = lokasiController.isLoading.value;
//               return ElevatedButton(
//                 onPressed: (selectedLokasiId != null && !isLoading)
//                     ? () async {
//                         // Tampilkan loading
//                         Get.dialog(
//                           const Center(child: CircularProgressIndicator()),
//                           barrierDismissible: false,
//                         );

//                         // Submit absensi
//                         final success = await lokasiController.submitAbsensi(
//                           selectedLokasiId!,
//                           selectedLokasiNama!,
//                         );

//                         // Tutup loading
//                         Get.back();

//                         if (success) {
//                           Get.back(); // Tutup modal
//                           Get.snackbar(
//                             'Berhasil',
//                             'Absen berhasil',
//                             backgroundColor: Colors.green,
//                             colorText: Colors.white,
//                             snackPosition: SnackPosition.BOTTOM,
//                           );
//                         } else {
//                           Get.snackbar(
//                             'Gagal',
//                             'Gagal absen',
//                             backgroundColor: Colors.red,
//                             colorText: Colors.white,
//                             snackPosition: SnackPosition.BOTTOM,
//                           );
//                         }
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text(isLoading ? 'Memuat...' : 'Konfirmasi Absen'),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
// lib/pages/user/user_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_lokasi_controller.dart';

class UserPage extends GetView<AuthController> {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: "Konfirmasi Logout",
                middleText: "Apakah anda mau logout?",
                textCancel: "Batal",
                textConfirm: "Ya",
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            user['name']?[0].toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selamat datang,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          user['name'] ?? 'User',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user['email'] ?? '',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Absen Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.fingerprint, size: 28),
                    label: const Text(
                      'Absen Kehadiran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Inisialisasi controller jika belum ada
                      if (!Get.isRegistered<UserLokasiController>()) {
                        Get.put(UserLokasiController());
                      }

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const AbsensiModal(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Info Card
                Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Silahkan absen dengan memilih lokasi yang telah ditentukan oleh admin',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================
   MODAL ABSENSI (DROPDOWN + MAP)
============================ */
class AbsensiModal extends StatefulWidget {
  const AbsensiModal({super.key});

  @override
  State<AbsensiModal> createState() => _AbsensiModalState();
}

class _AbsensiModalState extends State<AbsensiModal> {
  String? selectedLokasiId;
  String? selectedLokasiNama;
  String? selectedLokasiKoordinat;

  late final UserLokasiController lokasiController;

  // Untuk map preview
  GoogleMapController? mapController;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();

    lokasiController = Get.find<UserLokasiController>();

    // Panggil fetch data setelah modal dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lokasiController.fetchUserLokasi();
    });
  }

  // Ganti fungsi _onLokasiSelected menjadi:

  void _onLokasiSelected(String? value) {
    // Tambahkan tanda ? (nullable)
    if (value != null) {
      // Tambahkan pengecekan null
      final selected = lokasiController.userLokasis.firstWhere(
        (l) => l['id'].toString() == value,
      );

      setState(() {
        selectedLokasiId = value;
        selectedLokasiNama = selected['lokasi'];
        selectedLokasiKoordinat = selected['koordinat'];

        // Parse koordinat untuk map
        if (selectedLokasiKoordinat != null) {
          try {
            final parts = selectedLokasiKoordinat!.split(',');
            if (parts.length == 2) {
              final lat = double.tryParse(parts[0].trim());
              final lng = double.tryParse(parts[1].trim());
              if (lat != null && lng != null) {
                selectedLocation = LatLng(lat, lng);
                if (mapController != null) {
                  mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(selectedLocation!, 16),
                  );
                }
              }
            }
          } catch (e) {
            print('Error parsing koordinat: $e');
            selectedLocation = null;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle drag indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Absen Kehadiran',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                if (lokasiController.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat data lokasi...'),
                      ],
                    ),
                  );
                }

                if (lokasiController.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          lokasiController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            lokasiController.fetchUserLokasi();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (lokasiController.userLokasis.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada lokasi absensi',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hubungi admin untuk menambahkan lokasi',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      const Text(
                        'Pilih Lokasi Absensi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dropdown
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          hint: const Text('-- Pilih Lokasi --'),
                          value: selectedLokasiId,
                          items: lokasiController.userLokasis.map((lokasi) {
                            return DropdownMenuItem<String>(
                              value: lokasi['id'].toString(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lokasi['lokasi'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '📍 ${lokasi['koordinat']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _onLokasiSelected,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Map Preview
                      if (selectedLocation != null) ...[
                        const Text(
                          'Preview Lokasi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: selectedLocation!,
                                    zoom: 16,
                                  ),
                                  onMapCreated: (controller) {
                                    mapController = controller;
                                  },
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId(
                                        'selected_location',
                                      ),
                                      position: selectedLocation!,
                                      infoWindow: InfoWindow(
                                        title: selectedLokasiNama,
                                        snippet: selectedLokasiKoordinat,
                                      ),
                                    ),
                                  },
                                  zoomControlsEnabled: true,
                                  myLocationButtonEnabled: false,
                                  compassEnabled: true,
                                  mapToolbarEnabled: false,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Lokasi dipilih',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedLokasiNama ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedLokasiKoordinat ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Tombol Konfirmasi
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(() {
                          final isLoading = lokasiController.isLoading.value;
                          return ElevatedButton(
                            onPressed: (selectedLokasiId != null && !isLoading)
                                ? () async {
                                    // Tampilkan loading dialog
                                    Get.dialog(
                                      const Center(
                                        child: Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(height: 16),
                                                Text('Memproses absensi...'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      barrierDismissible: false,
                                    );

                                    // Submit absensi
                                    final success = await lokasiController
                                        .submitAbsensi(
                                          selectedLokasiId!,
                                          selectedLokasiNama!,
                                        );

                                    // Tutup loading dialog
                                    Get.back();

                                    if (success) {
                                      Get.back(); // Tutup modal

                                      // Tampilkan success dialog
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 60,
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Absensi Berhasil!',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Anda telah absen di:',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                selectedLokasiNama!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                selectedLokasiKoordinat!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      Get.snackbar(
                                        'Gagal',
                                        'Gagal melakukan absensi, silahkan coba lagi',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                        duration: const Duration(seconds: 3),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              isLoading
                                  ? 'Memuat...'
                                  : (selectedLokasiId != null
                                        ? 'KONFIRMASI ABSEN'
                                        : 'PILIH LOKASI TERLEBIH DAHULU'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
