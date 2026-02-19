class Mahasiswa {
  int? id;
  String nama;
  String nim;
  String jurusan;
  int tahunMasuk;

  Mahasiswa({
    this.id,
    required this.nama,
    required this.nim,
    required this.jurusan,
    required this.tahunMasuk,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      id: json['id'],
      nama: json['nama'],
      nim: json['nim'],
      jurusan: json['jurusan'],
      tahunMasuk: json['tahun_masuk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nim': nim,
      'jurusan': jurusan,
      'tahun_masuk': tahunMasuk,
    };
  }
}
