// lib/pages/admin/widgets/lokasi/lokasi_helpers.dart

import 'package:get/get.dart';
import '../../../../controllers/lokasi_controller.dart';

class LokasiHelpers {
  // Hitung jumlah entry yang valid
  static int getValidEntriesCount(LokasiController controller) {
    return controller.multipleLokasiEntries.where((entry) {
      final lokasi = entry['lokasi']?.value ?? '';
      final koordinat = entry['koordinat']?.value ?? '';
      return lokasi.isNotEmpty && koordinat.isNotEmpty;
    }).length;
  }
}
