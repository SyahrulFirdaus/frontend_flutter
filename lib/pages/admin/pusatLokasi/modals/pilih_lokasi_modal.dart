import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class PilihLokasiModal extends StatefulWidget {
  final Function(String koordinat, String alamat) onLocationPicked;
  final LatLng? initialLocation;

  const PilihLokasiModal({
    super.key,
    required this.onLocationPicked,
    this.initialLocation,
  });

  @override
  State<PilihLokasiModal> createState() => _PilihLokasiModalState();
}

class _PilihLokasiModalState extends State<PilihLokasiModal> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  Set<Marker> markers = {};
  String selectedAddress = '';
  bool isLoading = false;

  // Controller untuk search
  final TextEditingController searchController = TextEditingController();

  // Lokasi default (Indonesia)
  static const LatLng defaultLocation = LatLng(
    -6.208763,
    106.845599,
  ); // Jakarta

  @override
  void initState() {
    super.initState();
    // Set lokasi awal
    if (widget.initialLocation != null) {
      selectedLocation = widget.initialLocation;
      _getAddressFromLatLng(widget.initialLocation!);
    } else {
      selectedLocation = defaultLocation;
    }

    // Set marker awal
    _updateMarker();
  }

  @override
  void dispose() {
    mapController?.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Update marker berdasarkan lokasi yang dipilih
  void _updateMarker() {
    if (selectedLocation != null) {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: selectedLocation!,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              selectedLocation = newPosition;
              _getAddressFromLatLng(newPosition);
            });
          },
        ),
      );

      // Pindah kamera ke lokasi baru
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!, 16),
      );
    }
  }

  // Mendapatkan alamat dari koordinat (reverse geocoding)
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          selectedAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        selectedAddress = 'Alamat tidak ditemukan';
      });
    }
  }

  // Fungsi search lokasi (menggunakan geocoding)
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final firstLocation = locations.first;
        setState(() {
          selectedLocation = LatLng(
            firstLocation.latitude,
            firstLocation.longitude,
          );
          _updateMarker();
          _getAddressFromLatLng(selectedLocation!);
        });
      } else {
        Get.snackbar(
          'Info',
          'Lokasi tidak ditemukan',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error searching location: $e');
      Get.snackbar(
        'Error',
        'Gagal mencari lokasi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Tombol konfirmasi
          TextButton(
            onPressed: () {
              if (selectedLocation != null) {
                final koordinat =
                    '${selectedLocation!.latitude}, ${selectedLocation!.longitude}';
                Navigator.pop(context);
                widget.onLocationPicked(koordinat, selectedAddress);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text(
              'PILIH',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                              },
                            ),
                    ),
                    onSubmitted: _searchLocation,
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol lokasi saya
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.blue),
                  onPressed: () async {
                    // TODO: Implementasi get current location
                    Get.snackbar(
                      'Info',
                      'Fitur lokasi saya akan diimplementasikan',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ),

          // Info alamat terpilih
          if (selectedAddress.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedAddress,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          if (selectedAddress.isNotEmpty) const SizedBox(height: 8),

          // Google Maps
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: selectedLocation ?? defaultLocation,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: markers,
              onTap: (position) {
                setState(() {
                  selectedLocation = position;
                  _updateMarker();
                  _getAddressFromLatLng(position);
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),

          // Info koordinat
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Koordinat:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedLocation != null
                      ? '${selectedLocation!.latitude.toStringAsFixed(6)}, ${selectedLocation!.longitude.toStringAsFixed(6)}'
                      : '-',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
