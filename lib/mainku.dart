import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/initial_binding.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/admin/listAkun/list_akun.dart';
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

        GetPage(name: '/admin', page: () => const ListAkunPage()),
      ],
    );
  }

  String _getInitialRoute() {
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();

      if (auth.isLoggedIn) {
        if (auth.isAdmin) {
          return '/admin';
        } else {
          return '/user';
        }
      }
    }

    return '/login';
  }
}
