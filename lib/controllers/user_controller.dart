import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_controller.dart';

class UserController extends GetxController {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  var users = <UserModel>[].obs;
  var isLoading = false.obs;

  final AuthController authController = Get.find<AuthController>();

  Map<String, String> get _authHeaders => {
    'Accept': 'application/json',
    'Authorization': 'Bearer ${authController.token}',
  };

  // ================= GET USERS (ADMIN) =================
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      final res = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _authHeaders,
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        users.value = (json['data'] as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar('Error', 'Gagal mengambil data user');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= REGISTER USER / ADMIN =================
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading.value = true;

      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back();
        Get.snackbar('Sukses', 'User berhasil didaftarkan');
        fetchUsers();
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Error', err['message'] ?? 'Register gagal');
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
      final res = await http.delete(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: _authHeaders,
      );

      if (res.statusCode == 200) {
        Get.snackbar('Sukses', 'User berhasil dihapus');
        fetchUsers();
      } else {
        Get.snackbar('Error', 'Gagal menghapus user');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
