// lib/controllers/user_lokasi_controller.dart

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'auth_controller.dart';

class UserLokasiController extends GetxController {
  final auth = Get.find<AuthController>();
  // final String baseUrl = 'http://10.0.2.2:8000/api';
  // final String baseUrl =
  //     'http://192.168.1.9:8000/api'; // Sesuaikan dengan IP komputer Anda
  final String baseUrl = 'http://192.168.95.243:8000/api';

  var userLokasis = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Untuk riwayat absensi
  var riwayatAbsensi = <Map<String, dynamic>>[].obs;
  var isLoadingRiwayat = false.obs;

  // Status absen hari ini
  var sudahMasuk = false.obs;
  var sudahPulang = false.obs;
  var dataMasuk = Rxn<Map<String, dynamic>>();
  var dataPulang = Rxn<Map<String, dynamic>>();

  // Lokasi real-time pengguna
  var lokasiSaatIni = ''.obs;
  var isGettingLocation = false.obs;

  // Foto wajah
  var fotoWajah = Rxn<File>();
  var isTakingPhoto = false.obs;
  var isDetectingFace = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🟢 UserLokasiController diinisialisasi');
    cekStatusHariIni();
  }

  // ================= CEK STATUS ABSEN HARI INI =================
  Future<void> cekStatusHariIni() async {
    try {
      print('📌 Cek status absen hari ini...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/absensi/cek-status'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 5));

      print('📨 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sudahMasuk.value = data['sudah_masuk'] ?? false;
        sudahPulang.value = data['sudah_pulang'] ?? false;
        dataMasuk.value = data['data_masuk'];
        dataPulang.value = data['data_pulang'];

        print('📊 Status Absen: Masuk=$sudahMasuk, Pulang=$sudahPulang');
      }
    } catch (e) {
      print('❌ Error cek status: $e');
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
      print('=' * 50);
      print('📌 FETCH USER LOKASI - DIMULAI');
      print('🔑 Token: ${auth.token.substring(0, 20)}...');
      print('👤 User ID: ${auth.user['id']}');
      print('👤 User Name: ${auth.user['name']}');
      print('📌 URL: $baseUrl/user/lokasi');

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/lokasi'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is List) {
          userLokasis.value = List<Map<String, dynamic>>.from(data);
          print('✅ Lokasi ditemukan: ${userLokasis.length} data');

          if (userLokasis.isEmpty) {
            errorMessage.value = 'Belum ada lokasi yang ditentukan untuk Anda';
            print('⚠️ Data lokasi kosong');
          } else {
            for (var lokasi in userLokasis) {
              print(
                '   - ID: ${lokasi['id']}, Nama: ${lokasi['lokasi']}, Koordinat: ${lokasi['koordinat']}',
              );
            }
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
          snackPosition: SnackPosition.TOP,
        );
        Future.delayed(const Duration(seconds: 2), () => auth.logout());
      } else if (response.statusCode == 403) {
        errorMessage.value = 'Akses ditolak. Anda bukan user.';
        print('❌ Forbidden - Bukan role user');
      } else if (response.statusCode == 404) {
        errorMessage.value = 'Endpoint tidak ditemukan. Cek URL.';
        print('❌ 404 Not Found - URL: $baseUrl/user/lokasi');
      } else {
        errorMessage.value = 'Error ${response.statusCode}';
        print('❌ Error lain: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
    } finally {
      isLoading.value = false;
      print('📌 FETCH USER LOKASI - SELESAI');
      print('=' * 50);
    }
  }

  // ================= DETEKSI WAJAH =================
  Future<bool> _detectFace(File imageFile) async {
    isDetectingFace.value = true;

    try {
      final inputImage = InputImage.fromFile(imageFile);

      final options = FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        performanceMode: FaceDetectorMode.fast,
      );

      final faceDetector = FaceDetector(options: options);
      final List<Face> faces = await faceDetector.processImage(inputImage);
      faceDetector.close();

      print('📸 Jumlah wajah terdeteksi: ${faces.length}');

      if (faces.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Tidak ada wajah terdeteksi',
          backgroundColor: Colors.red,
        );
        return false;
      }

      if (faces.length > 1) {
        Get.snackbar(
          'Gagal',
          'Terlalu banyak wajah',
          backgroundColor: Colors.orange,
        );
        return false;
      }

      Face face = faces.first;

      if (face.boundingBox.width < 100 || face.boundingBox.height < 100) {
        Get.snackbar(
          'Kualitas Rendah',
          'Wajah terlalu kecil',
          backgroundColor: Colors.orange,
        );
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error face detection: $e');
      return false;
    } finally {
      isDetectingFace.value = false;
    }
  }

  // ================= AMBIL FOTO DAN DETEKSI WAJAH =================
  Future<File?> takePhotoWithFaceDetection() async {
    isTakingPhoto.value = true;

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo == null) {
        return null;
      }

      File imageFile = File(photo.path);
      bool isFaceValid = await _detectFace(imageFile);

      if (!isFaceValid) {
        bool retry = await _showRetryDialog();
        if (retry) {
          return await takePhotoWithFaceDetection();
        } else {
          return null;
        }
      }

      fotoWajah.value = imageFile;
      return fotoWajah.value;
    } catch (e) {
      print('❌ Error take photo: $e');
      return null;
    } finally {
      isTakingPhoto.value = false;
    }
  }

  // ================= DIALOG FOTO ULANG =================
  Future<bool> _showRetryDialog() async {
    Completer<bool> completer = Completer();

    Get.dialog(
      AlertDialog(
        title: const Text('Foto Tidak Valid'),
        content: const Text(
          'Foto tidak mengandung wajah yang jelas. Foto ulang?',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Foto Ulang'),
          ),
        ],
      ),
    );

    return completer.future;
  }

  // ================= AMBIL LOKASI REAL-TIME =================
  Future<String> getCurrentLocation() async {
    isGettingLocation.value = true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Izin lokasi diperlukan',
            backgroundColor: Colors.orange,
          );
          return '';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String koordinat = '${position.latitude}, ${position.longitude}';
      lokasiSaatIni.value = koordinat;
      return koordinat;
    } catch (e) {
      print('❌ Error getCurrentLocation: $e');
      return '';
    } finally {
      isGettingLocation.value = false;
    }
  }

  // ================= SUBMIT ABSENSI MASUK =================
  Future<bool> submitAbsensiMasuk(
    String lokasiId,
    String lokasiNama,
    String koordinatLokasi,
  ) async {
    return _submitAbsensi(lokasiId, lokasiNama, koordinatLokasi, 'masuk');
  }

  // ================= SUBMIT ABSENSI PULANG =================
  Future<bool> submitAbsensiPulang(
    String lokasiId,
    String lokasiNama,
    String koordinatLokasi,
  ) async {
    return _submitAbsensi(lokasiId, lokasiNama, koordinatLokasi, 'pulang');
  }

  // ================= SUBMIT ABSENSI (GENERAL) =================
  Future<bool> _submitAbsensi(
    String lokasiId,
    String lokasiNama,
    String koordinatLokasi,
    String tipe,
  ) async {
    isLoading.value = true;

    try {
      print('🔥 SUBMIT ABSENSI $tipe - $lokasiNama');

      if (auth.token.isEmpty) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan',
          backgroundColor: Colors.red,
        );
        return false;
      }

      // Validasi apakah sudah absen untuk tipe ini
      if (tipe == 'masuk' && sudahMasuk.value) {
        Get.snackbar(
          'Info',
          'Anda sudah absen masuk hari ini',
          backgroundColor: Colors.orange,
        );
        return false;
      }
      if (tipe == 'pulang' && sudahPulang.value) {
        Get.snackbar(
          'Info',
          'Anda sudah absen pulang hari ini',
          backgroundColor: Colors.orange,
        );
        return false;
      }

      final lokasiIdInt = int.tryParse(lokasiId);
      if (lokasiIdInt == null) {
        Get.snackbar(
          'Error',
          'ID Lokasi tidak valid',
          backgroundColor: Colors.red,
        );
        return false;
      }

      // Ambil lokasi real-time
      String titikKoordinatKamu = await getCurrentLocation();
      if (titikKoordinatKamu.isEmpty) {
        Get.snackbar(
          'Error',
          'Gagal mendapatkan lokasi Anda',
          backgroundColor: Colors.red,
        );
        return false;
      }

      // Validasi jarak
      bool jarakValid = await _validasiJarak(
        koordinatLokasi,
        titikKoordinatKamu,
      );
      if (!jarakValid) return false;

      // Ambil foto
      File? foto = await takePhotoWithFaceDetection();
      if (foto == null) {
        Get.snackbar(
          'Info',
          'Absen dibatalkan',
          backgroundColor: Colors.orange,
        );
        return false;
      }

      // Kirim ke server
      return await _submitWithPhoto(
        lokasiIdInt,
        lokasiNama,
        titikKoordinatKamu,
        foto,
        tipe,
      );
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    } finally {
      isLoading.value = false;
      cekStatusHariIni(); // Refresh status
    }
  }

  // ================= VALIDASI JARAK =================
  Future<bool> _validasiJarak(
    String koordinatLokasi,
    String titikKoordinatKamu,
  ) async {
    try {
      // Parse koordinat lokasi
      final lokasiParts = koordinatLokasi.split(',');
      final kamuParts = titikKoordinatKamu.split(',');

      if (lokasiParts.length != 2 || kamuParts.length != 2) return false;

      final lokasiLat = double.tryParse(lokasiParts[0].trim());
      final lokasiLng = double.tryParse(lokasiParts[1].trim());
      final kamuLat = double.tryParse(kamuParts[0].trim());
      final kamuLng = double.tryParse(kamuParts[1].trim());

      if (lokasiLat == null ||
          lokasiLng == null ||
          kamuLat == null ||
          kamuLng == null) {
        return false;
      }

      final lokasiLatLng = LatLng(lokasiLat, lokasiLng);
      final kamuLatLng = LatLng(kamuLat, kamuLng);

      double jarakMeter = _hitungJarakDalamMeter(lokasiLatLng, kamuLatLng);
      print('📏 Jarak: ${jarakMeter.toStringAsFixed(2)} meter');

      const double batasMaksimal = 100.0;

      if (jarakMeter > batasMaksimal) {
        await _showJarakTerlaluJauhDialog(jarakMeter, batasMaksimal);
        return false;
      }

      return true;
    } catch (e) {
      print('Error validasi jarak: $e');
      return false;
    }
  }

  // ================= HITUNG JARAK =================
  double _hitungJarakDalamMeter(LatLng titik1, LatLng titik2) {
    const double R = 6371;

    double lat1 = titik1.latitude * pi / 180;
    double lat2 = titik2.latitude * pi / 180;
    double deltaLat = (titik2.latitude - titik1.latitude) * pi / 180;
    double deltaLng = (titik2.longitude - titik1.longitude) * pi / 180;

    double a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanceKm = R * c;

    return distanceKm * 1000;
  }

  // ================= KIRIM DENGAN FOTO =================
  Future<bool> _submitWithPhoto(
    int lokasiIdInt,
    String lokasiNama,
    String titikKoordinatKamu,
    File foto,
    String tipe,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/absensi/$tipe'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      });

      request.fields['lokasi_id'] = lokasiIdInt.toString();
      request.fields['titik_koordinat_kamu'] = titikKoordinatKamu;

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_wajah',
          foto.path,
          filename: '${tipe}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      print('📤 Mengirim request $tipe...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Berhasil',
          'Absen $tipe di $lokasiNama berhasil',
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          Get.snackbar(
            'Gagal',
            errorData['message'] ?? 'Gagal absen',
            backgroundColor: Colors.red,
          );
        } catch (e) {
          Get.snackbar(
            'Gagal',
            'Error ${response.statusCode}',
            backgroundColor: Colors.red,
          );
        }
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    }
  }

  // ================= DIALOG JARAK TERLALU JAUH =================
  Future<void> _showJarakTerlaluJauhDialog(double jarak, double batas) async {
    String jarakFormat = jarak < 1000
        ? '${jarak.toStringAsFixed(1)} meter'
        : '${(jarak / 1000).toStringAsFixed(2)} km';

    return Get.dialog(
      AlertDialog(
        title: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 40,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Jarak Terlalu Jauh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text('Jarak Anda $jarakFormat', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Batas maksimal ${batas.toStringAsFixed(0)} meter',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Anda tidak dapat melakukan absensi.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('MENGERTI'),
          ),
        ],
      ),
    );
  }

  // ================= AMBIL RIWAYAT ABSENSI =================
  Future<void> fetchRiwayatAbsensi() async {
    if (auth.token.isEmpty) return;

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

  // ================= RESET =================
  void reset() {
    userLokasis.clear();
    riwayatAbsensi.clear();
    errorMessage.value = '';
    isLoading.value = false;
    isLoadingRiwayat.value = false;
    lokasiSaatIni.value = '';
    fotoWajah.value = null;
    sudahMasuk.value = false;
    sudahPulang.value = false;
    dataMasuk.value = null;
    dataPulang.value = null;
  }

  // ================= DEBUG =================
  void printDebugInfo() {
    print('=' * 50);
    print('📊 USER LOKASI CONTROLLER');
    print('Token: ${auth.token.isNotEmpty ? "Ada" : "Kosong"}');
    print('Role: ${auth.user['role']}');
    print('Lokasi: ${userLokasis.length}');
    print('Riwayat: ${riwayatAbsensi.length}');
    print('Status Masuk: $sudahMasuk');
    print('Status Pulang: $sudahPulang');
    print('Lokasi Saat Ini: ${lokasiSaatIni.value}');
    print('Loading: $isLoading');
    print('=' * 50);
  }
}
