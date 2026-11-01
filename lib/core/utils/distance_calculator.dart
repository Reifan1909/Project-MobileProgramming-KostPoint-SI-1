import 'package:geolocator/geolocator.dart';

/// Utilitas perhitungan jarak koordinat dan estimasi waktu tempuh.
/// Sesuai dengan spesifikasi section 4.1 di panduan agen:
/// - Motor: Asumsi kecepatan 35 km/jam.
/// - Jalan kaki: Asumsi kecepatan 4.5 km/jam (radius dekat < 1.5 km).
class DistanceCalculator {
  DistanceCalculator._();

  /// Menghitung jarak antara dua koordinat (dalam satuan kilometer).
  static double calculateDistanceKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distanceInMeters / 1000.0;
  }

  /// Memformat jarak menjadi string yang mudah dibaca (misal: "450 m" atau "2.4 km").
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Estimasi waktu tempuh dengan sepeda motor (menit).
  /// Asumsi kecepatan 35 km/jam (kisaran 30-40 km/jam).
  static int estimateMotorbikeMinutes(double distanceKm) {
    if (distanceKm <= 0.05) return 1;
    final minutes = (distanceKm / 35.0 * 60).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// Estimasi waktu tempuh jalan kaki (menit).
  /// Asumsi kecepatan 4.5 km/jam (kisaran 4-5 km/jam).
  static int estimateWalkingMinutes(double distanceKm) {
    if (distanceKm <= 0.05) return 1;
    final minutes = (distanceKm / 4.5 * 60).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// Format estimasi waktu tempuh gabungan yang ringkas.
  static String formatTravelEstimate(double distanceKm) {
    final motor = estimateMotorbikeMinutes(distanceKm);
    if (distanceKm < 1.5) {
      final walk = estimateWalkingMinutes(distanceKm);
      return '$walk mnt jalan kaki • $motor mnt motor';
    }
    return '$motor mnt naik motor';
  }
}

