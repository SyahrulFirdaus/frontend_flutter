import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_controller.dart';

class UserController extends GetxController {
  // final String baseUrl = 'http://10.0.2.2:8000/api';
  final String baseUrl = 'http://192.168.137.1:8000/api';

  var users = <UserModel>[].obs;
  var isLoading = false.obs;

  final AuthController authController = Get.find<AuthController>();

  Map<String, String> get _authHeaders => {
    'Accept': 'application/json',
    'Authorization':
        'Bearer ${authController.token.value}', // Perbaikan: .value
  };

  // ================= GET USERS (ADMIN) =================
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      // Cek token
      if (authController.token.isEmpty) {
        Get.snackbar(
          'Error',
          'Anda harus login sebagai admin',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final res = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _authHeaders,
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        users.value = (json['data'] as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        Get.snackbar(
          'Sesi Habis',
          'Silahkan login kembali',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        authController.logout();
      } else {
        Get.snackbar('Error', 'Gagal mengambil data user');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= REGISTER USER (Hanya untuk admin) =================
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading.value = true;

      // CEK TOKEN - Pastikan admin sudah login
      if (authController.token.isEmpty) {
        Get.snackbar(
          'Error',
          'Anda harus login sebagai admin',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('🔐 Register user dengan token: ${authController.token.value}');
      print('👤 User yang login: ${authController.user}');

      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${authController.token.value}', // TAMBAHKAN INI!
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      print('📨 Response status: ${res.statusCode}');
      print('📨 Response body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back();
        Get.snackbar(
          '✅ Berhasil',
          'User $name berhasil didaftarkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchUsers();
      } else {
        final err = jsonDecode(res.body);

        // Cek khusus untuk error otorisasi
        if (res.statusCode == 401 || res.statusCode == 403) {
          Get.snackbar(
            'Error',
            err['message'] ??
                'Anda tidak memiliki izin. Pastikan Anda login sebagai admin.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            err['message'] ?? 'Register gagal',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DELETE USER =================
  Future<void> deleteUser(int id) async {
    try {
      isLoading.value = true;

      // CEK TOKEN
      if (authController.token.isEmpty) {
        Get.snackbar(
          'Error',
          'Anda harus login sebagai admin',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final res = await http.delete(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: _authHeaders,
      );

      if (res.statusCode == 200) {
        Get.snackbar(
          '✅ Berhasil',
          'User berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchUsers();
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar(
          'Error',
          err['message'] ?? 'Gagal menghapus user',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
