import 'package:flutter/material.dart';
import 'package:frontend_flutter/bindings/pusat_lokasi_binding.dart';
import 'package:frontend_flutter/pages/admin/pusatLokasi/pusat_lokasi_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_binding.dart';
import 'bindings/user_lokasi_binding.dart';
import 'bindings/lokasi_binding.dart'; // <<< TAMBAHKAN IMPORT INI
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/admin/listAkun/list_akun.dart';
import 'pages/admin/lokasiPage/lokasi_page.dart'; // <<< TAMBAHKAN IMPORT INI
import 'pages/user/userPage/user_page.dart';
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
      title: 'Flutter Auth Role',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: _getInitialRoute(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/admin', page: () => const ListAkunPage()),

        // <<< TAMBAHKAN ROUTE UNTUK LOKASI USER >>>
        GetPage(
          name: '/admin/lokasi',
          page: () => LokasiPage(),
          binding: LokasiBinding(),
        ),

        GetPage(
          name: '/user',
          page: () => const UserPage(),
          binding: UserLokasiBinding(),
        ),
        GetPage(
          name: '/admin/pusat-lokasi',
          page: () => const PusatLokasiPage(),
          binding: PusatLokasiBinding(),
        ),
      ],
    );
  }

  String _getInitialRoute() {
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn) {
        return auth.isAdmin ? '/admin' : '/user';
      }
    }
    return '/login';
  }
}
