// lib/pages/user/riwayat_absensi_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/user_lokasi_controller.dart';

class RiwayatAbsensiPage extends StatelessWidget {
  const RiwayatAbsensiPage({super.key});

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

        // List of absensi
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.riwayatAbsensi.length,
          itemBuilder: (context, index) {
            final item = controller.riwayatAbsensi[index];

            // Extract data dengan aman
            String lokasi = '-';
            String waktu = '-';
            String titikKoordinatLokasi = '-';
            String titikKoordinatKamu = '-';

            try {
              // Handle lokasi
              if (item['lokasi'] != null) {
                if (item['lokasi'] is Map) {
                  lokasi = item['lokasi']['lokasi']?.toString() ?? '-';
                } else {
                  lokasi = item['lokasi'].toString();
                }
              }

              // Handle titik_koordinat_lokasi
              if (item['titik_koordinat_lokasi'] != null) {
                titikKoordinatLokasi = item['titik_koordinat_lokasi']
                    .toString();
              }

              // Handle titik_koordinat_kamu (field baru)
              if (item['titik_koordinat_kamu'] != null &&
                  item['titik_koordinat_kamu'].toString().isNotEmpty) {
                titikKoordinatKamu = item['titik_koordinat_kamu'].toString();
              }

              // Handle waktu_absen
              if (item['waktu_absen'] != null) {
                waktu = _formatWaktu(item['waktu_absen'].toString());
              }
            } catch (e) {
              print('Error parsing data: $e');
            }

            // Format tanggal dan waktu
            String tanggal = waktu.contains(' ') ? waktu.split(' ')[0] : waktu;
            String jam = waktu.contains(' ') ? waktu.split(' ')[1] : '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  _showDetailDialog(context, item, index + 1);
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
                            // Lokasi
                            Text(
                              lokasi,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Tanggal dan jam
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tanggal,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  jam,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            // Indikator lokasi real-time
                            if (titikKoordinatKamu != '-') ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.my_location,
                                    size: 12,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lokasi real-time tersedia',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Icon sukses
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

  // Fungsi untuk memformat waktu dari berbagai format
  String _formatWaktu(String waktuStr) {
    try {
      // Handle format ISO: "2026-02-20T03:22:00.000Z"
      if (waktuStr.contains('T')) {
        final parts = waktuStr.split('T');
        String tanggal = parts[0];

        // Format tanggal: YYYY-MM-DD → DD-MM-YYYY
        final tglParts = tanggal.split('-');
        if (tglParts.length == 3) {
          tanggal = '${tglParts[2]}-${tglParts[1]}-${tglParts[0]}';
        }

        String jam = parts[1];
        // Hapus bagian .000Z atau zona waktu lainnya
        jam = jam.replaceAll(RegExp(r'\..*$'), '');
        jam = jam.replaceAll(RegExp(r'Z$'), '');

        // Ambil hanya jam dan menit (HH:MM)
        if (jam.contains(':')) {
          final jamParts = jam.split(':');
          if (jamParts.length >= 2) {
            jam = '${jamParts[0]}:${jamParts[1]}';
          }
        }

        return '$tanggal $jam';
      }

      // Handle format dengan spasi: "2026-02-20 03:22:00"
      if (waktuStr.contains(' ')) {
        final parts = waktuStr.split(' ');
        if (parts.length >= 2) {
          String tanggal = parts[0];
          // Format tanggal: YYYY-MM-DD → DD-MM-YYYY
          final tglParts = tanggal.split('-');
          if (tglParts.length == 3) {
            tanggal = '${tglParts[2]}-${tglParts[1]}-${tglParts[0]}';
          }

          String jam = parts[1];
          // Ambil hanya jam dan menit (HH:MM)
          if (jam.contains(':')) {
            final jamParts = jam.split(':');
            if (jamParts.length >= 2) {
              jam = '${jamParts[0]}:${jamParts[1]}';
            }
          }

          return '$tanggal $jam';
        }
      }

      return waktuStr;
    } catch (e) {
      print('Error format waktu: $e');
      return waktuStr;
    }
  }

  // Fungsi untuk menghitung jarak antara dua titik koordinat
  String _hitungJarak(LatLng titik1, LatLng titik2) {
    const double R = 6371; // Radius bumi dalam km

    double lat1 = titik1.latitude * pi / 180;
    double lat2 = titik2.latitude * pi / 180;
    double deltaLat = (titik2.latitude - titik1.latitude) * pi / 180;
    double deltaLng = (titik2.longitude - titik1.longitude) * pi / 180;

    double a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanceKm = R * c;
    double distanceM = distanceKm * 1000;
    double distanceCm = distanceM * 100;

    if (distanceCm < 100) {
      // Kurang dari 100 cm
      return '${distanceCm.toStringAsFixed(0)} cm';
    } else if (distanceM < 1000) {
      // Kurang dari 1000 meter
      return '${distanceM.toStringAsFixed(1)} meter';
    } else {
      return '${distanceKm.toStringAsFixed(2)} km';
    }
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> item,
    int no,
  ) {
    String lokasi = '-';
    String koordinatLokasi = '-';
    String koordinatKamu = '-';
    String waktu = '-';
    LatLng? lokasiLatLng;
    LatLng? kamuLatLng;
    String jarak = '';

    try {
      if (item['lokasi'] != null) {
        if (item['lokasi'] is Map) {
          lokasi = item['lokasi']['lokasi']?.toString() ?? '-';
        } else {
          lokasi = item['lokasi'].toString();
        }
      }

      // Parse titik_koordinat_lokasi
      if (item['titik_koordinat_lokasi'] != null) {
        koordinatLokasi = item['titik_koordinat_lokasi'].toString();
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

      // Parse titik_koordinat_kamu - TAMPILKAN LENGKAP
      if (item['titik_koordinat_kamu'] != null &&
          item['titik_koordinat_kamu'].toString().isNotEmpty) {
        koordinatKamu = item['titik_koordinat_kamu'].toString();
        if (koordinatKamu.isNotEmpty && koordinatKamu != '-') {
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
      }

      // Hitung jarak jika kedua koordinat tersedia
      if (lokasiLatLng != null && kamuLatLng != null) {
        jarak = _hitungJarak(lokasiLatLng, kamuLatLng);
      }

      if (item['waktu_absen'] != null) {
        waktu = _formatWaktu(item['waktu_absen'].toString());
      }
    } catch (e) {
      print('Error parsing detail: $e');
    }

    String tanggal = waktu.contains(' ') ? waktu.split(' ')[0] : waktu;
    String jam = waktu.contains(' ') ? waktu.split(' ')[1] : '';

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
                    const Expanded(
                      child: Text(
                        'Detail Absensi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
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

                // Titik Koordinat Lokasi (LENGKAP)
                _buildDetailItem(
                  icon: Icons.pin_drop,
                  label: 'Titik Koordinat Lokasi',
                  value: koordinatLokasi,
                ),
                const SizedBox(height: 12),

                // Preview Map Lokasi Absensi
                if (lokasiLatLng != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Preview Lokasi Absensi',
                    style: TextStyle(
                      fontSize: 14,
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

                // Titik Koordinat Kamu (LENGKAP - TIDAK DIPOTONG)
                _buildDetailItem(
                  icon: Icons.my_location,
                  label: 'Titik Koordinat Kamu',
                  value: koordinatKamu.isNotEmpty
                      ? koordinatKamu
                      : '(Tidak tersedia)',
                  valueColor: koordinatKamu.isNotEmpty
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(height: 12),

                // Preview Map Posisi Kamu
                if (kamuLatLng != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Preview Posisi Kamu',
                    style: TextStyle(
                      fontSize: 14,
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
                            markerId: const MarkerId('posisi_kamu'),
                            position: kamuLatLng,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                            infoWindow: InfoWindow(
                              title: 'Posisi Kamu',
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

                // Informasi Jarak (TAMBAHAN BARU)
                if (jarak.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.straighten,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jarak Antara Lokasi dan Posisi Kamu',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                jarak,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Waktu
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.calendar_today,
                        label: 'Tanggal',
                        value: tanggal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.access_time,
                        label: 'Jam Absen',
                        value: jam,
                      ),
                    ),
                  ],
                ),

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
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
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
                  fontSize: 14,
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
