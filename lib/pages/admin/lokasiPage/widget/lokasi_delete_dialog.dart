import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/lokasi_controller.dart';

class LokasiDeleteDialog {
  static void show({
    required BuildContext context,
    required int id,
    required String lokasi,
    required LokasiController controller,
  }) {
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
