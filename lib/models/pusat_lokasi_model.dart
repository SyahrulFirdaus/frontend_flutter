class PusatLokasiModel {
  final int id;
  final String namaLokasi;
  final String titikKordinat;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  PusatLokasiModel({
    required this.id,
    required this.namaLokasi,
    required this.titikKordinat,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PusatLokasiModel.fromJson(Map<String, dynamic> json) {
    return PusatLokasiModel(
      id: json['id'],
      namaLokasi: json['nama_lokasi'],
      titikKordinat: json['titik_kordinat'],
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper untuk mendapatkan latitude (angka)
  double? get latitude {
    try {
      final parts = titikKordinat.split(',');
      if (parts.length == 2) {
        return double.tryParse(parts[0].trim());
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Helper untuk mendapatkan longitude (angka)
  double? get longitude {
    try {
      final parts = titikKordinat.split(',');
      if (parts.length == 2) {
        return double.tryParse(parts[1].trim());
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Format koordinat untuk display (dengan 6 desimal)
  String get formattedKordinat {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return titikKordinat;
  }

  // Apakah koordinat valid?
  bool get isKordinatValid {
    return latitude != null && longitude != null;
  }

  // Untuk keperluan debugging
  @override
  String toString() {
    return 'PusatLokasi{id: $id, nama: $namaLokasi, kordinat: $titikKordinat}';
  }
}
