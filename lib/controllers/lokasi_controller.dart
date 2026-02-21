// lib/controllers/lokasi_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart'; // TAMBAHKAN IMPORT INI untuk Colors
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/lokasi_model.dart';
import 'auth_controller.dart';

class LokasiController extends GetxController {
  final auth = Get.find<AuthController>();

  // final String baseUrl = 'http://10.0.2.2:8000/api';
  // final String baseUrl = 'http://192.168.1.9:8000/api';

  final String baseUrl = 'http://192.168.1.10:8000/api';

  var lokasis = <LokasiModel>[].obs;
  var users = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var isUserLoading = false.obs;

  // Untuk multiple lokasi
  var selectedUserForMultiple = ''.obs;
  var multipleLokasiEntries = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (auth.token.isNotEmpty) {
      fetchLokasi();
      fetchUsers();
    }
    // Inisialisasi dengan 1 entry kosong
    addNewLokasiEntry();
  }

  Map<String, String> get _authHeaders => {
    'Accept': 'application/json',
    'Authorization': 'Bearer ${auth.token}',
  };

  // ================= SINGLE LOKASI =================
  Future<void> fetchLokasi() async {
    if (auth.token.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/lokasi'),
        headers: _authHeaders,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          lokasis.value = data.map((e) => LokasiModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Error fetchLokasi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsers() async {
    if (auth.token.isEmpty) return;

    isUserLoading.value = true;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/lokasi/users'),
        headers: _authHeaders,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          users.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print('Error fetchUsers: $e');
    } finally {
      isUserLoading.value = false;
    }
  }

  Future<void> addLokasi({
    required String userId,
    required String lokasi,
    required String koordinat,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/lokasi'),
        headers: {..._authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': int.parse(userId),
          'lokasi': lokasi,
          'koordinat': koordinat,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchLokasi();
        Get.snackbar('Sukses', 'Lokasi berhasil ditambahkan');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteLokasi(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/lokasi/$id'),
        headers: _authHeaders,
      );

      if (res.statusCode == 200) {
        await fetchLokasi();
        Get.snackbar('Sukses', 'Lokasi berhasil dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ================= MULTIPLE LOKASI =================
  void addNewLokasiEntry() {
    multipleLokasiEntries.add({
      'lokasi': ''.obs,
      'koordinat': ''.obs,
      'isValid': false.obs,
    });
  }

  void removeLokasiEntry(int index) {
    if (multipleLokasiEntries.length > 1) {
      multipleLokasiEntries.removeAt(index);
    }
  }

  void updateLokasiEntry(int index, String field, String value) {
    if (index < multipleLokasiEntries.length) {
      multipleLokasiEntries[index][field]?.value = value;
      // Validasi sederhana
      final lokasi = multipleLokasiEntries[index]['lokasi']?.value ?? '';
      final koordinat = multipleLokasiEntries[index]['koordinat']?.value ?? '';
      multipleLokasiEntries[index]['isValid']?.value =
          lokasi.isNotEmpty && koordinat.isNotEmpty;
    }
  }

  Future<void> submitMultipleLokasi() async {
    try {
      // Filter entries yang valid
      final validEntries = multipleLokasiEntries.where((entry) {
        final lokasi = entry['lokasi']?.value ?? '';
        final koordinat = entry['koordinat']?.value ?? '';
        return lokasi.isNotEmpty && koordinat.isNotEmpty;
      }).toList();

      if (validEntries.isEmpty) {
        Get.snackbar(
          'Error',
          'Tidak ada data lokasi yang valid untuk disimpan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedUserForMultiple.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Pilih user terlebih dahulu',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;
      int successCount = 0;
      int failedCount = 0;

      // Kirim satu per satu
      for (var entry in validEntries) {
        try {
          final res = await http.post(
            Uri.parse('$baseUrl/lokasi'),
            headers: {..._authHeaders, 'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': int.parse(selectedUserForMultiple.value),
              'lokasi': entry['lokasi']?.value ?? '',
              'koordinat': entry['koordinat']?.value ?? '',
            }),
          );

          if (res.statusCode == 200 || res.statusCode == 201) {
            successCount++;
          } else {
            failedCount++;
          }
        } catch (e) {
          failedCount++;
        }
      }

      // Reset form
      multipleLokasiEntries.clear();
      addNewLokasiEntry(); // Tambah 1 entry kosong
      selectedUserForMultiple.value = '';

      await fetchLokasi();

      // PERBAIKAN: String interpolation yang benar
      String message;
      if (failedCount > 0) {
        message =
            '$successCount lokasi berhasil ditambahkan, $failedCount gagal';
      } else {
        message = '$successCount lokasi berhasil ditambahkan';
      }

      Get.snackbar(
        'Sukses',
        message,
        backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void resetMultipleForm() {
    multipleLokasiEntries.clear();
    addNewLokasiEntry();
    selectedUserForMultiple.value = '';
  }
}
