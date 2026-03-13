import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/lokasi_controller.dart';
import '../../../../models/lokasi_model.dart';

class LokasiTableWidget extends GetView<LokasiController> {
  const LokasiTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // GANTI DENGAN Obx AGAR AUTO UPDATE
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.lokasis.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Belum ada data lokasi',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Tambahkan lokasi menggunakan form di atas',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      // GROUP DATA BERDASARKAN USER
      final Map<String, List<LokasiModel>> groupedByUser = {};
      for (var lokasi in controller.lokasis) {
        if (!groupedByUser.containsKey(lokasi.user)) {
          groupedByUser[lokasi.user] = [];
        }
        groupedByUser[lokasi.user]!.add(lokasi);
      }

      // URUTKAN USER BERDASARKAN NAMA
      final sortedUsers = groupedByUser.keys.toList()..sort();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan total
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                const Text(
                  'Daftar Lokasi per User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Total: ${controller.lokasis.length} lokasi • ${groupedByUser.length} user',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // TABEL DENGAN GROUPING
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.blue.shade50,
                  ),
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Daftar Lokasi')),
                    DataColumn(label: Text('Jumlah')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: List.generate(sortedUsers.length, (index) {
                    final userName = sortedUsers[index];
                    final userLokasi = groupedByUser[userName]!;

                    return DataRow(
                      cells: [
                        // Nomor
                        DataCell(
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // User
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(minWidth: 120),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Daftar Lokasi (chip-chip)
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(minWidth: 300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: userLokasi.map((lokasi) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        lokasi.lokasi,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        // Jumlah Lokasi
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${userLokasi.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ),

                        // Aksi
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (userLokasi.length == 1)
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: () => _showDeleteDialog(
                                    context,
                                    userLokasi.first,
                                  ),
                                  tooltip: 'Hapus lokasi ini',
                                )
                              else
                                PopupMenuButton<String>(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'hapus_semua',
                                      child: Text(
                                        'Hapus semua lokasi user ini',
                                      ),
                                    ),
                                    ...userLokasi.map((lokasi) {
                                      return PopupMenuItem(
                                        value: 'hapus_${lokasi.id}',
                                        child: Text('Hapus "${lokasi.lokasi}"'),
                                      );
                                    }),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'hapus_semua') {
                                      _showDeleteAllDialog(
                                        context,
                                        userName,
                                        userLokasi,
                                      );
                                    } else if (value.startsWith('hapus_')) {
                                      final id = int.parse(value.split('_')[1]);
                                      final lokasi = userLokasi.firstWhere(
                                        (l) => l.id == id,
                                      );
                                      _showDeleteDialog(context, lokasi);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showDeleteDialog(BuildContext context, LokasiModel item) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Hapus Lokasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin menghapus lokasi "${item.lokasi}" untuk user ${item.user}?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog
              await controller.deleteLokasi(
                item.id,
              ); // TUNGGU PROSES HAPUS SELESAI
              // TIDAK PERLU PANGGIL CONTROLLER.FETCHLOKASI() LAGI
              // KARENA DI DALAM DELETE SUDAH ADA
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(
    BuildContext context,
    String userName,
    List<LokasiModel> lokasiList,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Hapus Semua Lokasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin menghapus SEMUA lokasi (${lokasiList.length}) untuk user $userName?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog

              // TAMPILKAN LOADING
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              // Hapus satu per satu
              for (var lokasi in lokasiList) {
                await controller.deleteLokasi(lokasi.id);
              }

              // Tutup loading
              Get.back();

              Get.snackbar(
                '✅ Berhasil',
                'Semua lokasi user $userName telah dihapus',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}
