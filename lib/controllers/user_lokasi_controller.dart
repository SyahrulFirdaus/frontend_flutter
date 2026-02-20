// lib/controllers/user_lokasi_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Tambahkan package ini
import 'auth_controller.dart';

class UserLokasiController extends GetxController {
  final auth = Get.find<AuthController>();

  final String baseUrl = 'http://10.0.2.2:8000/api';

  var userLokasis = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Untuk riwayat absensi
  var riwayatAbsensi = <Map<String, dynamic>>[].obs;
  var isLoadingRiwayat = false.obs;

  // Lokasi real-time pengguna
  var lokasiSaatIni = ''.obs;
  var isGettingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🟢 UserLokasiController diinisialisasi');
  }

  // ================= AMBIL LOKASI REAL-TIME PENGGUNA =================
  Future<String> getCurrentLocation() async {
    isGettingLocation.value = true;

    try {
      // Cek permission lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Izin lokasi diperlukan untuk absen',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return '';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Ditolak Permanen',
          'Izin lokasi tidak dapat diminta lagi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return '';
      }

      // Ambil posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String koordinat = '${position.latitude}, ${position.longitude}';
      lokasiSaatIni.value = koordinat;

      print('📍 Lokasi real-time: $koordinat');
      return koordinat;
    } catch (e) {
      print('❌ Error getCurrentLocation: $e');
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return '';
    } finally {
      isGettingLocation.value = false;
    }
  }

  // ================= AMBIL LOKASI USER =================
  Future<void> fetchUserLokasi() async {
    if (auth.token.isEmpty) {
      errorMessage.value = 'Token tidak ditemukan, silahkan login ulang';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('📌 Fetching user lokasi...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/lokasi'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📨 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          userLokasis.value = List<Map<String, dynamic>>.from(data);
          print('✅ Lokasi: ${userLokasis.length} data');
        } else {
          userLokasis.value = [];
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
      }
    } catch (e) {
      print('❌ Error: $e');
      errorMessage.value = 'Gagal memuat data';
    } finally {
      isLoading.value = false;
    }
  }

  // ================= SUBMIT ABSENSI =================
  Future<bool> submitAbsensi(String lokasiId, String lokasiNama) async {
    isLoading.value = true;

    try {
      print('🔥 SUBMIT ABSENSI - $lokasiNama (ID: $lokasiId)');

      // Validasi token
      if (auth.token.isEmpty) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Parse ID
      final lokasiIdInt = int.tryParse(lokasiId);
      if (lokasiIdInt == null) {
        Get.snackbar(
          'Error',
          'ID Lokasi tidak valid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Tampilkan dialog konfirmasi untuk lokasi real-time
      bool lanjutkan = await _showLocationConfirmDialog();

      if (!lanjutkan) {
        isLoading.value = false;
        return false;
      }

      // Ambil lokasi real-time pengguna
      String titikKoordinatKamu = await getCurrentLocation();

      // Kirim dengan koordinat (bisa null)
      return await _submitWithLocation(
        lokasiIdInt,
        lokasiNama,
        titikKoordinatKamu.isNotEmpty ? titikKoordinatKamu : null,
      );
    } catch (e) {
      print('❌ Exception: $e');
      Get.snackbar(
        'Error',
        'Koneksi error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DIALOG KONFIRMASI LOKASI =================
  Future<bool> _showLocationConfirmDialog() async {
    Completer<bool> completer = Completer<bool>();

    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Lokasi'),
        content: const Text(
          'Aplikasi akan mengakses lokasi Anda saat ini untuk verifikasi absen. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              completer.complete(false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              completer.complete(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    return completer.future;
  }

  Future<bool> _submitWithLocation(
    int lokasiIdInt,
    String lokasiNama,
    String? titikKoordinatKamu,
  ) async {
    try {
      // Kirim request
      final url = Uri.parse('$baseUrl/user/absensi');
      final requestBody = {
        'lokasi_id': lokasiIdInt,
        'titik_koordinat_kamu':
            titikKoordinatKamu, // Kirim koordinat real-time (bisa null)
      };

      print('📤 URL: $url');
      print('📦 Data: $requestBody');

      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Absensi berhasil!');

        Get.snackbar(
          'Berhasil',
          'Absensi di $lokasiNama berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Gagal absen';
          Get.snackbar(
            'Gagal',
            errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } catch (e) {
          Get.snackbar(
            'Gagal',
            'Error ${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    }
  }

  // ================= AMBIL RIWAYAT ABSENSI =================
  Future<void> fetchRiwayatAbsensi() async {
    if (auth.token.isEmpty) {
      print('❌ Token kosong');
      return;
    }

    isLoadingRiwayat.value = true;

    try {
      print('📌 Fetching riwayat absensi...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/absensi/riwayat'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📨 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          riwayatAbsensi.value = List<Map<String, dynamic>>.from(data);
          print('✅ Riwayat: ${riwayatAbsensi.length} data');
        } else {
          riwayatAbsensi.value = [];
        }
      }
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      isLoadingRiwayat.value = false;
    }
  }

  // ================= CEK STATUS HARI INI =================
  Future<Map<String, dynamic>> cekStatusHariIni() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/user/absensi/cek-hari-ini'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('❌ Error cek status: $e');
    }

    return {'sudah_absen': false};
  }

  // ================= RESET =================
  void reset() {
    userLokasis.clear();
    riwayatAbsensi.clear();
    errorMessage.value = '';
    isLoading.value = false;
    isLoadingRiwayat.value = false;
    lokasiSaatIni.value = '';
  }

  // ================= DEBUG =================
  void printDebugInfo() {
    print('=' * 50);
    print('📊 USER LOKASI CONTROLLER');
    print('Token: ${auth.token.isNotEmpty ? "Ada" : "Kosong"}');
    print('Role: ${auth.user['role']}');
    print('Lokasi: ${userLokasis.length}');
    print('Riwayat: ${riwayatAbsensi.length}');
    print('Lokasi Saat Ini: ${lokasiSaatIni.value}');
    print('Loading: $isLoading');
    print('=' * 50);
  }
}
