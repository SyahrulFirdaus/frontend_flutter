// // lib/controllers/user_lokasi_controller.dart
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'auth_controller.dart';

// class UserLokasiController extends GetxController {
//   final auth = Get.find<AuthController>();

//   final String baseUrl = 'http://10.0.2.2:8000/api';

//   var userLokasis = <Map<String, dynamic>>[].obs;
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   // Untuk riwayat absensi
//   var riwayatAbsensi = <Map<String, dynamic>>[].obs;
//   var isLoadingRiwayat = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     print('🟢 UserLokasiController diinisialisasi');
//   }

//   Map<String, String> get _authHeaders {
//     return {
//       'Accept': 'application/json',
//       'Authorization': 'Bearer ${auth.token}',
//       'Content-Type': 'application/json',
//     };
//   }

//   // ================= CEK KONEKSI =================
//   Future<bool> cekKoneksi() async {
//     try {
//       final response = await http
//           .get(Uri.parse('$baseUrl/user/profile'), headers: _authHeaders)
//           .timeout(const Duration(seconds: 5));
//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }

//   // ================= AMBIL LOKASI USER =================
//   Future<void> fetchUserLokasi() async {
//     if (auth.token.isEmpty) {
//       errorMessage.value = 'Token tidak ditemukan, silahkan login ulang';
//       return;
//     }

//     isLoading.value = true;
//     errorMessage.value = '';

//     try {
//       print('=' * 60);
//       print('🔍 FETCH USER LOKASI DIMULAI');
//       print('📌 Token: ${auth.token.substring(0, 20)}...');
//       print('📌 User role: ${auth.user['role']}');

//       final url = Uri.parse('$baseUrl/user/lokasi');
//       print('📌 URL: $url');

//       final response = await http
//           .get(url, headers: _authHeaders)
//           .timeout(const Duration(seconds: 15));

//       print('📌 Response status: ${response.statusCode}');
//       print('📌 Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final dynamic data = jsonDecode(response.body);
//         print('📌 Tipe data: ${data.runtimeType}');

//         if (data is List) {
//           userLokasis.value = List<Map<String, dynamic>>.from(data);
//           print('✅ Berhasil memuat ${userLokasis.length} lokasi');

//           if (userLokasis.isEmpty) {
//             print('⚠️ Data lokasi kosong');
//           } else {
//             print('📍 Lokasi pertama: ${userLokasis.first}');
//           }
//         } else {
//           userLokasis.value = [];
//           errorMessage.value = 'Format data tidak sesuai';
//           print('❌ Data bukan List: $data');
//         }
//       } else if (response.statusCode == 401) {
//         errorMessage.value = 'Sesi habis, silahkan login ulang';
//         print('❌ Unauthorized - Token mungkin expired');
//         Get.snackbar(
//           'Sesi Habis',
//           'Silahkan login ulang',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//         Future.delayed(const Duration(seconds: 2), () {
//           auth.logout();
//         });
//       } else if (response.statusCode == 403) {
//         errorMessage.value = 'Akses ditolak. Anda bukan user.';
//         print('❌ Forbidden - Bukan role user');
//       } else if (response.statusCode == 404) {
//         errorMessage.value = 'Endpoint tidak ditemukan. Cek URL.';
//         print('❌ 404 Not Found - URL: $url');
//       } else {
//         errorMessage.value = 'Error ${response.statusCode}';
//         print('❌ Error lain: ${response.statusCode}');
//       }
//     } on TimeoutException catch (_) {
//       print('❌ Timeout fetchUserLokasi');
//       errorMessage.value = 'Koneksi timeout, silahkan coba lagi';
//     } catch (e) {
//       print('❌ Error fetchUserLokasi: $e');
//       errorMessage.value = 'Gagal memuat data: ${e.toString()}';
//     } finally {
//       isLoading.value = false;
//       print('=' * 60);
//     }
//   }

//   // ================= SUBMIT ABSENSI =================
//   Future<bool> submitAbsensi(String lokasiId, String lokasiNama) async {
//     try {
//       print('=' * 60);
//       print('🔥 SUBMIT ABSENSI - START');
//       print('📍 Parameter lokasiId: $lokasiId');
//       print('📍 Parameter lokasiNama: $lokasiNama');
//       print('🔑 Token tersedia: ${auth.token.isNotEmpty}');

//       // Validasi token
//       if (auth.token.isEmpty) {
//         print('❌ Token kosong');
//         Get.snackbar(
//           'Error',
//           'Token tidak ditemukan, silahkan login ulang',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//         return false;
//       }

//       print(
//         '🔑 Token (10 karakter pertama): ${auth.token.substring(0, 10)}...',
//       );
//       print('🔑 Headers: ${_authHeaders}');

//       // Validasi URL
//       final url = Uri.parse('$baseUrl/user/absensi');
//       print('📌 URL: $url');

//       // Parse lokasiId ke integer
//       final lokasiIdInt = int.tryParse(lokasiId);
//       if (lokasiIdInt == null) {
//         print('❌ lokasiId tidak valid: $lokasiId');
//         Get.snackbar(
//           'Error',
//           'ID Lokasi tidak valid',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//         return false;
//       }

//       // Buat request body
//       final Map<String, dynamic> requestBody = {'lokasi_id': lokasiIdInt};

//       final String requestBodyJson = jsonEncode(requestBody);
//       print('📦 Request body: $requestBodyJson');

//       // Kirim request
//       print('⏳ Mengirim request...');
//       final response = await http
//           .post(url, headers: _authHeaders, body: requestBodyJson)
//           .timeout(
//             const Duration(seconds: 15),
//             onTimeout: () {
//               print('⏰ TIMEOUT - Server tidak merespon dalam 15 detik');
//               throw TimeoutException('Koneksi timeout');
//             },
//           );

//       print('📨 Response status: ${response.statusCode}');
//       print('📨 Response body: ${response.body}');

//       // Handle response berdasarkan status code
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print('✅ SUCCESS - Absensi berhasil');

//         // Parse response untuk log
//         try {
//           final responseData = jsonDecode(response.body);
//           print('📊 Response data: $responseData');

//           // Tampilkan snackbar sukses
//           Get.snackbar(
//             'Berhasil',
//             'Absensi di $lokasiNama berhasil dicatat',
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//             duration: const Duration(seconds: 3),
//           );
//         } catch (e) {
//           print('⚠️ Tidak bisa parse response: $e');
//           Get.snackbar(
//             'Berhasil',
//             'Absensi berhasil',
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         }

//         return true;
//       } else if (response.statusCode == 400) {
//         print('❌ Bad Request - Mungkin sudah absen hari ini');
//         try {
//           final errorData = jsonDecode(response.body);
//           String errorMsg = errorData['message'] ?? 'Anda sudah absen hari ini';
//           print('❌ Error message: $errorMsg');
//           Get.snackbar(
//             'Info',
//             errorMsg,
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         } catch (e) {
//           Get.snackbar(
//             'Info',
//             'Anda sudah absen hari ini',
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         }
//         return false;
//       } else if (response.statusCode == 401) {
//         print('❌ Unauthorized - Token expired');
//         Get.snackbar(
//           'Sesi Habis',
//           'Silahkan login ulang',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//         Future.delayed(const Duration(seconds: 2), () {
//           auth.logout();
//         });
//         return false;
//       } else if (response.statusCode == 403) {
//         print('❌ Forbidden - Bukan milik user atau bukan role user');
//         try {
//           final errorData = jsonDecode(response.body);
//           String errorMsg = errorData['message'] ?? 'Akses ditolak';
//           print('❌ Error message: $errorMsg');
//           Get.snackbar(
//             'Gagal',
//             errorMsg,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         } catch (e) {
//           Get.snackbar(
//             'Gagal',
//             'Akses ditolak',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         }
//         return false;
//       } else if (response.statusCode == 404) {
//         print('❌ 404 Not Found - Endpoint salah');
//         Get.snackbar(
//           'Error',
//           'Endpoint tidak ditemukan',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//         return false;
//       } else if (response.statusCode == 422) {
//         print('❌ 422 Validation Error');
//         try {
//           final errorData = jsonDecode(response.body);
//           String errorMsg = errorData['message'] ?? 'Validasi gagal';
//           print('❌ Error message: $errorMsg');
//           print('❌ Errors: ${errorData['errors']}');
//           Get.snackbar(
//             'Gagal',
//             errorMsg,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         } catch (e) {
//           Get.snackbar(
//             'Gagal',
//             'Data tidak valid',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         }
//         return false;
//       } else if (response.statusCode == 500) {
//         print('❌ 500 Internal Server Error');
//         try {
//           final errorData = jsonDecode(response.body);
//           String errorMsg = errorData['message'] ?? 'Server error';
//           print('❌ Error message: $errorMsg');
//           Get.snackbar(
//             'Error',
//             'Terjadi kesalahan di server',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         } catch (e) {
//           Get.snackbar(
//             'Error',
//             'Server error',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             snackPosition: SnackPosition.TOP,
//           );
//         }
//         return false;
//       } else {
//         print('❌ Unknown error: ${response.statusCode}');
//         Get.snackbar(
//           'Error',
//           'Error ${response.statusCode}',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.TOP,
//         );
//         return false;
//       }
//     } on TimeoutException catch (e) {
//       print('⏰ TIMEOUT EXCEPTION: $e');
//       Get.snackbar(
//         'Error',
//         'Koneksi timeout, periksa jaringan Anda',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//       return false;
//     } catch (e) {
//       print('❌ EXCEPTION: $e');
//       print('📋 Stack trace: ${StackTrace.current}');
//       Get.snackbar(
//         'Error',
//         'Koneksi error: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//       return false;
//     } finally {
//       print('🔥 SUBMIT ABSENSI - END');
//       print('=' * 60);
//     }
//   }

//   // ================= AMBIL RIWAYAT ABSENSI =================
//   Future<void> fetchRiwayatAbsensi() async {
//     if (auth.token.isEmpty) {
//       print('❌ Token kosong, tidak bisa fetch riwayat');
//       return;
//     }

//     isLoadingRiwayat.value = true;

//     try {
//       print('📌 Fetching riwayat absensi...');
//       final url = Uri.parse('$baseUrl/user/absensi/riwayat');
//       print('📌 URL: $url');

//       final response = await http
//           .get(url, headers: _authHeaders)
//           .timeout(const Duration(seconds: 10));

//       print('📌 Response status: ${response.statusCode}');
//       print('📌 Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final dynamic data = jsonDecode(response.body);

//         if (data is List) {
//           riwayatAbsensi.value = List<Map<String, dynamic>>.from(data);
//           print('✅ Riwayat: ${riwayatAbsensi.length} data');
//         } else if (data is Map && data.containsKey('data')) {
//           riwayatAbsensi.value = List<Map<String, dynamic>>.from(data['data']);
//           print('✅ Riwayat (pagination): ${riwayatAbsensi.length} data');
//         } else {
//           print('⚠️ Format riwayat tidak dikenal: $data');
//         }
//       } else {
//         print('❌ Gagal fetch riwayat: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error fetchRiwayat: $e');
//     } finally {
//       isLoadingRiwayat.value = false;
//     }
//   }

//   // ================= CEK STATUS ABSENSI HARI INI =================
//   Future<Map<String, dynamic>> cekStatusHariIni() async {
//     try {
//       print('📌 Cek status absensi hari ini...');
//       final url = Uri.parse('$baseUrl/user/absensi/cek-hari-ini');
//       final response = await http
//           .get(url, headers: _authHeaders)
//           .timeout(const Duration(seconds: 5));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('✅ Status: ${data['sudah_absen']}');
//         return data;
//       }
//     } catch (e) {
//       print('❌ Error cekStatusHariIni: $e');
//     }
//     return {
//       'sudah_absen': false,
//       'tanggal': DateTime.now().toString().substring(0, 10),
//     };
//   }

//   // ================= RESET =================
//   void reset() {
//     print('🔄 Reset UserLokasiController');
//     userLokasis.clear();
//     riwayatAbsensi.clear();
//     errorMessage.value = '';
//     isLoading.value = false;
//     isLoadingRiwayat.value = false;
//   }

//   // ================= DEBUG INFO =================
//   void printDebugInfo() {
//     print('=' * 60);
//     print('📊 DEBUG INFO UserLokasiController');
//     print('🔑 Token ada: ${auth.token.isNotEmpty}');
//     print('👤 User role: ${auth.user['role']}');
//     print('📍 Jumlah lokasi: ${userLokasis.length}');
//     print('📋 Jumlah riwayat: ${riwayatAbsensi.length}');
//     print('⏳ Loading: $isLoading');
//     print('⚠️ Error: ${errorMessage.value}');
//     print('=' * 60);
//   }
// }
// lib/controllers/user_lokasi_controller.dart
import 'dart:async';
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

  // Untuk riwayat absensi
  var riwayatAbsensi = <Map<String, dynamic>>[].obs;
  var isLoadingRiwayat = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🟢 UserLokasiController diinisialisasi');
  }

  Map<String, String> get _authHeaders {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${auth.token}',
      'Content-Type': 'application/json',
    };
  }

  // ================= CEK KONEKSI =================
  Future<bool> cekKoneksi() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/user/profile'), headers: _authHeaders)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
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
      print('=' * 60);
      print('🔍 FETCH USER LOKASI DIMULAI');
      print('📌 Token: ${auth.token.substring(0, 20)}...');
      print('📌 User role: ${auth.user['role']}');

      final url = Uri.parse('$baseUrl/user/lokasi');
      print('📌 URL: $url');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 15));

      print('📌 Response status: ${response.statusCode}');
      print('📌 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        print('📌 Tipe data: ${data.runtimeType}');

        if (data is List) {
          userLokasis.value = List<Map<String, dynamic>>.from(data);
          print('✅ Berhasil memuat ${userLokasis.length} lokasi');

          if (userLokasis.isEmpty) {
            print('⚠️ Data lokasi kosong');
          } else {
            print('📍 Lokasi pertama: ${userLokasis.first}');
          }
        } else {
          userLokasis.value = [];
          errorMessage.value = 'Format data tidak sesuai';
          print('❌ Data bukan List: $data');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Sesi habis, silahkan login ulang';
        print('❌ Unauthorized - Token mungkin expired');
        Get.snackbar(
          'Sesi Habis',
          'Silahkan login ulang',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Future.delayed(const Duration(seconds: 2), () {
          auth.logout();
        });
      } else if (response.statusCode == 403) {
        errorMessage.value = 'Akses ditolak. Anda bukan user.';
        print('❌ Forbidden - Bukan role user');
      } else if (response.statusCode == 404) {
        errorMessage.value = 'Endpoint tidak ditemukan. Cek URL.';
        print('❌ 404 Not Found - URL: $url');
      } else {
        errorMessage.value = 'Error ${response.statusCode}';
        print('❌ Error lain: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('❌ Timeout fetchUserLokasi');
      errorMessage.value = 'Koneksi timeout, silahkan coba lagi';
    } catch (e) {
      print('❌ Error fetchUserLokasi: $e');
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
    } finally {
      isLoading.value = false;
      print('=' * 60);
    }
  }

  // ================= SUBMIT ABSENSI =================
  Future<bool> submitAbsensi(String lokasiId, String lokasiNama) async {
    // Set loading state di awal
    isLoading.value = true;

    try {
      print('=' * 60);
      print('🔥 SUBMIT ABSENSI - START');
      print('📍 Parameter lokasiId: $lokasiId');
      print('📍 Parameter lokasiNama: $lokasiNama');
      print('🔑 Token tersedia: ${auth.token.isNotEmpty}');

      // Validasi token
      if (auth.token.isEmpty) {
        print('❌ Token kosong');
        Get.snackbar(
          'Error',
          'Token tidak ditemukan, silahkan login ulang',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      print(
        '🔑 Token (10 karakter pertama): ${auth.token.substring(0, 10)}...',
      );

      // Validasi URL
      final url = Uri.parse('$baseUrl/user/absensi');
      print('📌 URL: $url');

      // Parse lokasiId ke integer
      final lokasiIdInt = int.tryParse(lokasiId);
      if (lokasiIdInt == null) {
        print('❌ lokasiId tidak valid: $lokasiId');
        Get.snackbar(
          'Error',
          'ID Lokasi tidak valid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Buat request body
      final Map<String, dynamic> requestBody = {'lokasi_id': lokasiIdInt};
      final String requestBodyJson = jsonEncode(requestBody);
      print('📦 Request body: $requestBodyJson');

      // Kirim request
      print('⏳ Mengirim request...');
      final response = await http
          .post(url, headers: _authHeaders, body: requestBodyJson)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('⏰ TIMEOUT - Server tidak merespon dalam 15 detik');
              throw TimeoutException('Koneksi timeout');
            },
          );

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      // Handle response berdasarkan status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ SUCCESS - Absensi berhasil');

        // Parse response untuk log
        try {
          final responseData = jsonDecode(response.body);
          print('📊 Response data: $responseData');
        } catch (e) {
          print('⚠️ Tidak bisa parse response: $e');
        }

        return true;
      } else if (response.statusCode == 400) {
        print('❌ Bad Request - Mungkin sudah absen hari ini');
        try {
          final errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Anda sudah absen hari ini';
          print('❌ Error message: $errorMsg');
          Get.snackbar(
            'Info',
            errorMsg,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } catch (e) {
          Get.snackbar(
            'Info',
            'Anda sudah absen hari ini',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
        return false;
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - Token expired');
        Get.snackbar(
          'Sesi Habis',
          'Silahkan login ulang',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Future.delayed(const Duration(seconds: 2), () {
          auth.logout();
        });
        return false;
      } else if (response.statusCode == 403) {
        print('❌ Forbidden - Bukan milik user atau bukan role user');
        try {
          final errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Akses ditolak';
          print('❌ Error message: $errorMsg');
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
            'Akses ditolak',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
        return false;
      } else if (response.statusCode == 404) {
        print('❌ 404 Not Found - Endpoint salah');
        Get.snackbar(
          'Error',
          'Endpoint tidak ditemukan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      } else if (response.statusCode == 422) {
        print('❌ 422 Validation Error');
        try {
          final errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Validasi gagal';
          print('❌ Error message: $errorMsg');
          print('❌ Errors: ${errorData['errors']}');
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
            'Data tidak valid',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
        return false;
      } else if (response.statusCode == 500) {
        print('❌ 500 Internal Server Error');
        try {
          final errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Server error';
          print('❌ Error message: $errorMsg');
          Get.snackbar(
            'Error',
            'Terjadi kesalahan di server',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Server error',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
        return false;
      } else {
        print('❌ Unknown error: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Error ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } on TimeoutException catch (e) {
      print('⏰ TIMEOUT EXCEPTION: $e');
      Get.snackbar(
        'Error',
        'Koneksi timeout, periksa jaringan Anda',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } catch (e) {
      print('❌ EXCEPTION: $e');
      print('📋 Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Koneksi error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      // Pastikan loading state dimatikan di finally block
      isLoading.value = false;
      print('🔥 SUBMIT ABSENSI - END (isLoading: false)');
      print('=' * 60);
    }
  }

  // ================= AMBIL RIWAYAT ABSENSI =================
  Future<void> fetchRiwayatAbsensi() async {
    if (auth.token.isEmpty) {
      print('❌ Token kosong, tidak bisa fetch riwayat');
      return;
    }

    isLoadingRiwayat.value = true;

    try {
      print('📌 Fetching riwayat absensi...');
      final url = Uri.parse('$baseUrl/user/absensi/riwayat');
      print('📌 URL: $url');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      print('📌 Response status: ${response.statusCode}');
      print('📌 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is List) {
          riwayatAbsensi.value = List<Map<String, dynamic>>.from(data);
          print('✅ Riwayat: ${riwayatAbsensi.length} data');
        } else if (data is Map && data.containsKey('data')) {
          riwayatAbsensi.value = List<Map<String, dynamic>>.from(data['data']);
          print('✅ Riwayat (pagination): ${riwayatAbsensi.length} data');
        } else {
          print('⚠️ Format riwayat tidak dikenal: $data');
        }
      } else {
        print('❌ Gagal fetch riwayat: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetchRiwayat: $e');
    } finally {
      isLoadingRiwayat.value = false;
    }
  }

  // ================= CEK STATUS ABSENSI HARI INI =================
  Future<Map<String, dynamic>> cekStatusHariIni() async {
    try {
      print('📌 Cek status absensi hari ini...');
      final url = Uri.parse('$baseUrl/user/absensi/cek-hari-ini');
      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Status: ${data['sudah_absen']}');
        return data;
      }
    } catch (e) {
      print('❌ Error cekStatusHariIni: $e');
    }
    return {
      'sudah_absen': false,
      'tanggal': DateTime.now().toString().substring(0, 10),
    };
  }

  // ================= RESET =================
  void reset() {
    print('🔄 Reset UserLokasiController');
    userLokasis.clear();
    riwayatAbsensi.clear();
    errorMessage.value = '';
    isLoading.value = false;
    isLoadingRiwayat.value = false;
  }

  // ================= DEBUG INFO =================
  void printDebugInfo() {
    print('=' * 60);
    print('📊 DEBUG INFO UserLokasiController');
    print('🔑 Token ada: ${auth.token.isNotEmpty}');
    print('👤 User role: ${auth.user['role']}');
    print('📍 Jumlah lokasi: ${userLokasis.length}');
    print('📋 Jumlah riwayat: ${riwayatAbsensi.length}');
    print('⏳ Loading: $isLoading');
    print('⚠️ Error: ${errorMessage.value}');
    print('=' * 60);
  }
}
