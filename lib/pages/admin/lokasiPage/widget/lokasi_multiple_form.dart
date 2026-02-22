// lib/pages/admin/widgets/lokasi/lokasi_multiple_form.dart

import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/admin/lokasiPage/modals/lokasi_helpers.dart';
import 'package:get/get.dart';
import '../../../../controllers/lokasi_controller.dart';
import 'lokasi_entry_item.dart';

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
            const SizedBox(height: 8),
            _buildInfoBox(),
            const SizedBox(height: 16),
            _buildUserDropdown(),
            const SizedBox(height: 20),
            _buildEntriesHeader(),
            const SizedBox(height: 12),
            _buildEntriesList(),
            const SizedBox(height: 8),
            _buildAddEntryButton(),
            const Divider(height: 32),
            _buildSubmitButton(),
            if (controller.multipleLokasiEntries.isNotEmpty)
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
          'Tambah Lokasi (Multiple)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
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
    );
  }

  Widget _buildUserDropdown() {
    return Obx(() {
      if (controller.users.isEmpty) {
        return _buildEmptyUsers();
      }

      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Pilih User',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        onChanged: (v) => controller.selectedUserForMultiple.value = v ?? '',
      );
    });
  }

  Widget _buildEmptyUsers() {
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

  Widget _buildEntriesHeader() {
    return Obx(() {
      final totalEntries = controller.multipleLokasiEntries.length;
      final validEntries = LokasiHelpers.getValidEntriesCount(controller);

      return Row(
        children: [
          const Text(
            'Entries',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          ),
          const SizedBox(width: 8),
          Text(
            'Total: $totalEntries',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    });
  }

  Widget _buildEntriesList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.multipleLokasiEntries.length,
        itemBuilder: (context, index) {
          return LokasiEntryItem(index: index, controller: controller);
        },
      ),
    );
  }

  Widget _buildAddEntryButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add_circle, color: Colors.green),
        label: const Text(
          'Tambah Entry Lagi',
          style: TextStyle(color: Colors.green),
        ),
        onPressed: controller.addNewLokasiEntry,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isValid =
          controller.multipleLokasiEntries.isNotEmpty &&
          controller.selectedUserForMultiple.value.isNotEmpty;
      final validCount = LokasiHelpers.getValidEntriesCount(controller);

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save_alt),
          label: Text(
            controller.isLoading.value
                ? 'Menyimpan...'
                : 'Simpan Semua ($validCount dari ${controller.multipleLokasiEntries.length} entry)',
          ),
          onPressed: (isValid && validCount > 0 && !controller.isLoading.value)
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
        ),
      );
    });
  }

  Widget _buildResetButton() {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.clear_all, color: Colors.red),
          label: const Text('Reset Semua', style: TextStyle(color: Colors.red)),
          onPressed: controller.resetMultipleForm,
        ),
      ],
    );
  }
}
