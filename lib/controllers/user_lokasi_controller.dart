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

  final String baseUrl =
      'http://192.168.1.9:8000/api'; // Sesuaikan dengan IP komputer Anda

  var userLokasis = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Untuk riwayat absensi
  var riwayatAbsensi = <Map<String, dynamic>>[].obs;
  var isLoadingRiwayat = false.obs;

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
  }

  // ================= DETEKSI WAJAH DENGAN GOOGLE ML KIT =================
  Future<bool> _detectFace(File imageFile) async {
    isDetectingFace.value = true;

    try {
      // Buat InputImage dari file
      final inputImage = InputImage.fromFile(imageFile);

      // Konfigurasi face detector
      final options = FaceDetectorOptions(
        enableClassification: true, // Deteksi senyum, mata terbuka
        enableLandmarks: true, // Deteksi landmark wajah
        enableContours: true, // Deteksi kontur wajah
        performanceMode: FaceDetectorMode.fast, // Mode cepat
      );

      // Buat instance face detector
      final faceDetector = FaceDetector(options: options);

      // Proses deteksi
      final List<Face> faces = await faceDetector.processImage(inputImage);

      // Tutup detector untuk hemat memori
      faceDetector.close();

      print('📸 Jumlah wajah terdeteksi: ${faces.length}');

      // VALIDASI 1: Harus ada wajah
      if (faces.isEmpty) {
        Get.snackbar(
          'Deteksi Wajah Gagal',
          'Tidak ada wajah terdeteksi. Silakan foto ulang.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      // VALIDASI 2: Hanya boleh 1 wajah
      if (faces.length > 1) {
        Get.snackbar(
          'Deteksi Wajah Gagal',
          'Terdeteksi ${faces.length} wajah. Harap foto hanya 1 wajah.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      // Ambil wajah pertama
      Face face = faces.first;

      // VALIDASI 3: Ukuran wajah minimal
      if (face.boundingBox.width < 100 || face.boundingBox.height < 100) {
        Get.snackbar(
          'Kualitas Foto Rendah',
          'Wajah terlalu kecil. Dekatkan kamera.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // VALIDASI 4: Pastikan mata terbuka (opsional)
      if (face.leftEyeOpenProbability != null &&
          face.rightEyeOpenProbability != null) {
        if (face.leftEyeOpenProbability! < 0.3 ||
            face.rightEyeOpenProbability! < 0.3) {
          Get.snackbar(
            'Peringatan',
            'Pastikan mata terbuka',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          // Bisa return false jika ingin mewajibkan mata terbuka
          // return false;
        }
      }

      // VALIDASI 5: Pastikan wajah menghadap ke depan (opsional)
      if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() > 30) {
        Get.snackbar(
          'Peringatan',
          'Wajah terlalu miring. Hadap lurus ke kamera.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        // return false; // Opsional
      }

      print('✅ Wajah terdeteksi dengan baik');
      print('   - Posisi: ${face.boundingBox}');
      print('   - Probabilitas mata kiri: ${face.leftEyeOpenProbability}');
      print('   - Probabilitas mata kanan: ${face.rightEyeOpenProbability}');
      print('   - Probabilitas senyum: ${face.smilingProbability}');

      return true;
    } catch (e) {
      print('❌ Error face detection: $e');
      Get.snackbar(
        'Error Deteksi',
        'Gagal mendeteksi wajah. Coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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

      // Buka kamera dengan kamera depan
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo == null) {
        print('⚠️ User membatalkan pengambilan foto');
        return null;
      }

      File imageFile = File(photo.path);

      // Deteksi wajah
      bool isFaceValid = await _detectFace(imageFile);

      if (!isFaceValid) {
        // Tanya user apakah mau foto ulang?
        bool retry = await _showRetryDialog();
        if (retry) {
          return await takePhotoWithFaceDetection(); // Rekursif
        } else {
          return null;
        }
      }

      fotoWajah.value = imageFile;
      print('✅ Foto wajah valid dan siap dikirim');
      return fotoWajah.value;
    } catch (e) {
      print('❌ Error take photo: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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
          'Foto tidak mengandung wajah yang jelas.\nApakah Anda ingin mengambil foto ulang?',
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
            child: const Text('Foto Ulang'),
          ),
        ],
      ),
    );

    return completer.future;
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

  // ================= SUBMIT ABSENSI DENGAN FOTO =================
  Future<bool> submitAbsensi(
    String lokasiId,
    String lokasiNama,
    String koordinatLokasi,
  ) async {
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

      // Parse koordinat lokasi
      LatLng? lokasiLatLng;
      try {
        final parts = koordinatLokasi.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            lokasiLatLng = LatLng(lat, lng);
          }
        }
      } catch (e) {
        print('Error parsing koordinat lokasi: $e');
      }

      if (lokasiLatLng == null) {
        Get.snackbar(
          'Error',
          'Koordinat lokasi tidak valid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Tampilkan dialog konfirmasi lokasi
      bool lanjutkan = await _showLocationConfirmDialog();

      if (!lanjutkan) {
        isLoading.value = false;
        return false;
      }

      // Ambil lokasi real-time pengguna
      String titikKoordinatKamu = await getCurrentLocation();

      if (titikKoordinatKamu.isEmpty) {
        Get.snackbar(
          'Error',
          'Gagal mendapatkan lokasi Anda',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Parse koordinat kamu
      LatLng? kamuLatLng;
      try {
        final parts = titikKoordinatKamu.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            kamuLatLng = LatLng(lat, lng);
          }
        }
      } catch (e) {
        print('Error parsing koordinat kamu: $e');
      }

      if (kamuLatLng == null) {
        Get.snackbar(
          'Error',
          'Koordinat kamu tidak valid',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Hitung jarak antara lokasi absensi dan posisi kamu
      double jarakMeter = _hitungJarakDalamMeter(lokasiLatLng, kamuLatLng);

      print('📏 Jarak: ${jarakMeter.toStringAsFixed(2)} meter');

      // VALIDASI JARAK: WAJIB maksimal 100 meter
      const double batasMaksimal = 100.0; // 100 meter

      if (jarakMeter > batasMaksimal) {
        // Tampilkan dialog error jarak terlalu jauh
        await _showJarakTerlaluJauhDialog(jarakMeter, batasMaksimal);
        return false; // Gagal absen
      }

      // AMBIL FOTO DAN DETEKSI WAJAH
      File? foto = await takePhotoWithFaceDetection();

      if (foto == null) {
        // User membatalkan pengambilan foto
        Get.snackbar(
          'Info',
          'Absen dibatalkan',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Kirim data dengan foto
      return await _submitWithPhoto(
        lokasiIdInt,
        lokasiNama,
        titikKoordinatKamu,
        foto,
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
      fotoWajah.value = null; // Reset foto setelah selesai
    }
  }

  // ================= KIRIM ABSENSI DENGAN FOTO =================
  Future<bool> _submitWithPhoto(
    int lokasiIdInt,
    String lokasiNama,
    String titikKoordinatKamu,
    File foto,
  ) async {
    try {
      // Buat request multipart untuk mengirim file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/absensi'),
      );

      // Tambahkan headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      });

      // Tambahkan fields
      request.fields['lokasi_id'] = lokasiIdInt.toString();
      request.fields['titik_koordinat_kamu'] = titikKoordinatKamu;

      // Tambahkan file foto
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_wajah',
          foto.path,
          filename: 'absensi_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      print('📤 Mengirim request dengan foto...');
      print('📍 Lokasi ID: $lokasiIdInt');
      print('📍 Koordinat: $titikKoordinatKamu');
      print('📸 Foto: ${foto.path}');

      // Kirim request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Absensi dengan foto berhasil!');

        Get.snackbar(
          'Berhasil',
          'Absensi di $lokasiNama berhasil dengan foto',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
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

  // Fungsi untuk menghitung jarak antara dua titik koordinat (dalam meter)
  double _hitungJarakDalamMeter(LatLng titik1, LatLng titik2) {
    const double R = 6371; // Radius bumi dalam km

    double lat1 = titik1.latitude * pi / 180;
    double lat2 = titik2.latitude * pi / 180;
    double deltaLat = (titik2.latitude - titik1.latitude) * pi / 180;
    double deltaLng = (titik2.longitude - titik1.longitude) * pi / 180;

    double a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanceKm = R * c;

    return distanceKm * 1000; // Kembalikan dalam meter
  }

  // ================= DIALOG KONFIRMASI LOKASI =================
  Future<bool> _showLocationConfirmDialog() async {
    Completer<bool> completer = Completer<bool>();

    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Lokasi'),
        content: const Text(
          'Aplikasi akan mengakses lokasi Anda saat ini untuk verifikasi jarak dengan lokasi absensi. Lanjutkan?',
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
            Text(
              'Jarak antara lokasi absensi dan posisi Anda adalah $jarakFormat',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Batas maksimal yang diizinkan adalah ${batas.toStringAsFixed(0)} meter',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Anda tidak dapat melakukan absensi karena berada terlalu jauh dari lokasi yang ditentukan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('MENGERTI'),
          ),
        ],
      ),
    );
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
    fotoWajah.value = null;
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
    print('Foto tersedia: ${fotoWajah.value != null}');
    print('Loading: $isLoading');
    print('=' * 50);
  }
}
