// lib/pages/user/riwayat_absensi_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/user_lokasi_controller.dart';

class RiwayatAbsensiPage extends StatelessWidget {
  const RiwayatAbsensiPage({super.key});

  // Base URL Laravel (sesuaikan dengan IP komputer Anda)
  // static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'http://192.168.1.9:8000';
  static const String baseUrl = 'http://192.168.1.10:8000';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserLokasiController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Absensi',
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
              controller.fetchRiwayatAbsensi();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoadingRiwayat.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat riwayat absensi...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (controller.riwayatAbsensi.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history,
                      size: 60,
                      color: Colors.blue.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum Ada Riwayat Absensi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anda belum melakukan absensi.\nSilahkan absen terlebih dahulu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.fetchRiwayatAbsensi();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Group data by tanggal
        final groupedData = _groupByDate(controller.riwayatAbsensi);
        final dates = groupedData.keys.toList()..sort((a, b) => b.compareTo(a));

        // List of absensi per hari
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final tanggal = dates[index];
            final items = groupedData[tanggal]!;

            // Cari data masuk dan pulang - PERBAIKAN DI SINI
            Map<String, dynamic>? dataMasuk;
            Map<String, dynamic>? dataPulang;

            try {
              dataMasuk = items.firstWhere(
                (item) => item['tipe_absen'] == 'masuk',
              );
            } catch (e) {
              dataMasuk = null;
            }

            try {
              dataPulang = items.firstWhere(
                (item) => item['tipe_absen'] == 'pulang',
              );
            } catch (e) {
              dataPulang = null;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  _showDetailDialog(
                    context,
                    dataMasuk,
                    dataPulang,
                    index + 1,
                    tanggal,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Nomor dengan background lingkaran
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue, Colors.blue.shade700],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Konten utama
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tanggal
                            Text(
                              _formatTanggal(tanggal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Status Masuk
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: dataMasuk != null
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: dataMasuk != null
                                        ? Colors.green
                                        : Colors.grey,
                                    fontWeight: dataMasuk != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (dataMasuk != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatJam(
                                      dataMasuk['waktu_absen']?.toString() ??
                                          '',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Status Pulang
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: dataPulang != null
                                        ? Colors.orange
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Pulang',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: dataPulang != null
                                        ? Colors.orange
                                        : Colors.grey,
                                    fontWeight: dataPulang != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (dataPulang != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatJam(
                                      dataPulang['waktu_absen']?.toString() ??
                                          '',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Icon indikator
                      if (dataMasuk != null && dataPulang != null)
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
                        )
                      else if (dataMasuk != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.access_time,
                            color: Colors.blue.shade400,
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
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.fetchRiwayatAbsensi();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // Group data berdasarkan tanggal
  Map<String, List<Map<String, dynamic>>> _groupByDate(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in data) {
      if (item['waktu_absen'] != null) {
        String waktu = item['waktu_absen'].toString();
        String tanggal = '';

        if (waktu.contains('T')) {
          tanggal = waktu.split('T')[0];
        } else if (waktu.contains(' ')) {
          tanggal = waktu.split(' ')[0];
        }

        if (tanggal.isNotEmpty) {
          if (!grouped.containsKey(tanggal)) {
            grouped[tanggal] = [];
          }
          grouped[tanggal]!.add(item);
        }
      }
    }

    return grouped;
  }

  String _formatTanggal(String tanggal) {
    try {
      final parts = tanggal.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}'; // DD-MM-YYYY
      }
      return tanggal;
    } catch (e) {
      return tanggal;
    }
  }

  String _formatJam(String waktuStr) {
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

  // Fungsi untuk mendapatkan URL foto lengkap
  String _getFullImageUrl(String path) {
    if (path.isEmpty) return '';

    if (path.startsWith('http')) {
      if (path.contains('localhost')) {
        // return path.replaceFirst('localhost', '192.168.1.9:8000');
        return path.replaceFirst('localhost', '192.168.1.10:8000');
        // return path.replaceFirst('localhost', '10.0.2.2:8000');
      }
      return path;
    }
    if (path.startsWith('/storage')) {
      return baseUrl + path;
    }
    return baseUrl + '/storage/foto_absensi/' + path;
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic>? dataMasuk,
    Map<String, dynamic>? dataPulang,
    int no,
    String tanggal,
  ) {
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
          child: DefaultTabController(
            length: 2,
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
                            _formatTanggal(tanggal),
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
                const SizedBox(height: 16),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Absen Masuk'),
                      Tab(text: 'Absen Pulang'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab Content
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      // Tab Masuk
                      dataMasuk != null
                          ? _buildDetailContent(dataMasuk, 'masuk')
                          : _buildEmptyContent('Belum absen masuk'),
                      // Tab Pulang
                      dataPulang != null
                          ? _buildDetailContent(dataPulang, 'pulang')
                          : _buildEmptyContent('Belum absen pulang'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol Tutup
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

  Widget _buildDetailContent(Map<String, dynamic> item, String tipe) {
    String lokasi = '-';
    String koordinatLokasi = '-';
    String koordinatKamu = '-';
    String waktu = '-';
    String fotoWajah = '';
    LatLng? lokasiLatLng;
    LatLng? kamuLatLng;

    try {
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

      if (item['titik_koordinat_lokasi'] != null) {
        koordinatLokasi = item['titik_koordinat_lokasi'].toString();
      }

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
        } catch (e) {}
      }

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
        } catch (e) {}
      }

      if (item['foto_wajah'] != null &&
          item['foto_wajah'].toString().isNotEmpty) {
        fotoWajah = item['foto_wajah'].toString();
      }

      if (item['waktu_absen'] != null) {
        waktu = item['waktu_absen'].toString();
        if (waktu.contains('T')) {
          waktu = waktu.replaceFirst('T', ' ');
        }
        if (waktu.contains('.')) {
          waktu = waktu.split('.').first;
        }
      }
    } catch (e) {}

    Color themeColor = tipe == 'masuk' ? Colors.blue : Colors.orange;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lokasi
          _buildDetailItem(
            icon: Icons.location_on,
            label: 'Lokasi',
            value: lokasi,
            color: themeColor,
          ),
          const SizedBox(height: 12),

          // Titik Koordinat Lokasi
          _buildDetailItem(
            icon: Icons.pin_drop,
            label: 'Titik Koordinat Lokasi',
            value: koordinatLokasi,
            color: themeColor,
          ),
          const SizedBox(height: 12),

          // Preview Map Lokasi
          if (lokasiLatLng != null) ...[
            const SizedBox(height: 8),
            Text(
              'Preview Lokasi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
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
                      markerId: MarkerId('lokasi_$tipe'),
                      position: lokasiLatLng,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        tipe == 'masuk'
                            ? BitmapDescriptor.hueBlue
                            : BitmapDescriptor.hueOrange,
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

          // Titik Koordinat Kamu
          _buildDetailItem(
            icon: Icons.my_location,
            label: 'Titik Koordinat Kamu',
            value: koordinatKamu.isNotEmpty
                ? koordinatKamu
                : '(Tidak tersedia)',
            valueColor: koordinatKamu.isNotEmpty ? Colors.green : Colors.grey,
            color: themeColor,
          ),
          const SizedBox(height: 12),

          // Preview Map Posisi Kamu
          if (kamuLatLng != null) ...[
            const SizedBox(height: 8),
            Text(
              'Preview Posisi Kamu',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
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
                      markerId: const MarkerId('posisi_kamu'),
                      position: kamuLatLng,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
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
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waktu Absen $tipe',
                  style: TextStyle(
                    fontSize: 11,
                    color: themeColor,
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

          // Foto
          if (fotoWajah.isNotEmpty) ...[
            const Text(
              'Foto Bukti',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
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
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(child: Text('Gagal memuat foto')),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color color = Colors.blue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 24, child: Icon(icon, color: color, size: 18)),
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
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
