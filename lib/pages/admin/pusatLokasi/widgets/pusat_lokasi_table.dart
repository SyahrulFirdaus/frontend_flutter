import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/pusat_lokasi_controller.dart';
import '../../../../models/pusat_lokasi_model.dart';
import '../modals/edit_pusat_lokasi_modal.dart';
import '../modals/detail_pusat_lokasi_modal.dart';

class PusatLokasiTable extends StatelessWidget {
  final PusatLokasiController controller;

  const PusatLokasiTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ========== DEBUGGING ==========
      print('🔄 Building PusatLokasiTable');
      print('   - isLoading: ${controller.isLoading.value}');
      print('   - data count: ${controller.filteredLokasis.length}');
      print('   - error: ${controller.errorMessage.value}');

      // FALLBACK: Jika data sudah ada tapi loading masih true, tampilkan data
      if (controller.isLoading.value && controller.filteredLokasis.isNotEmpty) {
        print(
          '⚠️ WARNING: isLoading true tapi data sudah ada! Memaksa tampilkan data...',
        );
        // LANGSUNG TAMPILKAN DATA
        return _buildDataTable(context);
      }

      // LOADING STATE
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat data...'),
            ],
          ),
        );
      }

      // ERROR STATE
      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchPusatLokasi(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );
      }

      // EMPTY STATE
      if (controller.filteredLokasis.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isEmpty
                    ? 'Belum ada data pusat lokasi'
                    : 'Tidak ada hasil untuk "${controller.searchQuery.value}"',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              if (controller.searchQuery.value.isNotEmpty)
                TextButton(
                  onPressed: () => controller.search(''),
                  child: const Text('Reset Pencarian'),
                ),
            ],
          ),
        );
      }

      // TAMPILKAN DATA
      return _buildDataTable(context);
    });
  }

  // ========== BUILD DATA TABLE ==========
  Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: [
            if (controller.isSelectionMode.value)
              const DataColumn(label: Text('Pilih')),
            const DataColumn(label: Text('No')),
            const DataColumn(label: Text('Nama Lokasi')),
            const DataColumn(label: Text('Titik Kordinat')),
            const DataColumn(label: Text('Keterangan')),
            const DataColumn(label: Text('Aksi')),
          ],
          rows: List.generate(controller.filteredLokasis.length, (index) {
            final item = controller.filteredLokasis[index];
            final isSelected = controller.selectedIds.contains(item.id);

            return DataRow(
              selected: isSelected,
              onSelectChanged: controller.isSelectionMode.value
                  ? (selected) => controller.toggleSelectItem(item.id)
                  : (_) {
                      DetailPusatLokasiModal.show(context, item);
                    },
              cells: [
                if (controller.isSelectionMode.value)
                  DataCell(
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => controller.toggleSelectItem(item.id),
                      activeColor: Colors.blue,
                    ),
                  ),
                // Nomor
                DataCell(
                  InkWell(
                    onTap: () {
                      if (!controller.isSelectionMode.value) {
                        DetailPusatLokasiModal.show(context, item);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
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
                ),
                // Nama Lokasi
                DataCell(
                  InkWell(
                    onTap: () {
                      if (!controller.isSelectionMode.value) {
                        DetailPusatLokasiModal.show(context, item);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        item.namaLokasi,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                // Titik Kordinat
                DataCell(
                  InkWell(
                    onTap: () {
                      if (!controller.isSelectionMode.value) {
                        DetailPusatLokasiModal.show(context, item);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            item.isKordinatValid
                                ? Icons.check_circle
                                : Icons.warning,
                            size: 14,
                            color: item.isKordinatValid
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.formattedKordinat,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: item.isKordinatValid
                                    ? Colors.black87
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Keterangan
                DataCell(
                  InkWell(
                    onTap: () {
                      if (!controller.isSelectionMode.value) {
                        DetailPusatLokasiModal.show(context, item);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        item.keterangan ?? '-',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),
                // Aksi
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Detail
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.visibility,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                        onPressed: () {
                          DetailPusatLokasiModal.show(context, item);
                        },
                        tooltip: 'Detail',
                      ),
                      // Edit
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                        onPressed: () {
                          EditPusatLokasiModal.show(context, controller, item);
                        },
                        tooltip: 'Edit',
                      ),
                      // Hapus
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
                        onPressed: () {
                          _showDeleteConfirmation(context, controller, item);
                        },
                        tooltip: 'Hapus',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PusatLokasiController controller,
    PusatLokasiModel item,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Hapus Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus lokasi "${item.namaLokasi}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.deletePusatLokasi(item.id);
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
}
