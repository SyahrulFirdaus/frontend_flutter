import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../controllers/pusat_lokasi_controller.dart';
import 'pilih_lokasi_modal.dart'; // Import modal baru

class TambahPusatLokasiModal {
  static void show(BuildContext context, PusatLokasiController controller) {
    final namaLokasiC = TextEditingController();
    final titikKordinatC = TextEditingController();
    final alamatC = TextEditingController(); // Field baru untuk alamat
    final formKey = GlobalKey<FormState>();

    // Untuk preview map
    GoogleMapController? mapController;
    LatLng? selectedLocation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Center(
                    child: Text(
                      'Tambah Pusat Lokasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Nama Lokasi
                  TextFormField(
                    controller: namaLokasiC,
                    decoration: InputDecoration(
                      labelText: 'Nama Lokasi *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.place, color: Colors.blue),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lokasi wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Form Titik Kordinat dengan tombol pilih lokasi
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: titikKordinatC,
                          readOnly:
                              true, // Read-only karena akan diisi dari modal
                          decoration: InputDecoration(
                            labelText: 'Titik Kordinat *',
                            hintText: 'Pilih lokasi di maps',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Titik kordinat wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.map, color: Colors.white),
                          onPressed: () async {
                            // Buka modal pilih lokasi
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PilihLokasiModal(
                                  onLocationPicked: (koordinat, alamat) {
                                    // Isi form dengan hasil dari modal
                                    titikKordinatC.text = koordinat;
                                    alamatC.text = alamat;

                                    // Parse untuk preview map
                                    try {
                                      final parts = koordinat.split(',');
                                      if (parts.length == 2) {
                                        final lat = double.tryParse(
                                          parts[0].trim(),
                                        );
                                        final lng = double.tryParse(
                                          parts[1].trim(),
                                        );
                                        if (lat != null && lng != null) {
                                          selectedLocation = LatLng(lat, lng);
                                        }
                                      }
                                    } catch (e) {
                                      print('Error parsing: $e');
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          tooltip: 'Pilih Lokasi',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Preview Map (jika koordinat sudah dipilih)
                  if (selectedLocation != null) ...[
                    const Text(
                      'Preview Lokasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: selectedLocation!,
                            zoom: 14,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                          markers: {
                            Marker(
                              markerId: const MarkerId('selected_location'),
                              position: selectedLocation!,
                              infoWindow: InfoWindow(
                                title: namaLokasiC.text.isEmpty
                                    ? 'Lokasi Baru'
                                    : namaLokasiC.text,
                              ),
                            ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          compassEnabled: true,
                          mapToolbarEnabled: false,
                          gestureRecognizers: const {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Alamat Lengkap (field baru)
                  TextFormField(
                    controller: alamatC,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap',
                      hintText: 'Alamat akan terisi otomatis dari maps',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.location_city,
                        color: Colors.blue,
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Keterangan (opsional)
                  TextFormField(
                    controller:
                        alamatC, // Bisa diganti dengan field keterangan terpisah
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Keterangan (Opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.description,
                        color: Colors.blue,
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          final isLoading = controller.isSubmitting.value;
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      Navigator.pop(context);

                                      final success = await controller
                                          .createPusatLokasi(
                                            namaLokasi: namaLokasiC.text.trim(),
                                            titikKordinat: titikKordinatC.text
                                                .trim(),
                                            keterangan:
                                                alamatC.text.trim().isEmpty
                                                ? null
                                                : alamatC.text.trim(),
                                          );

                                      if (success) {
                                        Get.snackbar(
                                          'Berhasil',
                                          'Data berhasil ditambahkan',
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.TOP,
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isLoading ? 'Menyimpan...' : 'Simpan'),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
