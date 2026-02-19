// lib/pages/user/riwayat_absensi_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_lokasi_controller.dart';
import '../../controllers/auth_controller.dart';

class RiwayatAbsensiPage extends StatelessWidget {
  const RiwayatAbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserLokasiController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchRiwayatAbsensi();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingRiwayat.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.riwayatAbsensi.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat absensi',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silahkan melakukan absensi terlebih dahulu',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: () {
                    controller.fetchRiwayatAbsensi();
                  },
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.riwayatAbsensi.length,
          itemBuilder: (context, index) {
            final item = controller.riwayatAbsensi[index];
            String lokasi = '';
            String koordinat = '';
            String waktu = '';

            // Handle berbagai format response
            if (item['lokasi'] is Map) {
              lokasi = item['lokasi']['lokasi'] ?? '-';
              koordinat = item['lokasi']['koordinat'] ?? '-';
            } else {
              lokasi = item['lokasi']?.toString() ?? '-';
              koordinat = item['koordinat']?.toString() ?? '-';
            }

            if (item['waktu_absen'] != null) {
              waktu = item['waktu_absen'].toString().substring(0, 16);
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                title: Text(
                  lokasi,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Koordinat: $koordinat',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Waktu: $waktu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
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
}
