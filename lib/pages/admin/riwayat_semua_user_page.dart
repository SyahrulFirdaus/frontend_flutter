// lib/pages/admin/riwayat_semua_user_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/admin_absensi_controller.dart';
import '../../controllers/auth_controller.dart';

class RiwayatSemuaUserPage extends StatelessWidget {
  const RiwayatSemuaUserPage({super.key});

  // Base URL Laravel (sesuaikan dengan IP komputer Anda)
  static const String baseUrl = 'http://192.168.1.9:8000';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAbsensiController());
    final auth = Get.find<AuthController>();

    // Panggil data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllUsers();
      controller.fetchAllAbsensi();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Semua User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetFilter();
              controller.fetchAllUsers();
              controller.fetchAllAbsensi();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value || controller.isLoadingUsers.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text('Memuat data...'),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Filter Section (hanya filter user)
            _buildFilterSection(controller),

            const Divider(height: 1),

            // Summary Card dengan data real
            _buildSummaryCard(controller),

            const Divider(height: 1),

            // List Absensi
            Expanded(child: _buildAbsensiList(controller)),
          ],
        );
      }),
    );
  }

  // ================= FUNGSI UNTUK MENDAPATKAN URL FOTO LENGKAP =================
  String _getFullImageUrl(String path) {
    if (path.isEmpty) return '';

    print('🔧 Admin - Memproses path foto: $path');

    String result = '';

    // Kasus 1: Path sudah lengkap dengan http
    if (path.startsWith('http')) {
      result = path;
    }
    // Kasus 2: Path dimulai dengan /storage
    else if (path.startsWith('/storage')) {
      result = baseUrl + path;
      print('✅ Admin - Path dengan baseUrl: $result');
    }
    // Kasus 3: Path hanya nama file
    else {
      result = baseUrl + '/storage/foto_absensi/' + path;
      print('✅ Admin - Path dari nama file: $result');
    }

    // PERBAIKAN: Pastikan port 8000 selalu ada
    if (result.contains('192.168.1.9') && !result.contains(':8000')) {
      result = result.replaceFirst('192.168.1.9', '192.168.1.9:8000');
    }

    // Jika masih ada localhost, ganti dengan IP+port
    if (result.contains('localhost')) {
      result = result.replaceFirst('localhost', '192.168.1.9:8000');
    }

    return result;
  }

  Widget _buildFilterSection(AdminAbsensiController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter User',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),

          // Filter User
          Obx(() {
            if (controller.semuaUsers.isEmpty) {
              return const Center(child: Text('Tidak ada data user'));
            }

            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Pilih User',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      prefixIcon: const Icon(Icons.person, size: 18),
                    ),
                    value: controller.selectedUserId.value.isEmpty
                        ? null
                        : controller.selectedUserId.value,
                    hint: const Text('Semua User'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('Semua User'),
                      ),
                      ...controller.semuaUsers.map((user) {
                        return DropdownMenuItem<String>(
                          value: user['id'].toString(),
                          child: Text(user['name'] ?? 'Unknown'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      controller.filterByUser(value ?? '');
                    },
                  ),
                ),
                if (controller.selectedUserId.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: controller.resetFilter,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AdminAbsensiController controller) {
    // Hitung statistik real dari data
    int totalUser = controller.semuaUsers.length;
    int totalAbsensi = controller.semuaAbsensi.length;
    int hariAktif = controller.getUniqueDatesCount();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.people,
            value: totalUser.toString(),
            label: 'Total User',
            color: Colors.blue,
          ),
          Container(height: 30, width: 1, color: Colors.blue.shade200),
          _buildSummaryItem(
            icon: Icons.fingerprint,
            value: totalAbsensi.toString(),
            label: 'Total Absensi',
            color: Colors.green,
          ),
          Container(height: 30, width: 1, color: Colors.blue.shade200),
          _buildSummaryItem(
            icon: Icons.today,
            value: hariAktif.toString(),
            label: 'Hari Aktif',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildAbsensiList(AdminAbsensiController controller) {
    if (controller.semuaAbsensi.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data Absensi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada user yang melakukan absensi',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: controller.semuaAbsensi.length,
      itemBuilder: (context, index) {
        final item = controller.semuaAbsensi[index];
        final userId = item['user_id'] ?? 0;

        // Cari user name
        String userName = controller.getUserNameById(userId);

        // Ambil data lokasi
        String lokasiNama = '-';
        if (item['lokasi'] != null) {
          if (item['lokasi'] is Map) {
            lokasiNama = item['lokasi']['lokasi']?.toString() ?? '-';
          } else {
            lokasiNama = item['lokasi'].toString();
          }
        }

        // Cek apakah ada foto
        String fotoWajah = '';
        if (item['foto_wajah'] != null &&
            item['foto_wajah'].toString().isNotEmpty) {
          fotoWajah = item['foto_wajah'].toString();
        }

        // Format waktu
        String waktu = controller.formatWaktu(
          item['waktu_absen']?.toString() ?? '',
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              _showDetailDialog(context, item, userName, index + 1);
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar dengan inisial user
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Konten utama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lokasiNama,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          waktu,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Indikator foto jika ada
                        if (fotoWajah.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Dengan Foto',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Icon status
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade400,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> item,
    String userName,
    int no,
  ) {
    String lokasi = '-';
    String koordinatLokasi = '-';
    String koordinatKamu = '-';
    String waktu = '-';
    String fotoWajah = '';
    LatLng? lokasiLatLng;
    LatLng? kamuLatLng;

    try {
      // Handle lokasi
      if (item['lokasi'] != null) {
        if (item['lokasi'] is Map) {
          lokasi = item['lokasi']['lokasi']?.toString() ?? '-';
          if (item['lokasi']['koordinat'] != null) {
            koordinatLokasi = item['lokasi']['koordinat'].toString();
          }
        } else {
          lokasi = item['lokasi'].toString();
        }
      }

      // Handle titik_koordinat_lokasi (jika ada langsung di item)
      if (item['titik_koordinat_lokasi'] != null) {
        koordinatLokasi = item['titik_koordinat_lokasi'].toString();
      }

      // Parse koordinat lokasi untuk map
      if (koordinatLokasi != '-') {
        try {
          final parts = koordinatLokasi.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null) {
              lokasiLatLng = LatLng(lat, lng);
            }
          }
        } catch (e) {
          print('Error parsing koordinat lokasi: $e');
        }
      }

      // Handle titik_koordinat_kamu
      if (item['titik_koordinat_kamu'] != null &&
          item['titik_koordinat_kamu'].toString().isNotEmpty) {
        koordinatKamu = item['titik_koordinat_kamu'].toString();
        try {
          final parts = koordinatKamu.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null) {
              kamuLatLng = LatLng(lat, lng);
            }
          }
        } catch (e) {
          print('Error parsing koordinat kamu: $e');
        }
      }

      // Handle foto_wajah
      if (item['foto_wajah'] != null &&
          item['foto_wajah'].toString().isNotEmpty) {
        fotoWajah = item['foto_wajah'].toString();
        print('📸 Admin - Foto: ${_getFullImageUrl(fotoWajah)}');
      }

      if (item['waktu_absen'] != null) {
        waktu = item['waktu_absen'].toString();
        // Format sederhana
        if (waktu.contains('T')) {
          waktu = waktu.replaceFirst('T', ' ');
        }
        if (waktu.contains('.')) {
          waktu = waktu.split('.').first;
        }
      }
    } catch (e) {
      print('Error parsing detail: $e');
    }

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$no',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Absensi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Lokasi
                _buildDetailItem(
                  icon: Icons.location_on,
                  label: 'Lokasi',
                  value: lokasi,
                ),
                const SizedBox(height: 12),

                // Titik Koordinat Lokasi
                _buildDetailItem(
                  icon: Icons.pin_drop,
                  label: 'Titik Koordinat Lokasi',
                  value: koordinatLokasi,
                ),
                const SizedBox(height: 12),

                // Preview Map Lokasi
                if (lokasiLatLng != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Preview Lokasi Absensi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: lokasiLatLng,
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('lokasi_absensi'),
                            position: lokasiLatLng,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                            infoWindow: InfoWindow(
                              title: 'Lokasi Absensi',
                              snippet: koordinatLokasi,
                            ),
                          ),
                        },
                        zoomControlsEnabled: true,
                        myLocationButtonEnabled: false,
                        compassEnabled: true,
                        mapToolbarEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Titik Koordinat User
                _buildDetailItem(
                  icon: Icons.my_location,
                  label: 'Titik Koordinat User',
                  value: koordinatKamu.isNotEmpty
                      ? koordinatKamu
                      : '(Tidak tersedia)',
                  valueColor: koordinatKamu.isNotEmpty
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(height: 12),

                // Preview Map Posisi User
                if (kamuLatLng != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Preview Posisi User',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: kamuLatLng,
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('posisi_user'),
                            position: kamuLatLng,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                            infoWindow: InfoWindow(
                              title: 'Posisi User',
                              snippet: koordinatKamu,
                            ),
                          ),
                        },
                        zoomControlsEnabled: true,
                        myLocationButtonEnabled: false,
                        compassEnabled: true,
                        mapToolbarEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Waktu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Absen',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        waktu,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // FOTO WAJAH - TAMPIL DI BAGIAN BAWAH
                if (fotoWajah.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Foto Bukti Absensi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tampilkan gambar
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getFullImageUrl(fotoWajah),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Error loading image: $error');
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Gagal memuat foto',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade100,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const CircularProgressIndicator(),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Memuat foto...',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 20),

                // Tombol OK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 24, child: Icon(icon, color: Colors.blue, size: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
