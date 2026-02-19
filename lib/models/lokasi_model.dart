// models/lokasi_model.dart
class LokasiModel {
  final int id;
  final String user;
  final String lokasi;
  final String koordinat;

  LokasiModel({
    required this.id,
    required this.user,
    required this.lokasi,
    required this.koordinat,
  });

  factory LokasiModel.fromJson(Map<String, dynamic> json) {
    return LokasiModel(
      id: json['id'],
      user: json['user']['name'],
      lokasi: json['lokasi'],
      koordinat: json['koordinat'],
    );
  }
}
