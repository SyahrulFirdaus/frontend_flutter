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
      'http://192.168.95.243:8000/api'; // Sesuaikan dengan IP Anda
  // final String baseUrl = 'http://10.0.2.2:8000/api'; // Sesuaikan dengan IP Anda

  var userLokasis = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSubmitting = false.obs;
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

  // Untuk deteksi lokasi otomatis (hanya digunakan saat absen)
  var lokasiTerpilih = Rxn<Map<String, dynamic>>();
  var jarakTerdekat = 0.0.obs;
  var isInRange = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🟢 UserLokasiController diinisialisasi');
    // Hanya cek status, tidak fetch lokasi
    cekStatusHariIni();
  }

  // ================= CEK STATUS ABSEN HARI INI =================
  Future<void> cekStatusHariIni() async {
    try {
      print('📌 Cek status absen hari ini...');

      if (auth.token.isEmpty) {
        print('⚠️ Token kosong');
        return;
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/absensi/cek-status'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 5));

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
      print('📌 FETCH USER LOKASI - DIMULAI');

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/lokasi'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.token}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is List) {
          userLokasis.value = List<Map<String, dynamic>>.from(data);
          print('✅ Lokasi ditemukan: ${userLokasis.length} data');

          if (userLokasis.isEmpty) {
            errorMessage.value = 'Belum ada lokasi yang ditentukan untuk Anda';
          }
        } else {
          userLokasis.value = [];
          errorMessage.value = 'Format data tidak sesuai';
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Sesi habis, silahkan login ulang';
        Future.delayed(const Duration(seconds: 2), () => auth.logout());
      } else {
        errorMessage.value = 'Error ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
    } finally {
      isLoading.value = false;
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
        timeLimit: const Duration(seconds: 10),
      );

      String koordinat = '${position.latitude}, ${position.longitude}';
      lokasiSaatIni.value = koordinat;
      return koordinat;
    } catch (e) {
      print('❌ Error getCurrentLocation: $e');
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi Anda. Pastikan GPS aktif.',
        backgroundColor: Colors.red,
      );
      return '';
    } finally {
      isGettingLocation.value = false;
    }
  }

  // ================= HITUNG JARAK (Haversine Formula) =================
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

  // ================= CARI LOKASI TERDEKAT =================
  Future<Map<String, dynamic>?> cariLokasiTerdekat(String koordinatUser) async {
    // Pastikan data lokasi tersedia
    if (userLokasis.isEmpty) {
      await fetchUserLokasi();
    }

    if (userLokasis.isEmpty) {
      Get.snackbar(
        'Error',
        'Anda belum memiliki lokasi absensi. Hubungi admin.',
        backgroundColor: Colors.red,
      );
      return null;
    }

    try {
      final userParts = koordinatUser.split(',');
      if (userParts.length != 2) return null;

      final userLat = double.tryParse(userParts[0].trim());
      final userLng = double.tryParse(userParts[1].trim());

      if (userLat == null || userLng == null) return null;

      final userLatLng = LatLng(userLat, userLng);

      List<Map<String, dynamic>> lokasiDenganJarak = [];

      for (var lokasi in userLokasis) {
        final lokasiParts = lokasi['koordinat'].split(',');
        if (lokasiParts.length != 2) continue;

        final lokasiLat = double.tryParse(lokasiParts[0].trim());
        final lokasiLng = double.tryParse(lokasiParts[1].trim());

        if (lokasiLat == null || lokasiLng == null) continue;

        final lokasiLatLng = LatLng(lokasiLat, lokasiLng);
        final jarak = _hitungJarakDalamMeter(userLatLng, lokasiLatLng);

        lokasiDenganJarak.add({
          'id': lokasi['id'],
          'lokasi': lokasi['lokasi'],
          'koordinat': lokasi['koordinat'],
          'jarak': jarak,
          'dalam_radius': jarak <= 100,
        });
      }

      // Urutkan berdasarkan jarak terdekat
      lokasiDenganJarak.sort((a, b) => a['jarak'].compareTo(b['jarak']));

      if (lokasiDenganJarak.isNotEmpty) {
        lokasiTerpilih.value = lokasiDenganJarak.first;
        jarakTerdekat.value = lokasiDenganJarak.first['jarak'];
        isInRange.value = lokasiDenganJarak.first['dalam_radius'];

        print('📍 Lokasi terdekat: ${lokasiTerpilih.value!['lokasi']}');
        print('📏 Jarak: ${jarakTerdekat.value.toStringAsFixed(2)} meter');
        print('✅ Dalam radius: $isInRange');
      }

      return lokasiDenganJarak.first;
    } catch (e) {
      print('❌ Error cari lokasi terdekat: $e');
      return null;
    }
  }

  // ================= PROSES ABSENSI (DIPANGGIL SAAT KLIK TOMBOL) =================
  Future<void> prosesAbsensi(String tipe) async {
    // CEK STATUS
    if (tipe == 'masuk' && sudahMasuk.value) {
      Get.snackbar(
        'Info',
        'Anda sudah absen masuk hari ini',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (tipe == 'pulang' && sudahPulang.value) {
      Get.snackbar(
        'Info',
        'Anda sudah absen pulang hari ini',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (tipe == 'pulang' && !sudahMasuk.value) {
      Get.snackbar(
        'Info',
        'Anda harus absen masuk terlebih dahulu',
        backgroundColor: Colors.orange,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // 1. AMBIL LOKASI GPS
      String titikKoordinatKamu = await getCurrentLocation();
      if (titikKoordinatKamu.isEmpty) {
        return;
      }

      // 2. CARI LOKASI TERDEKAT
      final lokasiTerdekat = await cariLokasiTerdekat(titikKoordinatKamu);

      if (lokasiTerdekat == null) {
        return;
      }

      // 3. CEK APAKAH DALAM RADIUS
      if (!lokasiTerdekat['dalam_radius']) {
        await _showJarakTerlaluJauhDialog(
          lokasiTerdekat['jarak'],
          lokasiTerdekat['lokasi'],
        );
        return;
      }

      // 4. AMBIL FOTO
      File? foto = await takePhotoWithFaceDetection();
      if (foto == null) {
        Get.snackbar(
          'Info',
          'Absen dibatalkan',
          backgroundColor: Colors.orange,
        );
        return;
      }

      // 5. KIRIM KE SERVER
      bool success = await _kirimAbsensiOtomatis(
        lokasiTerdekat,
        titikKoordinatKamu,
        foto,
        tipe,
      );

      if (success) {
        // 6. TAMPILKAN DIALOG SUKSES
        _showSuccessDialog(tipe, lokasiTerdekat);
      }
    } catch (e) {
      print('❌ Error proses absensi: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ================= KIRIM ABSENSI OTOMATIS KE SERVER =================
  Future<bool> _kirimAbsensiOtomatis(
    Map<String, dynamic> lokasiTerpilih,
    String titikKoordinatKamu,
    File foto,
    String tipe,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/absensi/otomatis'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      });

      request.fields['tipe_absen'] = tipe;
      request.fields['titik_koordinat_kamu'] = titikKoordinatKamu;

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_wajah',
          foto.path,
          filename: '${tipe}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      print('📤 Mengirim request absensi otomatis $tipe...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          '❌ Gagal',
          errorData['message'] ?? 'Anda berada di luar jangkauan absen',
          backgroundColor: Colors.red,
        );
        return false;
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

  // ================= DIALOG SUKSES =================
  void _showSuccessDialog(String tipe, Map<String, dynamic> lokasiTerpilih) {
    Get.dialog(
      AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Absen $tipe Berhasil!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Anda telah absen $tipe di:'),
            const SizedBox(height: 4),
            Text(
              lokasiTerpilih['lokasi'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Jarak: ${lokasiTerpilih['jarak'].toStringAsFixed(1)} meter',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Waktu: ${DateTime.now().toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              cekStatusHariIni(); // Refresh status
              fetchUserLokasi(); // Refresh lokasi
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ================= DIALOG JARAK TERLALU JAUH =================
  // Future<void> _showJarakTerlaluJauhDialog(
  //   double jarak,
  //   String lokasiTerdekat,
  // ) async {
  //   String jarakFormat = jarak < 1000
  //       ? '${jarak.toStringAsFixed(1)} meter'
  //       : '${(jarak / 1000).toStringAsFixed(2)} km';

  //   return Get.dialog(
  //     AlertDialog(
  //       title: const Icon(
  //         Icons.warning_amber_rounded,
  //         color: Colors.red,
  //         size: 40,
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text(
  //             'Jarak Terlalu Jauh',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.red,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Text('Lokasi terdekat: $lokasiTerdekat'),
  //           const SizedBox(height: 4),
  //           Text('Jarak Anda $jarakFormat'),
  //           const SizedBox(height: 8),
  //           const Text(
  //             'Batas maksimal 100 meter',
  //             style: TextStyle(color: Colors.red),
  //           ),
  //           const SizedBox(height: 16),
  //           const Text('Anda tidak dapat melakukan absensi.'),
  //         ],
  //       ),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () => Get.back(),
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           child: const Text('MENGERTI'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ================= DIALOG JARAK TERLALU JAUH =================
  Future<void> _showJarakTerlaluJauhDialog(
    double jarak,
    String lokasiTerdekat,
  ) async {
    String jarakFormat = jarak < 1000
        ? '${jarak.toStringAsFixed(1)} meter'
        : '${(jarak / 1000).toStringAsFixed(2)} km';

    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Anda tidak bisa absen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                'Anda di luar jangkauan absen',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),

              // Jarak info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Batas maksimal 100 meter',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Detail jarak
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Lokasi terdekat: $lokasiTerdekat',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jarak Anda $jarakFormat',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'MENGERTI',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    lokasiTerpilih.value = null;
    jarakTerdekat.value = 0.0;
    isInRange.value = false;
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
    print('Submitting: $isSubmitting');
    print('=' * 50);
  }
}
