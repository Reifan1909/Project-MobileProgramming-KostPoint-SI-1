import 'package:flutter/foundation.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../shared/models/kos_model.dart';

/// Provider untuk mengelola state katalog kos pada Mode Guest & Penyewa.
/// Mengatur titik tujuan aktif, filter kategori, navigasi menu bar, dan pengurutan dinamis.
class KatalogProvider with ChangeNotifier {
  DestinationTarget _selectedDestination = DummyData.defaultDestination;
  String _selectedCategory = 'Semua';
  int _selectedNavIndex = 0;
  final List<KosModel> _kosList = List.from(DummyData.dummyKosList);
  final Set<String> _bookmarkedKosIds = {};

  DestinationTarget get selectedDestination => _selectedDestination;
  String get selectedCategory => _selectedCategory;
  int get selectedNavIndex => _selectedNavIndex;
  List<KosModel> get allKos => _kosList;
  Set<String> get bookmarkedKosIds => _bookmarkedKosIds;

  List<KosModel> get favoriteKosList {
    return _kosList.where((k) => _bookmarkedKosIds.contains(k.id)).toList();
  }

  /// Daftar kos yang sudah difilter dan diurutkan:
  /// 1. Prioritas utama: status isPremium (PRO / Unggulan) di posisi teratas.
  /// 2. Prioritas kedua: Jarak terdekat dari koordinat titik tujuan yang dipilih.
  List<KosModel> get sortedKosList {
    final filtered = _selectedCategory == 'Semua'
        ? List<KosModel>.from(_kosList)
        : _kosList.where((k) => k.type == _selectedCategory).toList();

    filtered.sort((a, b) {
      // 1. Cek Prioritas PRO / Premium
      if (a.isPremium && !b.isPremium) return -1;
      if (!a.isPremium && b.isPremium) return 1;

      // 2. Cek Jarak Terdekat terhadap Titik Tujuan
      final distA = DistanceCalculator.calculateDistanceKm(
        startLatitude: a.latitude,
        startLongitude: a.longitude,
        endLatitude: _selectedDestination.latitude,
        endLongitude: _selectedDestination.longitude,
      );
      final distB = DistanceCalculator.calculateDistanceKm(
        startLatitude: b.latitude,
        startLongitude: b.longitude,
        endLatitude: _selectedDestination.latitude,
        endLongitude: _selectedDestination.longitude,
      );

      return distA.compareTo(distB);
    });

    return filtered;
  }

  /// Mengubah index menu bar navigasi bawah
  void setNavIndex(int index) {
    if (_selectedNavIndex != index) {
      _selectedNavIndex = index;
      notifyListeners();
    }
  }

  /// Mengubah titik tujuan pencarian secara dinamis (di mana saja di Indonesia)
  void updateDestination(DestinationTarget destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  /// Memfilter berdasarkan jenis kos (Semua, Putra, Putri, Campur)
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Toggle simpan favorit kos
  void toggleBookmark(String kosId) {
    if (_bookmarkedKosIds.contains(kosId)) {
      _bookmarkedKosIds.remove(kosId);
    } else {
      _bookmarkedKosIds.add(kosId);
    }
    notifyListeners();
  }

  /// Update ketersediaan kamar
  void updateRoomAvailability(String kosId, int remainingRooms) {
    final index = _kosList.indexWhere((k) => k.id == kosId);
    if (index != -1) {
      _kosList[index] = _kosList[index].copyWith(remainingRooms: remainingRooms);
      notifyListeners();
    }
  }
}
