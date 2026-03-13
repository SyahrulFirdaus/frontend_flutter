import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/lokasi_controller.dart';

class LokasiMultipleForm extends GetView<LokasiController> {
  const LokasiMultipleForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildUserDropdown(),
            const SizedBox(height: 24),

            _buildTabSection(),

            const SizedBox(height: 24),

            _buildSubmitButton(),

            if (controller.selectedPusatLokasiIds.isNotEmpty ||
                controller.multipleLokasiEntries.length > 1)
              _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
          'Tambah Lokasi ke User',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildUserDropdown() {
    return Obx(() {
      if (controller.users.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Pilih User *',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            prefixIcon: const Icon(Icons.person, color: Colors.blue),
          ),
          value: controller.selectedUserForMultiple.value.isEmpty
              ? null
              : controller.selectedUserForMultiple.value,
          items: controller.users.map((u) {
            return DropdownMenuItem<String>(
              value: u['id'].toString(),
              child: Text(
                u['name'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: (v) {
            controller.selectedUserForMultiple.value = v ?? '';
            controller.fetchPusatLokasi();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih user terlebih dahulu';
            }
            return null;
          },
        ),
      );
    });
  }

  Widget _buildTabSection() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Pilih dari Pusat'),
                Tab(text: 'Input Manual'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 450, // Tinggi tetap untuk tab content
            child: TabBarView(
              children: [
                _buildPusatLokasiGrid(), // UBAH KE GRID 2 KOLOM
                _buildManualEntryList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== GRID 2 KOLOM UNTUK PUSAT LOKASI ==========
  Widget _buildPusatLokasiGrid() {
    return Obx(() {
      if (controller.pusatLokasis.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Belum ada data pusat lokasi',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan pusat lokasi terlebih dahulu',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location),
                label: const Text('Buka Pusat Lokasi'),
                onPressed: () {
                  Get.toNamed('/admin/pusat-lokasi');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Header dengan Select All
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Pusat Lokasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: controller.toggleSelectAllPusatLokasi,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        controller.selectedPusatLokasiIds.length ==
                                controller.pusatLokasis.length
                            ? 'Unselect All'
                            : 'Select All',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.selectedPusatLokasiIds.length}/${controller.pusatLokasis.length}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // GRID VIEW 2 KOLOM
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: controller.pusatLokasis.length,
              itemBuilder: (context, index) {
                final item = controller.pusatLokasis[index];
                final isSelected = controller.selectedPusatLokasiIds.contains(
                  item['id'],
                );

                return _buildGridItem(item, isSelected, index);
              },
            ),
          ),
        ],
      );
    });
  }

  // ========== ITEM GRID ==========
  Widget _buildGridItem(Map<String, dynamic> item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => controller.togglePusatLokasiItem(item['id']),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox indikator
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['nama_lokasi'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Koordinat
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 10,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          _shortenKoordinat(item['titik_kordinat']),
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Keterangan (jika ada)
                  if (item['keterangan'] != null &&
                      item['keterangan'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 8,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              _shortenText(item['keterangan'], 30),
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== HELPER ==========
  String _shortenKoordinat(String koordinat) {
    final parts = koordinat.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      }
    }
    return koordinat.length > 25
        ? '${koordinat.substring(0, 22)}...'
        : koordinat;
  }

  String _shortenText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  Widget _buildManualEntryList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: controller.multipleLokasiEntries.length,
        itemBuilder: (context, index) {
          return _ManualEntryItem(index: index, controller: controller);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final hasPusatSelection = controller.selectedPusatLokasiIds.isNotEmpty;
      final hasManualEntries = controller.multipleLokasiEntries.any((entry) {
        final lokasi = entry['lokasi']?.value ?? '';
        final koordinat = entry['koordinat']?.value ?? '';
        return lokasi.isNotEmpty && koordinat.isNotEmpty;
      });
      final hasUser = controller.selectedUserForMultiple.value.isNotEmpty;

      final isValid = (hasPusatSelection || hasManualEntries) && hasUser;

      final pusatCount = controller.selectedPusatLokasiIds.length;
      final manualCount = controller.multipleLokasiEntries.where((entry) {
        final lokasi = entry['lokasi']?.value ?? '';
        final koordinat = entry['koordinat']?.value ?? '';
        return lokasi.isNotEmpty && koordinat.isNotEmpty;
      }).length;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save_alt),
          label: Text(
            controller.isLoading.value
                ? 'Menyimpan...'
                : 'Simpan (Pusat: $pusatCount, Manual: $manualCount)',
          ),
          onPressed: isValid && !controller.isLoading.value
              ? () {
                  if (pusatCount > 0) {
                    controller.submitMultipleLokasiFromPusat();
                  } else if (manualCount > 0) {
                    controller.submitMultipleLokasiManual();
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton.icon(
        icon: const Icon(Icons.clear_all, color: Colors.red),
        label: const Text('Reset Semua', style: TextStyle(color: Colors.red)),
        onPressed: controller.resetMultipleForm,
      ),
    );
  }
}

class _ManualEntryItem extends StatelessWidget {
  final int index;
  final LokasiController controller;

  const _ManualEntryItem({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entry = controller.multipleLokasiEntries[index];
      final lokasi = entry['lokasi'] as RxString;
      final koordinat = entry['koordinat'] as RxString;
      final isValid = entry['isValid'] as RxBool;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isValid.value ? Colors.green.shade200 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
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
                    ),
                  ),
                ),
                if (controller.multipleLokasiEntries.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => controller.removeLokasiEntry(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                prefixIcon: const Icon(Icons.place, size: 18),
              ),
              onChanged: (value) {
                controller.updateLokasiEntry(index, 'lokasi', value);
              },
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
                prefixIcon: const Icon(Icons.location_on, size: 18),
                hintText: 'Contoh: -6.893361, 107.602376',
              ),
              onChanged: (value) {
                controller.updateLokasiEntry(index, 'koordinat', value);
              },
            ),
          ],
        ),
      );
    });
  }
}
