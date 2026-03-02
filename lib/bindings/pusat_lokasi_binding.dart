import 'package:get/get.dart';
import '../controllers/pusat_lokasi_controller.dart';

class PusatLokasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PusatLokasiController>(
      () => PusatLokasiController(),
      fenix: true,
    );
  }
}
