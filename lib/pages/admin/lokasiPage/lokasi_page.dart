import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../controllers/lokasi_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../master_drawer.dart';
import 'widget/lokasi_multiple_form.dart';
import 'widget/lokasi_table_widget.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  // INISIALISASI CONTROLLER
  late final LokasiController controller;

  // Untuk tab view
  final RxInt selectedTabIndex = 0.obs;

  // Untuk preview map
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    // PUT CONTROLLER SAAT HALAMAN DIBUKA
    controller = Get.put(LokasiController());
    print('🟢 LokasiPage initialized with controller');
  }

  @override
  void dispose() {
    // HAPUS CONTROLLER SAAT HALAMAN DITUTUP (opsional, bisa dihapus jika ingin permanen)
    // Get.delete<LokasiController>();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Lokasi User'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(icon: Icon(Icons.library_add), text: 'Multiple Entry')],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.fetchLokasi();
                controller.fetchUsers();
                Get.snackbar(
                  'Info',
                  'Data sedang diperbarui',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 1),
                );
              },
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        drawer: const MasterDrawer(currentPage: 'lokasi'),
        body: Obx(() {
          // CEK TOKEN
          if (auth.token.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Silahkan login terlebih dahulu',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // CEK LOADING STATE
          if (controller.isUserLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data user...'),
                ],
              ),
            );
          }

          // TAMPILKAN CONTENT
          return const TabBarView(children: [_LokasiContent()]);
        }),
      ),
    );
  }
}

// ========== CONTENT WIDGET ==========
class _LokasiContent extends StatelessWidget {
  const _LokasiContent();

  @override
  Widget build(BuildContext context) {
    // PASTIKAN CONTROLLER SUDAH ADA
    final controller = Get.find<LokasiController>();

    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchLokasi();
        await controller.fetchUsers();
      },
      color: Colors.blue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FORM MULTIPLE ENTRY
            const LokasiMultipleForm(),
            const SizedBox(height: 16),

            // TABEL LOKASI
            const LokasiTableWidget(),

            // EXTRA SPACE
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ========== HELPER FUNCTIONS (untuk digunakan di widget lain) ==========
extension LokasiPageHelper on LokasiController {
  int getValidEntriesCount() {
    return multipleLokasiEntries.where((entry) {
      final lokasi = entry['lokasi']?.value ?? '';
      final koordinat = entry['koordinat']?.value ?? '';
      return lokasi.isNotEmpty && koordinat.isNotEmpty;
    }).length;
  }

  void hapusLokasi(int id, String lokasi) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Hapus Lokasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus lokasi "$lokasi"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              this.deleteLokasi(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
