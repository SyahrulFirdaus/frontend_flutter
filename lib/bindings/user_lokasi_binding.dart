import 'package:get/get.dart';
import '../controllers/user_lokasi_controller.dart';

class UserLokasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserLokasiController>(
      () => UserLokasiController(),
      fenix: true,
    );
  }
}
