// lib/pages/admin/widgets/lokasi/lokasi_entry_item.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../controllers/lokasi_controller.dart';

class LokasiEntryItem extends StatefulWidget {
  final int index;
  final LokasiController controller;

  const LokasiEntryItem({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  State<LokasiEntryItem> createState() => _LokasiEntryItemState();
}

class _LokasiEntryItemState extends State<LokasiEntryItem> {
  late TextEditingController lokasiController;
  late TextEditingController koordinatController;

  @override
  void initState() {
    super.initState();
    final entry = widget.controller.multipleLokasiEntries[widget.index];
    lokasiController = TextEditingController(
      text: entry['lokasi']?.value ?? '',
    );
    koordinatController = TextEditingController(
      text: entry['koordinat']?.value ?? '',
    );
  }

  @override
  void dispose() {
    lokasiController.dispose();
    koordinatController.dispose();
    super.dispose();
  }

  LatLng? _parseKoordinat(String koordinatStr) {
    try {
      final parts = koordinatStr.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      print('Error parsing koordinat: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entry = widget.controller.multipleLokasiEntries[widget.index];
      final lokasi = entry['lokasi'] as RxString;
      final koordinat = entry['koordinat'] as RxString;
      final isValid = entry['isValid'] as RxBool;

      final mapLocation = koordinat.value.isNotEmpty
          ? _parseKoordinat(koordinat.value)
          : null;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isValid.value ? Colors.green.shade200 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildHeader(isValid.value),
              const SizedBox(height: 12),
              _buildLokasiField(),
              const SizedBox(height: 8),
              _buildKoordinatField(),
              if (mapLocation != null)
                _buildMapPreview(mapLocation, lokasi.value),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isValid) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isValid ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isValid ? 'Entry Valid' : 'Belum Lengkap',
            style: TextStyle(
              color: isValid ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (widget.controller.multipleLokasiEntries.length > 1)
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => widget.controller.removeLokasiEntry(widget.index),
          ),
      ],
    );
  }

  Widget _buildLokasiField() {
    return TextField(
      controller: lokasiController,
      decoration: InputDecoration(
        labelText: 'Lokasi ${widget.index + 1}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        prefixIcon: const Icon(Icons.place, size: 20),
      ),
      onChanged: (value) {
        widget.controller.updateLokasiEntry(widget.index, 'lokasi', value);
      },
    );
  }

  Widget _buildKoordinatField() {
    return TextField(
      controller: koordinatController,
      decoration: InputDecoration(
        labelText: 'Koordinat ${widget.index + 1}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        prefixIcon: const Icon(Icons.location_on, size: 20),
        hintText: 'Contoh: -6.893361, 107.602376',
      ),
      onChanged: (value) {
        widget.controller.updateLokasiEntry(widget.index, 'koordinat', value);
      },
    );
  }

  Widget _buildMapPreview(LatLng mapLocation, String lokasiValue) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: mapLocation,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('preview_${widget.index}'),
                  position: mapLocation,
                  infoWindow: InfoWindow(
                    title: lokasiValue.isEmpty
                        ? 'Lokasi ${widget.index + 1}'
                        : lokasiValue,
                  ),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              gestureRecognizers: const {},
            ),
          ),
        ),
      ],
    );
  }
}
