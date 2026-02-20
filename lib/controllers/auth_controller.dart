import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final box = GetStorage();
  // final String baseUrl = 'http://10.0.2.2:8000/api';
  final String baseUrl = 'http://192.168.137.1:8000/api';

  var isLoading = false.obs;
  var token = ''.obs;
  var user = {}.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data login lama (auto login)
    token.value = box.read('token') ?? '';
    user.value = box.read('user') ?? {};

    // Debug
    print('🔍 AuthController initialized');
    print('📦 Token from storage: ${token.value.isNotEmpty ? "Yes" : "No"}');
    print('👤 User from storage: ${user.value}');
    print('👑 Is Admin: $isAdmin');
  }

  // ================= REGISTER =================
  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    isLoading.value = true;
    try {
      print('📝 Register attempt: $name, $email, $role');

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tampilkan snackbar sukses
        Get.snackbar(
          '✅ Berhasil',
          data['message'] ?? 'Register berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Redirect ke halaman login setelah register berhasil
        Get.offAllNamed('/login');
      } else {
        String errorMessage = data['message'] ?? 'Register gagal';

        // Tampilkan error validasi jika ada
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first;
          }
        }

        Get.snackbar(
          '❌ Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Register error: $e');
      Get.snackbar(
        'Error',
        'Koneksi error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      print('🔐 Login attempt: $email');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        token.value = data['access_token'];
        user.value = data['user'];

        // Simpan ke storage
        box.write('token', token.value);
        box.write('user', user.value);

        Get.snackbar(
          '✅ Berhasil',
          'Login berhasil sebagai ${user['role']}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Redirect sesuai role
        if (isAdmin) {
          Get.offAllNamed('/admin');
        } else {
          Get.offAllNamed('/user');
        }
      } else {
        String errorMessage = data['message'] ?? 'Login gagal';

        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first;
          }
        }

        Get.snackbar(
          '❌ Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
      Get.snackbar(
        'Error',
        'Koneksi error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      if (token.isNotEmpty) {
        print('📤 Logout attempt');
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer ${token.value}',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear data
      token.value = '';
      user.value = {};
      box.erase();

      // Force close semua controller
      Get.deleteAll();

      Get.offAllNamed('/login');

      Get.snackbar(
        '✅ Berhasil',
        'Berhasil logout',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ================= GETTERS =================
  bool get isLoggedIn => token.isNotEmpty;

  bool get isAdmin {
    if (user.isEmpty) return false;
    return user['role'] == 'admin';
  }

  bool get isUser {
    if (user.isEmpty) return false;
    return user['role'] == 'user';
  }

  String get userName {
    if (user.isEmpty) return '';
    return user['name'] ?? '';
  }

  String get userEmail {
    if (user.isEmpty) return '';
    return user['email'] ?? '';
  }

  String get userRole {
    if (user.isEmpty) return '';
    return user['role'] ?? '';
  }

  // ================= DEBUG =================
  void printDebugInfo() {
    print('=' * 50);
    print('🔍 AUTH CONTROLLER DEBUG');
    print('Token: ${token.value.isNotEmpty ? "Yes" : "No"}');
    print('User: $user');
    print('Is Admin: $isAdmin');
    print('Is User: $isUser');
    print('=' * 50);
  }
}
