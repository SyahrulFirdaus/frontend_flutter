// lib/pages/admin/riwayat_semua_user_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/admin_absensi_controller.dart';
import '../../controllers/auth_controller.dart';

class RiwayatSemuaUserPage extends StatelessWidget {
  const RiwayatSemuaUserPage({super.key});

  // Base URL Laravel (sesuaikan dengan IP komputer Anda)
  static const String baseUrl = 'http://192.168.1.10:8000';

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
            // Filter Section
            _buildFilterSection(controller),
            const Divider(height: 1),

            // Summary Card
            _buildSummaryCard(controller),
            const Divider(height: 1),

            // List Absensi (Group by User & Date)
            Expanded(child: _buildAbsensiList(controller)),
          ],
        );
      }),
    );
  }

  // ================= FUNGSI UNTUK MENDAPATKAN URL FOTO LENGKAP =================
  String _getFullImageUrl(String path) {
    if (path.isEmpty) return '';

    String result = '';

    if (path.startsWith('http')) {
      result = path;
    } else if (path.startsWith('/storage')) {
      result = baseUrl + path;
    } else {
      result = baseUrl + '/storage/foto_absensi/' + path;
    }

    if (result.contains('192.168.1.10') && !result.contains(':8000')) {
      result = result.replaceFirst('192.168.1.10', '192.168.1.10:8000');
    }

    if (result.contains('localhost')) {
      result = result.replaceFirst('localhost', '192.168.1.10:8000');
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

  // Group data by user and date
  Map<String, Map<String, List<Map<String, dynamic>>>> _groupByUserAndDate(
    List<Map<String, dynamic>> data,
    AdminAbsensiController controller,
  ) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> result = {};

    for (var item in data) {
      // Ambil userId dari item
      String userId = item['user_id']?.toString() ?? '0';

      // Dapatkan userName berdasarkan userId
      String userName = controller.getUserNameById(int.tryParse(userId) ?? 0);

      // Inisialisasi jika belum ada
      if (!result.containsKey(userName)) {
        result[userName] = {};
      }

      // Parse tanggal dari waktu_absen
      if (item['waktu_absen'] != null) {
        String waktu = item['waktu_absen'].toString();
        String tanggal = '';

        if (waktu.contains('T')) {
          tanggal = waktu.split('T')[0];
        } else if (waktu.contains(' ')) {
          tanggal = waktu.split(' ')[0];
        }

        if (tanggal.isNotEmpty) {
          if (!result[userName]!.containsKey(tanggal)) {
            result[userName]![tanggal] = [];
          }
          result[userName]![tanggal]!.add(item);
        }
      }
    }

    return result;
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

    // Group data by user and date - KIRIM CONTROLLER SEBAGAI PARAMETER
    final groupedData = _groupByUserAndDate(
      controller.semuaAbsensi,
      controller,
    );
    final userNames = groupedData.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: userNames.length,
      itemBuilder: (context, userIndex) {
        final userName = userNames[userIndex];
        final userDates = groupedData[userName]!;
        final dates = userDates.keys.toList()..sort((a, b) => b.compareTo(a));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header User
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${dates.length} hari',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // List absensi per user
            ...dates.map((tanggal) {
              final items = userDates[tanggal]!;

              // Cari data masuk dan pulang
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

              // Ambil ID absensi untuk keperluan hapus
              int? idMasuk = dataMasuk?['id'];
              int? idPulang = dataPulang?['id'];

              // Ambil lokasi dari item pertama
              String lokasi = '';
              if (items.isNotEmpty && items.first['lokasi'] != null) {
                if (items.first['lokasi'] is Map) {
                  lokasi = items.first['lokasi']['lokasi']?.toString() ?? '';
                } else {
                  lokasi = items.first['lokasi'].toString();
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    _showDetailDialog(
                      context,
                      dataMasuk,
                      dataPulang,
                      userName,
                      tanggal,
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Nomor urut
                        Container(
                          width: 36,
                          height: 36,
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
                              '${userIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                              // Tanggal dan Lokasi
                              Row(
                                children: [
                                  Text(
                                    _formatTanggal(tanggal),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      lokasi,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
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
                                      fontSize: 12,
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
                                        fontSize: 11,
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
                                      fontSize: 12,
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
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Tombol Hapus
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'hapus_masuk' && idMasuk != null) {
                              _showDeleteConfirmation(
                                context,
                                idMasuk,
                                'masuk',
                                controller,
                              );
                            } else if (value == 'hapus_pulang' &&
                                idPulang != null) {
                              _showDeleteConfirmation(
                                context,
                                idPulang,
                                'pulang',
                                controller,
                              );
                            } else if (value == 'hapus_semua' &&
                                idMasuk != null &&
                                idPulang != null) {
                              _showDeleteConfirmation(
                                context,
                                idMasuk,
                                'semua',
                                controller,
                                idPulang: idPulang,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            if (dataMasuk != null)
                              const PopupMenuItem(
                                value: 'hapus_masuk',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Hapus Absen Masuk'),
                                  ],
                                ),
                              ),
                            if (dataPulang != null)
                              const PopupMenuItem(
                                value: 'hapus_pulang',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Hapus Absen Pulang'),
                                  ],
                                ),
                              ),
                            if (dataMasuk != null && dataPulang != null)
                              const PopupMenuItem(
                                value: 'hapus_semua',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Hapus Semua'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // ================= FUNGSI HAPUS ABSENSI =================
  void _showDeleteConfirmation(
    BuildContext context,
    int id,
    String tipe,
    AdminAbsensiController controller, {
    int? idPulang,
  }) {
    String pesan = '';
    String title = 'Konfirmasi Hapus';

    if (tipe == 'masuk') {
      pesan = 'Yakin ingin menghapus absen MASUK ini?';
    } else if (tipe == 'pulang') {
      pesan = 'Yakin ingin menghapus absen PULANG ini?';
    } else if (tipe == 'semua') {
      pesan = 'Yakin ingin menghapus SEMUA absensi (masuk & pulang) hari ini?';
    }

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(pesan),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog konfirmasi

              bool success = false;
              if (tipe == 'masuk') {
                success = await controller.deleteAbsensi(id);
              } else if (tipe == 'pulang') {
                success = await controller.deleteAbsensi(id);
              } else if (tipe == 'semua' && idPulang != null) {
                // Hapus masuk dulu, lalu pulang
                bool success1 = await controller.deleteAbsensi(id);
                bool success2 = await controller.deleteAbsensi(idPulang);
                success = success1 && success2;
              }

              if (success) {
                Get.snackbar(
                  'Sukses',
                  'Data absensi berhasil dihapus',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 2),
                );
                controller.fetchAllAbsensi(); // Refresh data
              } else {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus data absensi',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
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

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic>? dataMasuk,
    Map<String, dynamic>? dataPulang,
    String userName,
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
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
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
                            '$userName - ${_formatTanggal(tanggal)}',
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
                          : _buildEmptyContent('User belum absen masuk'),
                      // Tab Pulang
                      dataPulang != null
                          ? _buildDetailContent(dataPulang, 'pulang')
                          : _buildEmptyContent('User belum absen pulang'),
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

          // Titik Koordinat User
          _buildDetailItem(
            icon: Icons.my_location,
            label: 'Titik Koordinat User',
            value: koordinatKamu.isNotEmpty
                ? koordinatKamu
                : '(Tidak tersedia)',
            valueColor: koordinatKamu.isNotEmpty ? Colors.green : Colors.grey,
            color: themeColor,
          ),
          const SizedBox(height: 12),

          // Preview Map Posisi User
          if (kamuLatLng != null) ...[
            const SizedBox(height: 8),
            Text(
              'Preview Posisi User',
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
                      markerId: const MarkerId('posisi_user'),
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
                      child: const Center(child: Text('Gagal memuat foto')),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
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
