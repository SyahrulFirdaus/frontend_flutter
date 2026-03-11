// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../controllers/user_lokasi_controller.dart';
// import '../../modals/daftar_lokasi_modal.dart';

// class UserHeaderWidget extends StatelessWidget {
//   final Map<String, dynamic> user;
//   final UserLokasiController lokasiController;
//   final VoidCallback onLogout;

//   const UserHeaderWidget({
//     super.key,
//     required this.user,
//     required this.lokasiController,
//     required this.onLogout,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Profile Avatar dengan inisial
//           _buildProfileInitial(),
//           const SizedBox(width: 12),

//           // User Info
//           _buildUserInfo(),

//           const Spacer(),

//           // Indikator Lokasi (BISA DI KLIK)
//           _buildLocationIndicator(context),

//           const SizedBox(width: 8),

//           // Refresh Button
//           _buildRefreshButton(),

//           const SizedBox(width: 8),

//           // Logout Button
//           _buildLogoutButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileInitial() {
//     return Container(
//       width: 48,
//       height: 48,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [Colors.blue, Colors.blue.shade300]),
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Text(
//           (user['name'] != null && user['name'].toString().isNotEmpty)
//               ? user['name'].toString()[0].toUpperCase()
//               : 'U',
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserInfo() {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Selamat Datang,',
//             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//           ),
//           Text(
//             user['name']?.toString() ?? 'User',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationIndicator(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (lokasiController.userLokasis.isNotEmpty) {
//           DaftarLokasiModal.show(context, lokasiController);
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.blue[50],
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.blue[100]!),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.location_on, size: 14, color: Colors.blue[600]),
//             const SizedBox(width: 4),
//             Obx(() {
//               final total = lokasiController.userLokasis.length;
//               return Text(
//                 total > 0 ? '$total' : '0',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.blue[700],
//                 ),
//               );
//             }),
//             const SizedBox(width: 2),
//             Icon(Icons.chevron_right, size: 14, color: Colors.blue[400]),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRefreshButton() {
//     return Obx(
//       () => Container(
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: IconButton(
//           icon: lokasiController.isLoading.value
//               ? SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Colors.blue[600]!,
//                     ),
//                   ),
//                 )
//               : Icon(Icons.refresh, color: Colors.blue[600], size: 20),
//           onPressed: lokasiController.isLoading.value
//               ? null
//               : () {
//                   lokasiController.cekStatusHariIni();
//                   lokasiController.fetchUserLokasi();
//                   Get.snackbar(
//                     'Sukses',
//                     'Data diperbarui',
//                     backgroundColor: Colors.green,
//                     colorText: Colors.white,
//                     snackPosition: SnackPosition.TOP,
//                     duration: const Duration(seconds: 1),
//                   );
//                 },
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
//           tooltip: 'Refresh',
//         ),
//       ),
//     );
//   }

//   Widget _buildLogoutButton() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.red[50],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: IconButton(
//         icon: Icon(Icons.logout, color: Colors.red[600], size: 20),
//         onPressed: onLogout,
//         padding: EdgeInsets.zero,
//         constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
//         tooltip: 'Logout',
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';
import '../../modals/daftar_lokasi_modal.dart';

class UserHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  final UserLokasiController lokasiController;
  final VoidCallback onLogout;

  const UserHeaderWidget({
    super.key,
    required this.user,
    required this.lokasiController,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: isWeb ? 56 : 48,
            height: isWeb ? 56 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade300],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user['name'] != null && user['name'].toString().isNotEmpty)
                    ? user['name'].toString()[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: isWeb ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  user['name']?.toString() ?? 'User',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Location Indicator
          if (!isWeb) // Sembunyikan di web karena sudah ada di grid
            _buildLocationIndicator(context),

          const SizedBox(width: 8),

          // Refresh Button
          _buildRefreshButton(isWeb),

          const SizedBox(width: 8),

          // Logout Button
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildLocationIndicator(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (lokasiController.userLokasis.isNotEmpty) {
          DaftarLokasiModal.show(context, lokasiController);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.blue[600]),
            const SizedBox(width: 4),
            Obx(() {
              final total = lokasiController.userLokasis.length;
              return Text(
                total > 0 ? '$total' : '0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton(bool isWeb) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: lokasiController.isLoading.value
              ? SizedBox(
                  width: isWeb ? 24 : 20,
                  height: isWeb ? 24 : 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[600]!,
                    ),
                  ),
                )
              : Icon(
                  Icons.refresh,
                  color: Colors.blue[600],
                  size: isWeb ? 22 : 20,
                ),
          onPressed: lokasiController.isLoading.value
              ? null
              : () {
                  lokasiController.cekStatusHariIni();
                  lokasiController.fetchUserLokasi();
                  Get.snackbar(
                    'Sukses',
                    'Data diperbarui',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 1),
                  );
                },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'Refresh',
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(Icons.logout, color: Colors.red[600], size: 20),
        onPressed: onLogout,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        tooltip: 'Logout',
      ),
    );
  }
}
