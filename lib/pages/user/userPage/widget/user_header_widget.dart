// lib/pages/user/widgets/user_header_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_lokasi_controller.dart';

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildProfileInitial(),
          const SizedBox(width: 12),
          _buildUserInfo(),
          _buildRefreshButton(),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileInitial() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade100],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          (user['name'] != null && user['name'].toString().isNotEmpty)
              ? user['name'].toString()[0].toUpperCase()
              : 'U',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang,',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          Text(
            user['name']?.toString() ?? 'User',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              user['email']?.toString() ?? '',
              style: const TextStyle(fontSize: 10, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white),
        onPressed: () {
          lokasiController.cekStatusHariIni();
          lokasiController.fetchUserLokasi();
          Get.snackbar(
            'Sukses',
            'Data berhasil di-refresh',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 1),
          );
        },
        tooltip: 'Refresh Data',
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: onLogout,
      ),
    );
  }
}
