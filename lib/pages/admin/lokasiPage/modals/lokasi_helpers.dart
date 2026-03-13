import '../../../../controllers/lokasi_controller.dart';

class LokasiHelpers {
  static int getValidEntriesCount(LokasiController controller) {
    return controller.multipleLokasiEntries.where((entry) {
      final lokasi = entry['lokasi']?.value ?? '';
      final koordinat = entry['koordinat']?.value ?? '';
      return lokasi.isNotEmpty && koordinat.isNotEmpty;
    }).length;
  }
}
