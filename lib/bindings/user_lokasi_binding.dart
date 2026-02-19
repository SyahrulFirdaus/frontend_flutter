// lib/bindings/user_lokasi_binding.dart
import 'package:get/get.dart';
import '../controllers/user_lokasi_controller.dart';

class UserLokasiBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load UserLokasiController hanya ketika dibutuhkan
    Get.lazyPut<UserLokasiController>(
      () => UserLokasiController(),
      fenix: true,
    );
  }
}
