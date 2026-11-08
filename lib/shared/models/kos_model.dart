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
  final List<String> images;
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
    this.images = const [],
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

  List<String> get allImages =>
      images.isNotEmpty ? images : (imageUrl.isNotEmpty ? [imageUrl] : const []);

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
    List<String>? images,
    int? remainingRooms,
    int? totalRooms,
    List<String>? facilities,
    double? rating,
    int? reviewCount,
    bool? isPremium,
    String? ownerPhone,
    String? description,
  }) {
    final effectiveImages = images ?? this.images;
    final effectiveImageUrl = imageUrl ??
        (effectiveImages.isNotEmpty ? effectiveImages.first : this.imageUrl);

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
      imageUrl: effectiveImageUrl,
      images: effectiveImages,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'district': district,
      'price': price,
      'pricePeriod': pricePeriod,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'images': allImages,
      'remainingRooms': remainingRooms,
      'totalRooms': totalRooms,
      'facilities': facilities,
      'rating': rating,
      'reviewCount': reviewCount,
      'isPremium': isPremium,
      'ownerPhone': ownerPhone,
      'description': description,
    };
  }

  factory KosModel.fromJson(Map<String, dynamic> json) {
    final parsedImages = (json['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final fallbackUrl = json['imageUrl'] as String? ?? '';
    final effectiveImages = parsedImages.isNotEmpty
        ? parsedImages
        : (fallbackUrl.isNotEmpty ? [fallbackUrl] : const <String>[]);

    return KosModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      district: json['district'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      pricePeriod: json['pricePeriod'] as String? ?? '/ bulan',
      type: json['type'] as String? ?? 'Campur',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: fallbackUrl.isNotEmpty
          ? fallbackUrl
          : (effectiveImages.isNotEmpty ? effectiveImages.first : ''),
      images: effectiveImages,
      remainingRooms: json['remainingRooms'] as int? ?? 0,
      totalRooms: json['totalRooms'] as int? ?? 0,
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
      ownerPhone: json['ownerPhone'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

