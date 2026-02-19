import 'package:flutter/material.dart';
import 'package:frontend_flutter/controllers/auth_controller.dart';
import 'package:frontend_flutter/controllers/user_controller.dart';
import 'package:frontend_flutter/pages/admin/list_akun.dart';
import 'package:get/get.dart';

void main() {
  Get.put(AuthController());
  Get.put(UserController());

  runApp(const AdminMainApp());
}

class AdminMainApp extends StatelessWidget {
  const AdminMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ListAkunPage(),
    );
  }
}
