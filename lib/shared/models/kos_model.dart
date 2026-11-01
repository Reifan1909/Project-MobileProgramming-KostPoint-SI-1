class KosModel {
  final String id;
  final String name;
  final String address;
  final String district;
  final double price;
  final String pricePeriod;
  final String type; // 'Putra', 'Putri', 'Campur'
  final double latitude;
  final double longitude;
  final String imageUrl;
  final int remainingRooms;
  final int totalRooms;
  final List<String> facilities;
  final double rating;
  final int reviewCount;
  final bool isPremium;
  final String ownerPhone;
  final String description;

  const KosModel({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.price,
    this.pricePeriod = '/ bulan',
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.remainingRooms,
    required this.totalRooms,
    required this.facilities,
    required this.rating,
    required this.reviewCount,
    this.isPremium = false,
    required this.ownerPhone,
    required this.description,
  });

  bool get isAvailable => remainingRooms > 0;

  String get formattedPrice {
    final formattedNum = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formattedNum$pricePeriod';
  }

  KosModel copyWith({
    String? id,
    String? name,
    String? address,
    String? district,
    double? price,
    String? pricePeriod,
    String? type,
    double? latitude,
    double? longitude,
    String? imageUrl,
    int? remainingRooms,
    int? totalRooms,
    List<String>? facilities,
    double? rating,
    int? reviewCount,
    bool? isPremium,
    String? ownerPhone,
    String? description,
  }) {
    return KosModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      district: district ?? this.district,
      price: price ?? this.price,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      remainingRooms: remainingRooms ?? this.remainingRooms,
      totalRooms: totalRooms ?? this.totalRooms,
      facilities: facilities ?? this.facilities,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isPremium: isPremium ?? this.isPremium,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      description: description ?? this.description,
    );
  }
}

