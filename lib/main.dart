import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_binding.dart';
import 'bindings/user_lokasi_binding.dart';
import 'bindings/lokasi_binding.dart';
import 'bindings/pusat_lokasi_binding.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/admin/listAkun/list_akun.dart';
import 'pages/admin/lokasiPage/lokasi_page.dart';
import 'pages/admin/pusatLokasi/pusat_lokasi_page.dart';
import 'pages/admin/riwayatSemuaUserPage/riwayat_semua_user_page.dart';
import 'pages/user/userPage/user_page.dart';
import 'pages/user/riwayatAbsensiPage/riwayat_absensi_page.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Absensi App',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: _getInitialRoute(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),

        // ===== ADMIN ROUTES =====
        GetPage(name: '/admin', page: () => const ListAkunPage()),

        GetPage(
          name: '/admin/lokasi',
          page: () => LokasiPage(),
          binding: LokasiBinding(),
        ),

        GetPage(
          name: '/admin/pusat-lokasi',
          page: () => const PusatLokasiPage(),
          binding: PusatLokasiBinding(),
        ),

        // Tambahkan route untuk riwayat semua user
        // GetPage(
        //   name: '/admin/riwayat-semua',
        //   page: () => const RiwayatSemuaUserPage(),
        //   binding: AdminAbsensiBinding(),
        // ),

        // ===== USER ROUTES =====
        GetPage(
          name: '/user',
          page: () => const UserPage(),
          binding: UserLokasiBinding(),
        ),

        GetPage(name: '/user/riwayat', page: () => const RiwayatAbsensiPage()),
      ],
    );
  }

  String _getInitialRoute() {
    // Cek apakah AuthController sudah terdaftar
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();

      // Jika sudah login
      if (auth.isLoggedIn) {
        // Redirect sesuai role
        if (auth.isAdmin) {
          return '/admin';
        } else {
          return '/user';
        }
      }
    }
    // Jika belum login
    return '/login';
  }
}
