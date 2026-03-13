class FormatterUtil {
  static String formatWaktuSimple(String waktuStr) {
    try {
      if (waktuStr.contains('T')) {
        final parts = waktuStr.split('T');
        String jam = parts[1];
        jam = jam.replaceAll(RegExp(r'\..*$'), '');
        jam = jam.replaceAll(RegExp(r'Z$'), '');
        if (jam.contains(':')) {
          final jamParts = jam.split(':');
          if (jamParts.length >= 2) {
            return '${jamParts[0]}:${jamParts[1]}';
          }
        }
        return jam;
      }
      if (waktuStr.contains(' ')) {
        final parts = waktuStr.split(' ');
        if (parts.length >= 2) {
          String jam = parts[1];
          if (jam.contains(':')) {
            final jamParts = jam.split(':');
            if (jamParts.length >= 2) {
              return '${jamParts[0]}:${jamParts[1]}';
            }
          }
          return jam;
        }
      }
      return waktuStr;
    } catch (e) {
      return '-';
    }
  }

  // Format tanggal
  static String formatTanggal(String tanggalStr) {
    try {
      if (tanggalStr.contains('T')) {
        tanggalStr = tanggalStr.split('T')[0];
      }
      if (tanggalStr.contains(' ')) {
        tanggalStr = tanggalStr.split(' ')[0];
      }

      final parts = tanggalStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return tanggalStr;
    } catch (e) {
      return tanggalStr;
    }
  }

  // Format jam
  static String formatJam(String waktuStr) {
    try {
      if (waktuStr.contains('T')) {
        final parts = waktuStr.split('T');
        String jam = parts[1];
        jam = jam.replaceAll(RegExp(r'\..*$'), '');
        jam = jam.replaceAll(RegExp(r'Z$'), '');
        if (jam.contains(':')) {
          final jamParts = jam.split(':');
          if (jamParts.length >= 2) {
            return '${jamParts[0]}:${jamParts[1]}';
          }
        }
        return jam;
      }
      if (waktuStr.contains(' ')) {
        final parts = waktuStr.split(' ');
        if (parts.length >= 2) {
          String jam = parts[1];
          if (jam.contains(':')) {
            final jamParts = jam.split(':');
            if (jamParts.length >= 2) {
              return '${jamParts[0]}:${jamParts[1]}';
            }
          }
          return jam;
        }
      }
      return waktuStr;
    } catch (e) {
      return '-';
    }
  }

  // ================= FUNGSI UNTUK URL GAMBAR =================
  static String getFullImageUrl(String path, String baseUrl) {
    if (path.isEmpty) return '';

    // Hapus '/api' dari baseUrl jika ada
    String cleanBaseUrl = baseUrl.replaceAll('/api', '');

    if (path.startsWith('http')) {
      if (path.contains('localhost')) {
        // Ganti localhost dengan IP dari baseUrl
        String ip = cleanBaseUrl.replaceAll('http://', '');
        return path.replaceFirst('localhost', ip);
      }
      return path;
    }

    if (path.startsWith('/storage')) {
      return cleanBaseUrl + path;
    }

    // Cek apakah path untuk wajah atau absensi
    if (path.contains('wajah')) {
      return '$cleanBaseUrl/storage/wajah/$path';
    } else {
      return '$cleanBaseUrl/storage/foto_absensi/$path';
    }
  }

  // Fungsi khusus untuk wajah
  static String getWajahImageUrl(String path) {
    if (path.isEmpty) return '';

    const String baseUrl = 'http://192.168.95.243:8000';

    if (path.startsWith('http')) {
      if (path.contains('localhost')) {
        return path.replaceFirst('localhost', '192.168.95.243:8000');
      }
      return path;
    }

    if (path.startsWith('/storage')) {
      return baseUrl + path;
    }

    return '$baseUrl/storage/wajah/$path';
  }

  // ================= FUNGSI UNTUK URL GAMBAR WAJAH =================
  static String getWajahAdminImageUrl(String path, {String? baseUrl}) {
    if (path.isEmpty) return '';

    // Default base URL
    const String defaultBaseUrl = 'http://192.168.95.243:8000';
    final String finalBaseUrl = baseUrl ?? defaultBaseUrl;

    // Hapus '/api' jika ada
    String cleanBaseUrl = finalBaseUrl.replaceAll('/api', '');

    if (path.startsWith('http')) {
      if (path.contains('localhost')) {
        // Ekstrak IP dari cleanBaseUrl
        String ip = cleanBaseUrl.replaceAll('http://', '');
        return path.replaceFirst('localhost', ip);
      }
      return path;
    }

    if (path.startsWith('/storage')) {
      return cleanBaseUrl + path;
    }

    return '$cleanBaseUrl/storage/wajah/$path';
  }
}
