import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PilihLokasiDialog extends GetView<PilihLokasiController> {
  final LatLng? initialLocation;
  final String? initialAddress;

  PilihLokasiDialog({super.key, this.initialLocation, this.initialAddress}) {
    Get.put(PilihLokasiController(initialLocation, initialAddress));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildMap(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.map, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Pilih Lokasi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari alamat atau tempat...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                suffixIcon: Obx(
                  () => controller.isLoading.value
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: controller.searchLocation,
                        ),
                ),
              ),
              onSubmitted: (_) => controller.searchLocation(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => controller.isLoading.value
                ? const SizedBox()
                : IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.blue),
                    onPressed: controller.getCurrentLocation,
                    tooltip: 'Lokasi Saya',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Obx(
        () => GoogleMap(
          onMapCreated: controller.onMapCreated,
          initialCameraPosition: CameraPosition(
            target:
                controller.selectedLocation.value ??
                const LatLng(-6.200000, 106.816666),
            zoom: 14,
          ),
          onTap: controller.onTap,
          markers: controller.markers.toSet(),
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      if (controller.selectedLocation.value == null) {
        return const SizedBox();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Koordinat:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.selectedLocation.value!.latitude.toStringAsFixed(6)}, '
                        '${controller.selectedLocation.value!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Get.back(
                      result: {
                        'koordinat':
                            '${controller.selectedLocation.value!.latitude.toStringAsFixed(6)}, '
                            '${controller.selectedLocation.value!.longitude.toStringAsFixed(6)}',
                        'alamat': controller.currentAddress.value,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Pilih'),
                ),
              ],
            ),
            if (controller.currentAddress.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Alamat: ${controller.currentAddress.value}',
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    });
  }
}

class PilihLokasiController extends GetxController {
  final LatLng? initialLocation;
  final String? initialAddress;

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final selectedLocation = Rxn<LatLng>();
  final currentAddress = ''.obs;
  final markers = <Marker>[].obs;

  GoogleMapController? mapController;

  PilihLokasiController(this.initialLocation, this.initialAddress);

  @override
  void onInit() {
    super.onInit();
    selectedLocation.value =
        initialLocation ?? const LatLng(-6.200000, 106.816666);

    if (initialAddress != null && initialAddress!.isNotEmpty) {
      searchController.text = initialAddress!;
      currentAddress.value = initialAddress!;
    }

    _updateMarker();
  }

  @override
  void onClose() {
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }

  void _updateMarker() {
    if (selectedLocation.value != null) {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: selectedLocation.value!,
          infoWindow: InfoWindow(
            title: 'Lokasi Terpilih',
            snippet: currentAddress.value.isEmpty
                ? 'Koordinat: ${selectedLocation.value!.latitude.toStringAsFixed(6)}, ${selectedLocation.value!.longitude.toStringAsFixed(6)}'
                : currentAddress.value,
          ),
          draggable: true,
          onDragEnd: (newPosition) {
            selectedLocation.value = newPosition;
            _getAddressFromLatLng(newPosition);
          },
        ),
      );
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onTap(LatLng location) {
    selectedLocation.value = location;
    _updateMarker();
    _getAddressFromLatLng(location);
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    isLoading.value = true;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        if (place.street?.isNotEmpty ?? false) addressParts.add(place.street!);
        if (place.locality?.isNotEmpty ?? false)
          addressParts.add(place.locality!);
        if (place.administrativeArea?.isNotEmpty ?? false)
          addressParts.add(place.administrativeArea!);
        if (place.country?.isNotEmpty ?? false)
          addressParts.add(place.country!);

        currentAddress.value = addressParts.join(', ');
        searchController.text = currentAddress.value;
      }
    } catch (e) {
      print('Error getting address: $e');
      currentAddress.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchLocation() async {
    if (searchController.text.isEmpty) return;

    isLoading.value = true;

    try {
      List<Location> locations = await locationFromAddress(
        searchController.text,
      );

      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLocation = LatLng(location.latitude, location.longitude);

        selectedLocation.value = newLocation;
        currentAddress.value = searchController.text;
        _updateMarker();

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newLocation, zoom: 15),
          ),
        );
      } else {
        Get.snackbar(
          'Tidak Ditemukan',
          'Lokasi tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencari lokasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    isLoading.value = true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation.value = currentLocation;
        _updateMarker();

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLocation, zoom: 15),
          ),
        );

        _getAddressFromLatLng(currentLocation);
      } else {
        Get.snackbar(
          'Izin Diperlukan',
          'Aplikasi membutuhkan izin lokasi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
