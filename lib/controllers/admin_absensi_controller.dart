// lib/controllers/admin_absensi_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';

class AdminAbsensiController extends GetxController {
  final auth = Get.find<AuthController>();

  // final String baseUrl = 'http://10.0.2.2:8000/api';
  final String baseUrl = 'http://192.168.1.9:8000/api';

  var semuaAbsensi = <Map<String, dynamic>>[].obs;
  var semuaUsers = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isLoadingUsers = false.obs;
  var errorMessage = ''.obs;

  // Filter
  var selectedUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🟢 AdminAbsensiController diinisialisasi');
  }

  // ================= AMBIL SEMUA USER =================
  Future<void> fetchAllUsers() async {
    if (auth.token.isEmpty) {
      errorMessage.value = 'Token tidak ditemukan';
      return;
    }

    isLoadingUsers.value = true;

    try {
      print('📌 Fetching all users from: $baseUrl/admin/users/all');

      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/users/all'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📨 Response users status: ${response.statusCode}');
      print('📨 Response users body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          semuaUsers.value = List<Map<String, dynamic>>.from(data['data']);
          print('✅ Users ditemukan: ${semuaUsers.length} data');

          if (semuaUsers.isEmpty) {
            print('⚠️ Tidak ada user dengan role "user" di database');
          } else {
            print('📋 Daftar user:');
            for (var user in semuaUsers) {
              print('   - ${user['id']}: ${user['name']}');
            }
          }
        } else {
          semuaUsers.value = [];
          print('❌ Format response tidak sesuai: ${data}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Sesi habis, silahkan login ulang';
        Get.snackbar(
          'Sesi Habis',
          'Silahkan login ulang',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Future.delayed(const Duration(seconds: 2), () => auth.logout());
      } else {
        print('❌ Error fetch users: ${response.statusCode} - ${response.body}');
        errorMessage.value = 'Gagal memuat data users';
      }
    } catch (e) {
      print('❌ Error fetch users: $e');
      errorMessage.value = 'Gagal memuat data users';
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // ================= AMBIL SEMUA ABSENSI =================
  Future<void> fetchAllAbsensi() async {
    if (auth.token.isEmpty) {
      errorMessage.value = 'Token tidak ditemukan';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('📌 Fetching all absensi...');

      // Build URL dengan filter user (opsional)
      String url = '$baseUrl/admin/absensi/all';

      if (selectedUserId.value.isNotEmpty) {
        url = '$url?user_id=${selectedUserId.value}';
      }

      print('📌 URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('📨 Response absensi status: ${response.statusCode}');
      print('📨 Response absensi body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          semuaAbsensi.value = List<Map<String, dynamic>>.from(data['data']);
          print('✅ Absensi ditemukan: ${semuaAbsensi.length} data');
        } else {
          semuaAbsensi.value = [];
          print('❌ Format response tidak sesuai: ${data}');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Sesi habis, silahkan login ulang';
        Get.snackbar(
          'Sesi Habis',
          'Silahkan login ulang',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Future.delayed(const Duration(seconds: 2), () => auth.logout());
      } else {
        errorMessage.value = 'Error ${response.statusCode}';
        print(
          '❌ Error fetch absensi: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetch absensi: $e');
      errorMessage.value = 'Gagal memuat data absensi';
    } finally {
      isLoading.value = false;
    }
  }

  // ================= FILTER BERDASARKAN USER =================
  void filterByUser(String userId) {
    selectedUserId.value = userId;
    fetchAllAbsensi();
  }

  // ================= RESET FILTER =================
  void resetFilter() {
    selectedUserId.value = '';
    fetchAllAbsensi(); // Ambil semua data tanpa filter
  }

  // ================= GET USER NAME BY ID =================
  String getUserNameById(int userId) {
    try {
      final user = semuaUsers.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => {'name': 'Unknown User'},
      );
      return user['name'] ?? 'Unknown User';
    } catch (e) {
      print('Error get user name: $e');
      return 'Unknown User';
    }
  }

  // ================= FORMAT WAKTU =================
  String formatWaktu(String waktuStr) {
    try {
      if (waktuStr.isEmpty) return '-';

      // Handle format ISO: "2026-02-20T03:22:00.000Z"
      if (waktuStr.contains('T')) {
        final parts = waktuStr.split('T');
        String tanggal = parts[0];

        // Format tanggal: YYYY-MM-DD → DD-MM-YYYY
        final tglParts = tanggal.split('-');
        if (tglParts.length == 3) {
          tanggal = '${tglParts[2]}-${tglParts[1]}-${tglParts[0]}';
        }

        String jam = parts[1];
        // Hapus bagian .000Z atau zona waktu lainnya
        jam = jam.replaceAll(RegExp(r'\..*$'), '');
        jam = jam.replaceAll(RegExp(r'Z$'), '');

        // Ambil hanya jam dan menit (HH:MM)
        if (jam.contains(':')) {
          final jamParts = jam.split(':');
          if (jamParts.length >= 2) {
            jam = '${jamParts[0]}:${jamParts[1]}';
          }
        }

        return '$tanggal $jam';
      }

      // Handle format dengan spasi: "2026-02-20 03:22:00"
      if (waktuStr.contains(' ')) {
        final parts = waktuStr.split(' ');
        if (parts.length >= 2) {
          String tanggal = parts[0];
          // Format tanggal: YYYY-MM-DD → DD-MM-YYYY
          final tglParts = tanggal.split('-');
          if (tglParts.length == 3) {
            tanggal = '${tglParts[2]}-${tglParts[1]}-${tglParts[0]}';
          }

          String jam = parts[1];
          // Ambil hanya jam dan menit (HH:MM)
          if (jam.contains(':')) {
            final jamParts = jam.split(':');
            if (jamParts.length >= 2) {
              jam = '${jamParts[0]}:${jamParts[1]}';
            }
          }

          return '$tanggal $jam';
        }
      }

      return waktuStr;
    } catch (e) {
      print('Error format waktu: $e');
      return waktuStr;
    }
  }

  // ================= HITUNG UNIQUE DATES =================
  int getUniqueDatesCount() {
    try {
      Set<String> dates = {};
      for (var item in semuaAbsensi) {
        if (item['waktu_absen'] != null) {
          String waktu = item['waktu_absen'].toString();
          if (waktu.contains('T')) {
            dates.add(waktu.split('T')[0]);
          } else if (waktu.contains(' ')) {
            dates.add(waktu.split(' ')[0]);
          }
        }
      }
      return dates.length;
    } catch (e) {
      print('Error hitung unique dates: $e');
      return 0;
    }
  }

  // ================= RESET =================
  void reset() {
    semuaAbsensi.clear();
    semuaUsers.clear();
    errorMessage.value = '';
    isLoading.value = false;
    isLoadingUsers.value = false;
    selectedUserId.value = '';
  }

  // ================= DEBUG =================
  void printDebugInfo() {
    print('=' * 50);
    print('📊 ADMIN ABSENSI CONTROLLER');
    print('Token: ${auth.token.isNotEmpty ? "Ada" : "Kosong"}');
    print('Total Users: ${semuaUsers.length}');
    print('Total Absensi: ${semuaAbsensi.length}');
    print('Selected User: ${selectedUserId.value}');
    print('Loading: $isLoading');
    print('Error: ${errorMessage.value}');
    print('=' * 50);
  }
}
