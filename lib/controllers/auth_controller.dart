// import 'dart:ui';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:frontend_flutter/models/mahasiswa_model.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthController extends GetxController {
//   static AuthController instance = Get.find();
//   var mahasiswaList = <Mahasiswa>[].obs;
//   var isLoading = false.obs;

//   var user = {}.obs;
//   var token = ''.obs;

//   final baseUrl = "http://10.0.2.2:8000/api";

//   // final alamat = "http://10.0.2.2:8000/api/mahasiswa";
//   // TODO REGISTER
//   Future<void> register(
//     String name,
//     String email,
//     String password,
//     String role,
//   ) async {
//     isLoading.value = true;
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl/register'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               "name": name,
//               "email": email,
//               "password": password,
//               "role": role,
//             }),
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Register success, please login');
//       } else {
//         var data = jsonDecode(response.body);
//         Get.snackbar('Error', data['message'] ?? 'Register failed');
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // TODO LOGIN
//   Future<void> login(String email, String password) async {
//     isLoading.value = true;
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl/login'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({"email": email, "password": password}),
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         token.value = data['access_token'];
//         user.value = data['user'];

//         if (user['role'] == 'admin') {
//           Get.offAllNamed('/admin');
//         } else {
//           Get.offAllNamed('/user');
//         }
//       } else {
//         var data = jsonDecode(response.body);
//         Get.snackbar('Error', data['message'] ?? 'Login gagal');
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // TODO LOGOUT
//   void logout() {
//     token.value = '';
//     user.value = {};
//     Get.offAllNamed('/login');
//   }

//   // TODO FETCH CUTI USER
//   Future<List<dynamic>> fetchUserLeaves() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$baseUrl/leave/user'),
//             headers: {
//               'Authorization': 'Bearer ${token.value}',
//               'Content-Type': 'application/json',
//             },
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         return List<dynamic>.from(jsonDecode(response.body));
//       } else {
//         Get.snackbar('Error', 'Gagal mengambil data cuti');
//         return [];
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//       return [];
//     }
//   }

//   // AJUKAN CUTI
//   Future<bool> submitLeave(
//     String startDate,
//     String endDate,
//     String reason,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$baseUrl/leave'),
//             headers: {
//               'Authorization': 'Bearer ${token.value}',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode({
//               'start_date': startDate,
//               'end_date': endDate,
//               'reason': reason,
//             }),
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Pengajuan cuti berhasil dikirim');
//         return true;
//       } else {
//         var data = jsonDecode(response.body);
//         Get.snackbar('Error', data['message'] ?? 'Gagal kirim pengajuan');
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//       return false;
//     }
//   }

//   // ADMIN - FETCH SEMUA CUTI
//   Future<List<dynamic>> fetchAllLeaves() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$baseUrl/leave'),
//             headers: {
//               'Authorization': 'Bearer ${token.value}',
//               'Content-Type': 'application/json',
//             },
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         return List<dynamic>.from(jsonDecode(response.body));
//       } else {
//         Get.snackbar('Error', 'Gagal mengambil data pengajuan cuti');
//         return [];
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//       return [];
//     }
//   }

//   // ADMIN - UPDATE STATUS CUTI
//   Future<bool> updateLeaveStatus(int leaveId, String status) async {
//     try {
//       final response = await http
//           .patch(
//             Uri.parse('$baseUrl/leave/$leaveId'),
//             headers: {
//               'Authorization': 'Bearer ${token.value}',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode({'status': status}),
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         Get.snackbar('Success', 'Status pengajuan berhasil diperbarui');
//         return true;
//       } else {
//         var data = jsonDecode(response.body);
//         Get.snackbar('Error', data['message'] ?? 'Gagal update status');
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//       return false;
//     }
//   }

//   // JUMLAH CUTI PENDING
//   var pendingLeaveCount = 0.obs;

//   Future<void> fetchPendingLeaveCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$baseUrl/leave/pending-count'),
//             headers: {
//               'Authorization': 'Bearer ${token.value}',
//               'Content-Type': 'application/json',
//             },
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         pendingLeaveCount.value = data['pending_count'] ?? 0;
//       } else {
//         pendingLeaveCount.value = 0;
//       }
//     } catch (e) {
//       pendingLeaveCount.value = 0;
//       Get.snackbar('Error', e.toString());
//     }
//   }

//   // TODO Mahasiswa
//   // FETCH CUTI USER
//   // Future<List<dynamic>> fetchMahasiswa() async {
//   //   try {
//   //     final response = await http
//   //         .get(
//   //           Uri.parse('$baseUrl/mahasiswa'),
//   //           headers: {
//   //             'Authorization': 'Bearer ${token.value}',
//   //             'Content-Type': 'application/json',
//   //           },
//   //         )
//   //         .timeout(const Duration(seconds: 30));

//   //     if (response.statusCode == 200) {
//   //       return List<dynamic>.from(jsonDecode(response.body));
//   //     } else {
//   //       Get.snackbar('Error', 'Gagal mengambil data cuti');
//   //       return [];
//   //     }
//   //   } catch (e) {
//   //     Get.snackbar('Error', e.toString());
//   //     return [];
//   //   }
//   // }

//   // s
//   // Future<List<Mahasiswa>> fetchMahasiswa() async {
//   //   final response = await http.get(Uri.parse('$baseUrl/mahasiswa'));
//   //   if (response.statusCode == 200) {
//   //     final jsonResponse = json.decode(response.body);
//   //     final data = jsonResponse['data']; // ambil array dari key "data"
//   //     return List<Mahasiswa>.from(data.map((e) => Mahasiswa.fromJson(e)));
//   //   } else {
//   //     throw Exception('Gagal mengambil data');
//   //   }
//   // }
//   Future<List<Mahasiswa>> fetchMahasiswa() async {
//     try {
//       print("TOKEN: ${token.value}"); // Debug token
//       final response = await http.get(
//         Uri.parse('$baseUrl/mahasiswa'),
//         headers: {
//           'Authorization': 'Bearer ${token.value}',
//           'Content-Type': 'application/json',
//         },
//       );

//       print("STATUS: ${response.statusCode}");
//       print("BODY: ${response.body}");

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);

//         List data;
//         if (jsonResponse is Map && jsonResponse.containsKey('data')) {
//           data = jsonResponse['data'];
//         } else if (jsonResponse is List) {
//           data = jsonResponse;
//         } else {
//           data = [];
//         }

//         return data.map((e) => Mahasiswa.fromJson(e)).toList();
//       } else {
//         throw Exception(
//           'HTTP ${response.statusCode}: ${response.reasonPhrase}',
//         );
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//       return [];
//     }
//   }

//   var fcmToken = ''.obs;

//   Future<void> saveFcmToken() async {
//     fcmToken.value = await FirebaseMessaging.instance.getToken() ?? '';
//     // Kirim token ke backend untuk disimpan di user
//     await http.post(
//       Uri.parse('$baseUrl/save-fcm-token'),
//       headers: {
//         'Authorization': 'Bearer ${token.value}',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({'fcm_token': fcmToken.value}),
//     );
//   }

//   // TODO GOOGLE SIGN IN khusus USER
//   Future<void> signInWithGoogle() async {
//     isLoading.value = true;
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) {
//         isLoading.value = false;
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // TODO Login dengan Firebase
//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithCredential(credential);

//       final userData = userCredential.user;

//       if (userData != null) {
//         // TODO Ambil info user dari backend untuk token
//         final response = await http.post(
//           Uri.parse(
//             '$baseUrl/google-login',
//           ), // endpoint backend untuk Google login
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'email': userData.email,
//             'name': userData.displayName,
//           }),
//         );

//         if (response.statusCode == 200) {
//           var data = jsonDecode(response.body);
//           token.value = data['access_token'];
//           user.value = data['user'];

//           if (user['role'] == 'user') {
//             Get.offAllNamed('/user');
//           } else {
//             Get.snackbar('Error', 'Google Sign In hanya untuk user');
//           }
//         } else {
//           Get.snackbar('Error', 'Login gagal via Google');
//         }
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final box = GetStorage();
  final String baseUrl = 'http://10.0.2.2:8000/api';

  var isLoading = false.obs;
  var token = ''.obs;
  var user = {}.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔥 ambil data login lama (auto login)
    token.value = box.read('token') ?? '';
    user.value = box.read('user') ?? {};
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
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Sukses', 'Register berhasil, silahkan login');
        Get.back();
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

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        token.value = data['access_token'];
        user.value = data['user'];

        // 🔥 SIMPAN KE STORAGE
        box.write('token', token.value);
        box.write('user', user.value);

        // 🔥 REDIRECT SESUAI ROLE
        if (user['role'] == 'admin') {
          Get.offAllNamed('/admin');
        } else {
          Get.offAllNamed('/user');
        }
      } else {
        final err = jsonDecode(res.body);
        Get.snackbar('Error', err['message'] ?? 'Login gagal');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      if (token.isNotEmpty) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer ${token.value}',
            'Accept': 'application/json',
          },
        );
      }
    } catch (_) {
      // abaikan error logout
    } finally {
      // 🔥 CLEAR DATA
      token.value = '';
      user.value = {};
      box.erase();

      // Force close semua controller dan binding
      Get.deleteAll();

      Get.offAllNamed('/login');
    }
  }

  // ================= UTIL =================
  bool get isLoggedIn => token.isNotEmpty;
  bool get isAdmin => user['role'] == 'admin';
  bool get isUser => user['role'] == 'user';
}
