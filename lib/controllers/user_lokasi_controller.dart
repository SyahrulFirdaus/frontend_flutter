// lib/controllers/user_lokasi_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';

class UserLokasiController extends GetxController {
  final auth = Get.find<AuthController>();

  final String baseUrl = 'http://10.0.2.2:8000/api';

  var userLokasis = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Tunggu sampai token tersedia
    ever(auth.token, (_) {
      if (auth.token.isNotEmpty) {
        fetchUserLokasi();
      }
    });

    if (auth.token.isNotEmpty) {
      fetchUserLokasi();
    }
  }

  Map<String, String> get _authHeaders => {
    'Accept': 'application/json',
    'Authorization': 'Bearer ${auth.token}',
    'Content-Type': 'application/json',
  };

  Future<void> fetchUserLokasi() async {
    if (auth.token.isEmpty) {
      errorMessage.value = 'Token tidak ditemukan';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 Fetching user lokasi...');
      print('📌 Token: ${auth.token.substring(0, 20)}...');
      print('📌 User role: ${auth.user['role']}');

      final url = Uri.parse('$baseUrl/user/lokasi');
      print('📌 URL: $url');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      print('📌 Response status: ${response.statusCode}');
      print('📌 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        print('📌 Data type: ${data.runtimeType}');

        if (data is List) {
          userLokasis.value = List<Map<String, dynamic>>.from(data);
          print('✅ Berhasil memuat ${userLokasis.length} lokasi');
        } else {
          userLokasis.value = [];
          errorMessage.value = 'Format data tidak sesuai';
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Sesi habis, silahkan login ulang';
        auth.logout();
      } else if (response.statusCode == 403) {
        errorMessage.value = 'Akses ditolak - Bukan role user';
      } else if (response.statusCode == 404) {
        errorMessage.value = 'Endpoint tidak ditemukan';
      } else {
        errorMessage.value = 'Error ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Error fetchUserLokasi: $e');
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitAbsensi(String lokasiId, String lokasiNama) async {
    try {
      print('📤 Submitting absensi...');
      print('📍 Lokasi ID: $lokasiId');

      final response = await http.post(
        Uri.parse('$baseUrl/user/absensi'),
        headers: _authHeaders,
        body: jsonEncode({'lokasi_id': int.parse(lokasiId)}),
      );

      print('📌 Response status: ${response.statusCode}');
      print('📌 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Error submitAbsensi: $e');
      return false;
    }
  }
}
