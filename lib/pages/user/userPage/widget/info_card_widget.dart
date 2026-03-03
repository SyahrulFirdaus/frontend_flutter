// // lib/pages/user/widgets/info_card_widget.dart

// import 'package:flutter/material.dart';

// class InfoCardWidget extends StatelessWidget {
//   const InfoCardWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.info_outline,
//               color: Colors.blue.shade700,
//               size: 16,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'Sistem akan otomatis mendeteksi lokasi terdekat Anda. '
//               'Pastikan GPS aktif dan Anda berada dalam radius 100 meter '
//               'dari lokasi absensi. Foto wajah akan diambil sebagai bukti.',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.blue.shade700,
//                 height: 1.3,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  const InfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sistem otomatis mendeteksi lokasi terdekat. GPS aktif dan radius 100m. Foto wajah sebagai bukti.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
