import 'package:flutter/material.dart';
import '../../../../utils/formatter_util.dart';

class RiwayatCardWidget extends StatelessWidget {
  final int index;
  final String tanggal;
  final Map<String, dynamic>? dataMasuk;
  final Map<String, dynamic>? dataPulang;
  final VoidCallback onTap;

  const RiwayatCardWidget({
    super.key,
    required this.index,
    required this.tanggal,
    required this.dataMasuk,
    required this.dataPulang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildNumberBadge(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent()),
              _buildStatusIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBadge() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.blue.shade700],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatterUtil.formatTanggal(tanggal),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dataMasuk != null ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Masuk',
              style: TextStyle(
                fontSize: 13,
                color: dataMasuk != null ? Colors.green : Colors.grey,
                fontWeight: dataMasuk != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (dataMasuk != null) ...[
              const SizedBox(width: 8),
              Text(
                FormatterUtil.formatJam(
                  dataMasuk!['waktu_absen']?.toString() ?? '',
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),

        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dataPulang != null ? Colors.orange : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Pulang',
              style: TextStyle(
                fontSize: 13,
                color: dataPulang != null ? Colors.orange : Colors.grey,
                fontWeight: dataPulang != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (dataPulang != null) ...[
              const SizedBox(width: 8),
              Text(
                FormatterUtil.formatJam(
                  dataPulang!['waktu_absen']?.toString() ?? '',
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    if (dataMasuk != null && dataPulang != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
      );
    } else if (dataMasuk != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.access_time, color: Colors.blue.shade400, size: 20),
      );
    }
    return const SizedBox.shrink();
  }
}
