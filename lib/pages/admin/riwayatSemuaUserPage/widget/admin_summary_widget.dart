// lib/pages/admin/widgets/admin_riwayat/admin_summary_widget.dart

import 'package:flutter/material.dart';

class AdminSummaryWidget extends StatelessWidget {
  final int totalUser;
  final int totalAbsensi;
  final int hariAktif;

  const AdminSummaryWidget({
    super.key,
    required this.totalUser,
    required this.totalAbsensi,
    required this.hariAktif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.people,
            value: totalUser.toString(),
            label: 'Total User',
            color: Colors.blue,
          ),
          Container(height: 30, width: 1, color: Colors.blue.shade200),
          _buildSummaryItem(
            icon: Icons.fingerprint,
            value: totalAbsensi.toString(),
            label: 'Total Absensi',
            color: Colors.green,
          ),
          Container(height: 30, width: 1, color: Colors.blue.shade200),
          _buildSummaryItem(
            icon: Icons.today,
            value: hariAktif.toString(),
            label: 'Hari Aktif',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
