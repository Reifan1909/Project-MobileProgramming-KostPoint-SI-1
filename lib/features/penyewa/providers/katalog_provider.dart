import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../shared/models/kos_model.dart';

/// Provider untuk mengelola state katalog kos pada Mode Guest, Penyewa, & Pemilik.
/// Mengatur titik tujuan aktif, filter kategori, navigasi menu bar, dan pengurutan dinamis.
class KatalogProvider with ChangeNotifier {
  DestinationTarget _selectedDestination = DummyData.defaultDestination;
  String _selectedCategory = 'Semua';
  int _selectedNavIndex = 0;
  final List<KosModel> _kosList = [];
  final Set<String> _bookmarkedKosIds = {};

  static const String _storageKeyKosList = 'kostpoint_registered_kos_list_v2';
  static const String _storageKeyBookmarks = 'kostpoint_bookmarked_kos_ids_v2';

  KatalogProvider() {
    _initFromStorage();
  }

  Future<void> _initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawKos = prefs.getString(_storageKeyKosList);
      if (rawKos != null) {
        final List<dynamic> decoded = jsonDecode(rawKos);
        _kosList.clear();
        for (final item in decoded) {
          _kosList.add(KosModel.fromJson(item as Map<String, dynamic>));
        }
      }
      final rawBookmarks = prefs.getStringList(_storageKeyBookmarks);
      if (rawBookmarks != null) {
        _bookmarkedKosIds.clear();
        _bookmarkedKosIds.addAll(rawBookmarks);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading katalog from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_kosList.map((k) => k.toJson()).toList());
      await prefs.setString(_storageKeyKosList, encoded);
      await prefs.setStringList(_storageKeyBookmarks, _bookmarkedKosIds.toList());
    } catch (e) {
      debugPrint('Error saving katalog to storage: $e');
    }
  }

  DestinationTarget get selectedDestination => _selectedDestination;
  String get selectedCategory => _selectedCategory;
  int get selectedNavIndex => _selectedNavIndex;
  List<KosModel> get allKos => _kosList;
  Set<String> get bookmarkedKosIds => _bookmarkedKosIds;

  List<KosModel> get favoriteKosList {
    return _kosList.where((k) => _bookmarkedKosIds.contains(k.id)).toList();
  }

  /// Daftar kos yang sudah difilter dan diurutkan berdasarkan jarak terdekat terhadap titik tujuan
  List<KosModel> get sortedKosList {
    final filtered = _selectedCategory == 'Semua'
        ? List<KosModel>.from(_kosList)
        : _kosList.where((k) => k.type == _selectedCategory).toList();

    filtered.sort((a, b) {
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
    _saveToStorage();
    notifyListeners();
  }

  /// Menambahkan kos baru hasil pendaftaran pemilik
  void addKos(KosModel kos) {
    _kosList.insert(0, kos);
    _saveToStorage();
    notifyListeners();
  }

  /// Menghapus kos dari sistem
  void deleteKos(String kosId) {
    _kosList.removeWhere((k) => k.id == kosId);
    _bookmarkedKosIds.remove(kosId);
    _saveToStorage();
    notifyListeners();
  }

  /// Update ketersediaan kamar
  void updateRoomAvailability(String kosId, int remainingRooms) {
    final index = _kosList.indexWhere((k) => k.id == kosId);
    if (index != -1) {
      _kosList[index] = _kosList[index].copyWith(remainingRooms: remainingRooms);
      _saveToStorage();
      notifyListeners();
    }
  }
}
