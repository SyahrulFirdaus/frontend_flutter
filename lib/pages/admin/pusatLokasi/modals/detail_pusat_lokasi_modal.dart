import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/pusat_lokasi_model.dart';

class DetailPusatLokasiModal {
  static void show(BuildContext context, PusatLokasiModel item) {
    GoogleMapController? mapController;

    final bool hasValidKoordinat = item.isKordinatValid;
    final LatLng? location = hasValidKoordinat
        ? LatLng(item.latitude!, item.longitude!)
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Lokasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Informasi lengkap pusat lokasi',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Tombol close
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.place,
                      label: 'Nama Lokasi',
                      value: item.namaLokasi,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),

                    _buildInfoItem(
                      icon: Icons.location_on,
                      label: 'Titik Kordinat',
                      value: item.titikKordinat,
                      color: Colors.green,
                      valueWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            item.titikKordinat,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hasValidKoordinat
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasValidKoordinat
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  size: 12,
                                  color: hasValidKoordinat
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasValidKoordinat
                                      ? 'Koordinat Valid'
                                      : 'Format Koordinat Tidak Valid',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: hasValidKoordinat
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasValidKoordinat) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Latitude: ${item.latitude!.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Longitude: ${item.longitude!.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoItem(
                      icon: Icons.description,
                      label: 'Keterangan / Alamat',
                      value: item.keterangan ?? '-',
                      color: Colors.purple,
                    ),

                    const SizedBox(height: 24),

                    if (hasValidKoordinat) ...[
                      const Text(
                        'Preview Lokasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: location!,
                                  zoom: 16,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller;
                                },
                                markers: {
                                  Marker(
                                    markerId: MarkerId('detail_${item.id}'),
                                    position: location,
                                    infoWindow: InfoWindow(
                                      title: item.namaLokasi,
                                      snippet: item.titikKordinat,
                                    ),
                                  ),
                                },
                                zoomControlsEnabled: true,
                                myLocationButtonEnabled: false,
                                compassEnabled: true,
                                mapToolbarEnabled: false,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          mapController?.animateCamera(
                                            CameraUpdate.zoomIn(),
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                      Container(
                                        height: 1,
                                        width: 30,
                                        color: Colors.grey.shade300,
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          mapController?.animateCamera(
                                            CameraUpdate.zoomOut(),
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openGoogleMaps(
                            item.latitude!,
                            item.longitude!,
                            item.namaLokasi,
                          ),
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Buka di Google Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Tampilan jika koordinat tidak valid
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.map,
                              size: 48,
                              color: Colors.orange.shade300,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Preview map tidak tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Koordinat tidak valid atau belum diisi dengan benar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildMetaRow(
                            icon: Icons.access_time,
                            label: 'Dibuat pada',
                            value: _formatDateTime(item.createdAt),
                          ),
                          const SizedBox(height: 12),
                          _buildMetaRow(
                            icon: Icons.update,
                            label: 'Terakhir diupdate',
                            value: _formatDateTime(item.updatedAt),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    Widget? valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              valueWidget ??
                  SelectableText(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const oneDay = Duration(days: 1);

    String day;
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      day = 'Hari ini';
    } else if (dateTime.day == now.day - 1 &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      day = 'Kemarin';
    } else {
      day =
          '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
    }

    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$day $time';
  }

  static Future<void> _openGoogleMaps(
    double lat,
    double lng,
    String namaLokasi,
  ) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$namaLokasi';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = 'https://www.google.com/maps?q=$lat,$lng';
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          _showError('Tidak dapat membuka Google Maps');
        }
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  static void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
