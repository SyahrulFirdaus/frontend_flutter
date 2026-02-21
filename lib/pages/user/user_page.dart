// lib/pages/user/user_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_lokasi_controller.dart';
import 'riwayat_absensi_page.dart';

class UserPage extends GetView<AuthController> {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade300, Colors.white],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            // Ambil data user dari controller
            final Map<String, dynamic> userData = Map<String, dynamic>.from(
              controller.user,
            );
            final lokasiController = Get.find<UserLokasiController>();

            return Column(
              children: [
                // Header dengan Profile dan Logout
                _buildHeader(userData, lokasiController),

                const SizedBox(height: 20),

                // Status Absen Hari Ini
                _buildStatusCard(lokasiController),

                const SizedBox(height: 20),

                // Menu Utama
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Menu Utama',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Grid Menu - 3 MENU (Absen Masuk, Absen Pulang, Riwayat)
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                              children: [
                                // Absen Masuk
                                _buildMenuCard(
                                  icon: Icons.login,
                                  label: 'Absen Masuk',
                                  color: Colors.blue,
                                  isDisabled: lokasiController.sudahMasuk.value,
                                  onTap: () {
                                    if (lokasiController.sudahMasuk.value) {
                                      Get.snackbar(
                                        'Info',
                                        'Anda sudah absen masuk hari ini',
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                      return;
                                    }

                                    _openAbsensiModal(context, 'masuk');
                                  },
                                ),

                                // Absen Pulang
                                _buildMenuCard(
                                  icon: Icons.logout,
                                  label: 'Absen Pulang',
                                  color: Colors.orange,
                                  isDisabled:
                                      !lokasiController.sudahMasuk.value ||
                                      lokasiController.sudahPulang.value,
                                  onTap: () {
                                    if (!lokasiController.sudahMasuk.value) {
                                      Get.snackbar(
                                        'Info',
                                        'Anda harus absen masuk terlebih dahulu',
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                      return;
                                    }

                                    if (lokasiController.sudahPulang.value) {
                                      Get.snackbar(
                                        'Info',
                                        'Anda sudah absen pulang hari ini',
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                      return;
                                    }

                                    _openAbsensiModal(context, 'pulang');
                                  },
                                ),

                                // Riwayat Absensi
                                _buildMenuCard(
                                  icon: Icons.history,
                                  label: 'Riwayat Absensi',
                                  color: Colors.green,
                                  isDisabled: false,
                                  onTap: () {
                                    final lokasiController =
                                        Get.find<UserLokasiController>();
                                    lokasiController.fetchRiwayatAbsensi();
                                    Get.to(() => const RiwayatAbsensiPage());
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Info Card
                          _buildInfoCard(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Fungsi untuk membuka modal absensi
  void _openAbsensiModal(BuildContext context, String tipe) {
    // Inisialisasi controller jika belum ada
    if (!Get.isRegistered<UserLokasiController>()) {
      Get.put(UserLokasiController());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AbsensiModal(tipe: tipe),
    );
  }

  Widget _buildHeader(
    Map<String, dynamic> user,
    UserLokasiController lokasiController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Inisial (tanpa logo/gambar)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue.shade100],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (user['name'] != null && user['name'].toString().isNotEmpty)
                    ? user['name'].toString()[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  user['name']?.toString() ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    user['email']?.toString() ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                lokasiController.cekStatusHariIni();
                lokasiController.fetchUserLokasi();
                Get.snackbar(
                  'Sukses',
                  'Data berhasil di-refresh',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 1),
                );
              },
              tooltip: 'Refresh Data',
            ),
          ),

          // Logout Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Get.defaultDialog(
                  title: "Konfirmasi Logout",
                  middleText: "Apakah anda yakin ingin logout?",
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(UserLokasiController controller) {
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
          Row(
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
              // Tombol refresh kecil di status card
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
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem(
                icon: Icons.login,
                label: 'Masuk',
                status: controller.sudahMasuk.value,
                waktu: controller.dataMasuk.value != null
                    ? _formatWaktuSimple(
                        controller.dataMasuk.value!['waktu_absen']
                                ?.toString() ??
                            '',
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
                    ? _formatWaktuSimple(
                        controller.dataPulang.value!['waktu_absen']
                                ?.toString() ??
                            '',
                      )
                    : null,
                color: Colors.orange,
              ),
            ],
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

  String _formatWaktuSimple(String waktuStr) {
    try {
      if (waktuStr.contains('T')) {
        final parts = waktuStr.split('T');
        String jam = parts[1];
        jam = jam.replaceAll(RegExp(r'\..*$'), '');
        jam = jam.replaceAll(RegExp(r'Z$'), '');
        if (jam.contains(':')) {
          final jamParts = jam.split(':');
          if (jamParts.length >= 2) {
            return '${jamParts[0]}:${jamParts[1]}';
          }
        }
        return jam;
      }
      if (waktuStr.contains(' ')) {
        final parts = waktuStr.split(' ');
        if (parts.length >= 2) {
          String jam = parts[1];
          if (jam.contains(':')) {
            final jamParts = jam.split(':');
            if (jamParts.length >= 2) {
              return '${jamParts[0]}:${jamParts[1]}';
            }
          }
          return jam;
        }
      }
      return waktuStr;
    } catch (e) {
      return '-';
    }
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

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.blue.shade700,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Absen masuk dan pulang dengan memilih lokasi yang telah ditentukan. Pastikan GPS aktif dan Anda berada dalam radius 100 meter dari lokasi absensi. Foto wajah akan diambil sebagai bukti.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================
   MODAL ABSENSI (DROPDOWN + MAP) 
============================ */
class AbsensiModal extends StatefulWidget {
  final String tipe; // 'masuk' atau 'pulang'

  const AbsensiModal({super.key, this.tipe = 'masuk'});

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

    // Reset loading state saat modal dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lokasiController.isLoading.value = false;
      lokasiController.fetchUserLokasi();
    });
  }

  void _onLokasiSelected(String? value) {
    if (value != null) {
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
              } else {
                selectedLocation = null;
              }
            } else {
              selectedLocation = null;
            }
          } catch (e) {
            print('Error parsing koordinat: $e');
            selectedLocation = null;
          }
        }
      });
    }
  }

  String _getModalTitle() {
    return widget.tipe == 'masuk' ? 'Absen Masuk' : 'Absen Pulang';
  }

  String _getButtonText() {
    return widget.tipe == 'masuk' ? 'KONFIRMASI MASUK' : 'KONFIRMASI PULANG';
  }

  Color _getButtonColor() {
    return widget.tipe == 'masuk' ? Colors.blue : Colors.orange;
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
        mainAxisSize: MainAxisSize.min,
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

          // Header dengan tombol refresh
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getButtonColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.tipe == 'masuk' ? Icons.login : Icons.logout,
                    color: _getButtonColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getModalTitle(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pilih lokasi absensi Anda',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Tombol refresh di modal
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: _getButtonColor(),
                      size: 20,
                    ),
                    onPressed: () {
                      lokasiController.fetchUserLokasi();
                      Get.snackbar(
                        'Sukses',
                        'Daftar lokasi diperbarui',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    tooltip: 'Refresh Lokasi',
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                  ),
                );
              }

              if (lokasiController.userLokasis.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            lokasiController.fetchUserLokasi();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    const Text(
                      'Pilih Lokasi Absensi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('-- Pilih Lokasi --'),
                        value: selectedLokasiId,
                        isExpanded: true,
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
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '📍 ${lokasi['koordinat']}',
                                  style: TextStyle(
                                    fontSize: 10,
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
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
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
                                  padding: const EdgeInsets.all(6),
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
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Lokasi dipilih',
                                        style: TextStyle(
                                          fontSize: 10,
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getButtonColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getButtonColor().withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: _getButtonColor(),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedLokasiNama ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getButtonColor(),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedLokasiKoordinat ?? '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getButtonColor().withOpacity(0.8),
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
                      height: 45,
                      child: Obx(() {
                        final isLoading = lokasiController.isLoading.value;
                        return ElevatedButton(
                          onPressed: (selectedLokasiId != null && !isLoading)
                              ? () async {
                                  // Submit absensi sesuai tipe
                                  final success = widget.tipe == 'masuk'
                                      ? await lokasiController
                                            .submitAbsensiMasuk(
                                              selectedLokasiId!,
                                              selectedLokasiNama!,
                                              selectedLokasiKoordinat!,
                                            )
                                      : await lokasiController
                                            .submitAbsensiPulang(
                                              selectedLokasiId!,
                                              selectedLokasiNama!,
                                              selectedLokasiKoordinat!,
                                            );

                                  if (success) {
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
                                            Text(
                                              'Absen ${widget.tipe} Berhasil!',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Anda telah absen ${widget.tipe} di:',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              selectedLokasiNama!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Waktu: ${DateTime.now().toString().substring(0, 16)}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Get.back(); // Tutup dialog sukses
                                              Get.back(); // Tutup modal absensi
                                              // Refresh data
                                              lokasiController
                                                  .fetchUserLokasi();
                                              lokasiController
                                                  .cekStatusHariIni();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getButtonColor(),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            isLoading
                                ? 'Memproses...'
                                : (selectedLokasiId != null
                                      ? _getButtonText()
                                      : 'PILIH LOKASI TERLEBIH DAHULU'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              );
            }),
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
