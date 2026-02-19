import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/lokasi_controller.dart';
import '../../controllers/auth_controller.dart';
import 'master_drawer.dart';

class LokasiPage extends GetView<LokasiController> {
  LokasiPage({super.key});

  // Untuk tab view
  final RxInt selectedTabIndex = 0.obs;

  // Untuk preview map
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return DefaultTabController(
      length: 1, // Hanya 1 tab karena single entry dihapus
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Lokasi'),
          bottom: const TabBar(
            tabs: [Tab(icon: Icon(Icons.library_add), text: 'Multiple Entry')],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.fetchLokasi();
                controller.fetchUsers();
              },
            ),
          ],
        ),
        drawer: const MasterDrawer(currentPage: 'lokasi'),
        body: Obx(() {
          if (auth.token.isEmpty) {
            return const Center(child: Text('Silahkan login terlebih dahulu'));
          }

          if (controller.isUserLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return const TabBarView(
            children: [
              // Hanya Multiple Entry Tab
              _MultipleEntryTab(),
            ],
          );
        }),
      ),
    );
  }

  // ========== HELPER FUNCTIONS ==========
  int _getValidEntriesCount() {
    return controller.multipleLokasiEntries.where((entry) {
      final lokasi = entry['lokasi']?.value ?? '';
      final koordinat = entry['koordinat']?.value ?? '';
      return lokasi.isNotEmpty && koordinat.isNotEmpty;
    }).length;
  }

  void _hapusLokasi(int id, String lokasi) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Lokasi'),
        content: Text('Yakin ingin menghapus lokasi "$lokasi"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteLokasi(id);
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
}

// ========== MULTIPLE ENTRY TAB ==========
class _MultipleEntryTab extends GetView<LokasiController> {
  const _MultipleEntryTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchLokasi();
        await controller.fetchUsers();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMultipleFormCard(),
            const SizedBox(height: 16),
            _buildTableLokasi(),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleFormCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.library_add, color: Colors.green),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tambah Lokasi (Multiple)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tambahkan beberapa lokasi sekaligus untuk user yang sama',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown User untuk multiple
            Obx(() {
              if (controller.users.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Tidak ada user dengan role user',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Data User'),
                        onPressed: controller.fetchUsers,
                      ),
                    ],
                  ),
                );
              }

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pilih User',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '-- Pilih User --',
                  prefixIcon: const Icon(Icons.person),
                ),
                value: controller.selectedUserForMultiple.value.isEmpty
                    ? null
                    : controller.selectedUserForMultiple.value,
                items: controller.users.map((u) {
                  return DropdownMenuItem<String>(
                    value: u['id'].toString(),
                    child: Text(u['name']),
                  );
                }).toList(),
                onChanged: (v) =>
                    controller.selectedUserForMultiple.value = v ?? '',
              );
            }),

            const SizedBox(height: 20),

            // Header entries
            Row(
              children: [
                const Text(
                  'Entries',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Obx(() {
                  final totalEntries = controller.multipleLokasiEntries.length;
                  final validEntries = _getValidEntriesCount();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: validEntries == totalEntries && totalEntries > 0
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$validEntries/$totalEntries valid',
                      style: TextStyle(
                        color: validEntries == totalEntries && totalEntries > 0
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  'Total: ${controller.multipleLokasiEntries.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of multiple entries
            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.multipleLokasiEntries.length,
                itemBuilder: (context, index) {
                  return _buildMultipleEntryItem(index);
                },
              ),
            ),

            const SizedBox(height: 8),

            // Tombol tambah entry
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                label: const Text(
                  'Tambah Entry Lagi',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: controller.addNewLokasiEntry,
              ),
            ),

            const Divider(height: 32),

            // Tombol submit all
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final isValid =
                    controller.multipleLokasiEntries.isNotEmpty &&
                    controller.selectedUserForMultiple.value.isNotEmpty;
                final validCount = _getValidEntriesCount();

                return ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: Text(
                    controller.isLoading.value
                        ? 'Menyimpan...'
                        : 'Simpan Semua ($validCount dari ${controller.multipleLokasiEntries.length} entry)',
                  ),
                  onPressed:
                      (isValid && validCount > 0 && !controller.isLoading.value)
                      ? controller.submitMultipleLokasi
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),

            if (controller.multipleLokasiEntries.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.clear_all, color: Colors.red),
                label: const Text(
                  'Reset Semua',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: controller.resetMultipleForm,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleEntryItem(int index) {
    return Obx(() {
      final entry = controller.multipleLokasiEntries[index];
      final lokasi = entry['lokasi'] as RxString;
      final koordinat = entry['koordinat'] as RxString;
      final isValid = entry['isValid'] as RxBool;

      // Parse koordinat untuk map preview
      LatLng? mapLocation;
      if (koordinat.value.isNotEmpty) {
        try {
          final parts = koordinat.value.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null) {
              mapLocation = LatLng(lat, lng);
            }
          }
        } catch (e) {
          print('Error parsing koordinat: $e');
        }
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isValid.value ? Colors.green.shade200 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isValid.value ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isValid.value ? 'Entry Valid' : 'Belum Lengkap',
                      style: TextStyle(
                        color: isValid.value ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (controller.multipleLokasiEntries.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => controller.removeLokasiEntry(index),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: TextEditingController(text: lokasi.value),
                decoration: InputDecoration(
                  labelText: 'Lokasi ${index + 1}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  prefixIcon: const Icon(Icons.place, size: 20),
                ),
                onChanged: (value) =>
                    controller.updateLokasiEntry(index, 'lokasi', value),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: TextEditingController(text: koordinat.value),
                decoration: InputDecoration(
                  labelText: 'Koordinat ${index + 1}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  prefixIcon: const Icon(Icons.location_on, size: 20),
                  hintText: 'Contoh: -6.893361, 107.602376',
                ),
                onChanged: (value) =>
                    controller.updateLokasiEntry(index, 'koordinat', value),
              ),

              // Preview Map jika koordinat valid
              if (mapLocation != null) ...[
                const SizedBox(height: 12),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: mapLocation,
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('preview_$index'),
                          position: mapLocation,
                          infoWindow: InfoWindow(
                            title: lokasi.value.isEmpty
                                ? 'Lokasi ${index + 1}'
                                : lokasi.value,
                          ),
                        ),
                      },
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      gestureRecognizers: const {},
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ========== TABEL LOKASI ==========
  Widget _buildTableLokasi() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.lokasis.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Belum ada data lokasi',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan lokasi menggunakan form di atas',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Daftar Lokasi Tersimpan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Total: ${controller.lokasis.length}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Table untuk tampilan desktop/tablet
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Colors.blue.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Lokasi')),
                    DataColumn(label: Text('Koordinat')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: List.generate(controller.lokasis.length, (i) {
                    final item = controller.lokasis[i];
                    return DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(item.user)),
                        DataCell(
                          Tooltip(
                            message: item.lokasi,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                item.lokasi,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Tooltip(
                            message: item.koordinat,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                item.koordinat,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusLokasi(item.id, item.lokasi),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            } else {
              // List view untuk mobile
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.lokasis.length,
                itemBuilder: (context, i) {
                  final item = controller.lokasis[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${i + 1}'),
                      ),
                      title: Text(item.lokasi),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User: ${item.user}'),
                          Text('Koordinat: ${item.koordinat}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusLokasi(item.id, item.lokasi),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  int _getValidEntriesCount() {
    return controller.multipleLokasiEntries.where((entry) {
      final lokasi = entry['lokasi']?.value ?? '';
      final koordinat = entry['koordinat']?.value ?? '';
      return lokasi.isNotEmpty && koordinat.isNotEmpty;
    }).length;
  }

  void _hapusLokasi(int id, String lokasi) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Lokasi'),
        content: Text('Yakin ingin menghapus lokasi "$lokasi"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteLokasi(id);
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
}
