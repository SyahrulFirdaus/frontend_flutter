import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/pusat_lokasi_controller.dart';

class PusatLokasiSearchBar extends StatelessWidget {
  const PusatLokasiSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PusatLokasiController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.search,
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan nama atau keterangan...',
            prefixIcon: const Icon(Icons.search, color: Colors.blue),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        controller.search('');
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
