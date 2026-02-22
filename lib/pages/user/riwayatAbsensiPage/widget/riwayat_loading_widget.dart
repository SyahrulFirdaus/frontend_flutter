// lib/pages/user/widgets/riwayat/riwayat_loading_widget.dart

import 'package:flutter/material.dart';

class RiwayatLoadingWidget extends StatelessWidget {
  const RiwayatLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat riwayat absensi...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
