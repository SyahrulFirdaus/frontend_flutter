// lib/pages/admin/widgets/admin_riwayat/admin_user_header_widget.dart

import 'package:flutter/material.dart';

class AdminUserHeaderWidget extends StatelessWidget {
  final String userName;
  final int totalDays;

  const AdminUserHeaderWidget({
    super.key,
    required this.userName,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            userName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '$totalDays hari',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
