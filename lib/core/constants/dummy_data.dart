import '../../shared/models/kos_model.dart';

class DestinationTarget {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;

  const DestinationTarget({
    required this.id,
    required this.name,
    required this.address,
    this.city = 'Kota Padang',
    required this.latitude,
    required this.longitude,
  });

  DestinationTarget copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) {
    return DestinationTarget(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class DummyData {
  DummyData._();

  /// Titik Tujuan Default: Kampus UPI YPTK Padang (Lubuk Begalung)
  static const DestinationTarget defaultDestination = DestinationTarget(
    id: 'upi_yptk',
    name: 'Universitas Putra Indonesia "YPTK" Padang',
    address: 'Jl. Raya Lubuk Begalung, Kec. Lubuk Begalung',
    city: 'Kota Padang',
    latitude: -0.965874,
    longitude: 100.399587,
  );

  /// Pilihan Titik Tujuan Populer di Berbagai Kota di Indonesia
  static const List<DestinationTarget> popularDestinations = [
    defaultDestination,
    DestinationTarget(
      id: 'unand',
      name: 'Universitas Andalas (Kampus Limau Manis)',
      address: 'Limau Manis, Kec. Pauh',
      city: 'Kota Padang',
      latitude: -0.914562,
      longitude: 100.460831,
    ),
    DestinationTarget(
      id: 'unp',
      name: 'Universitas Negeri Padang (Kampus Air Tawar)',
      address: 'Jl. Prof. Dr. Hamka, Air Tawar Barat',
      city: 'Kota Padang',
      latitude: -0.895123,
      longitude: 100.352418,
    ),
    DestinationTarget(
      id: 'ui_depok',
      name: 'Universitas Indonesia (Kampus UI Depok)',
      address: 'Jl. Margonda Raya, Pondok Cina, Beji',
      city: 'Kota Depok / Jakarta',
      latitude: -6.363300,
      longitude: 106.828700,
    ),
    DestinationTarget(
      id: 'itb_bandung',
      name: 'Institut Teknologi Bandung (ITB Ganesha)',
      address: 'Jl. Ganesa No. 10, Coblong',
      city: 'Kota Bandung',
      latitude: -6.891500,
      longitude: 107.610700,
    ),
    DestinationTarget(
      id: 'ugm_jogja',
      name: 'Universitas Gadjah Mada (UGM Bulaksumur)',
      address: 'Bulaksumur, Caturtunggal, Sleman',
      city: 'DI Yogyakarta',
      latitude: -7.771300,
      longitude: 110.377600,
    ),
    DestinationTarget(
      id: 'its_surabaya',
      name: 'Institut Teknologi Sepuluh Nopember (ITS Sukolilo)',
      address: 'Jl. Raya ITS, Keputih, Sukolilo',
      city: 'Kota Surabaya',
      latitude: -7.282400,
      longitude: 112.794400,
    ),
    DestinationTarget(
      id: 'usu_medan',
      name: 'Universitas Sumatera Utara (USU Padang Bulan)',
      address: 'Jl. Dr. Mansyur No. 9, Medan Baru',
      city: 'Kota Medan',
      latitude: 3.565100,
      longitude: 98.657500,
    ),
  ];

  /// Daftar Kos Dummy di Berbagai Area (Padang, Jakarta/Depok, Bandung, Jogja)
  static final List<KosModel> dummyKosList = [
    // Area Padang (Lubuk Begalung & Limau Manis)
    const KosModel(
      id: 'kos_1',
      name: 'Kos Graha YPTK Exclusive',
      address: 'Jl. Raya Lubuk Begalung No. 24, Depan Kampus UPI',
      district: 'Lubuk Begalung, Padang',
      price: 850000,
      pricePeriod: '/ bulan',
      type: 'Putra',
      latitude: -0.964200,
      longitude: 100.401100,
      imageUrl:
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80',
      remainingRooms: 2,
      totalRooms: 12,
      facilities: ['WiFi 100 Mbps', 'Kamar Mandi Dalam', 'AC', 'Kasur Springbed', 'Parkir Motor'],
      rating: 4.8,
      reviewCount: 32,
      isPremium: true,
      ownerPhone: '6281234567890',
      description:
          'Kos eksklusif tepat di seberang gerbang utama UPI YPTK Padang. Lingkungan nyaman, aman dengan CCTV 24 jam.',
    ),
    const KosModel(
      id: 'kos_2',
      name: 'Kos Putri Syariah Arafah',
      address: 'Jl. Gurun Laweh No. 15, Dekat Simpang Lubeg',
      district: 'Lubuk Begalung, Padang',
      price: 900000,
      pricePeriod: '/ bulan',
      type: 'Putri',
      latitude: -0.968100,
      longitude: 100.397200,
      imageUrl:
          'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80',
      remainingRooms: 1,
      totalRooms: 8,
      facilities: ['WiFi Cepat', 'Kamar Mandi Dalam', 'Dapur Bersama', 'Kulkas'],
      rating: 4.9,
      reviewCount: 45,
      isPremium: true,
      ownerPhone: '6281298765432',
      description:
          'Kos putri muslimah asri dan sejuk. Suasana tenang sangat cocok untuk mahasiswi yang fokus belajar.',
    ),
    const KosModel(
      id: 'kos_3',
      name: 'Kos Melati Residen Lubeg',
      address: 'Gang Melati No. 8, Lubuk Begalung Nan XX',
      district: 'Lubuk Begalung, Padang',
      price: 650000,
      pricePeriod: '/ bulan',
      type: 'Campur',
      latitude: -0.961500,
      longitude: 100.403500,
      imageUrl:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=80',
      remainingRooms: 4,
      totalRooms: 14,
      facilities: ['WiFi', 'Kasur Busa', 'Lemari', 'Parkir Motor Berpagar'],
      rating: 4.5,
      reviewCount: 19,
      isPremium: false,
      ownerPhone: '6282176543210',
      description:
          'Pilihan kos ekonomis dengan fasilitas lengkap dan bersih di Lubuk Begalung.',
    ),
    const KosModel(
      id: 'kos_4',
      name: 'Kos Paviliun Limau Manis Asri',
      address: 'Jl. Pasar Baru No. 11, Pauh',
      district: 'Limau Manis, Padang',
      price: 700000,
      pricePeriod: '/ bulan',
      type: 'Putra',
      latitude: -0.923400,
      longitude: 100.449100,
      imageUrl:
          'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800&q=80',
      remainingRooms: 2,
      totalRooms: 9,
      facilities: ['WiFi', 'Kamar Mandi Dalam', 'Balkon', 'Parkir Luas'],
      rating: 4.6,
      reviewCount: 22,
      isPremium: false,
      ownerPhone: '6281344556677',
      description:
          'Paviliun nyaman di kawasan Pasar Baru Limau Manis dekat Unand.',
    ),

    // Area Jakarta / Depok (Dekat UI)
    const KosModel(
      id: 'kos_jkt_1',
      name: 'Kutek Residence UI Depok',
      address: 'Jl. Haji Amat No. 12, Kukusan Teknik',
      district: 'Beji, Depok',
      price: 1350000,
      pricePeriod: '/ bulan',
      type: 'Putra',
      latitude: -6.365500,
      longitude: 106.824200,
      imageUrl:
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
      remainingRooms: 3,
      totalRooms: 18,
      facilities: ['AC', 'WiFi Fiber', 'Kamar Mandi Dalam', 'Water Heater', 'Security 24 Jam'],
      rating: 4.9,
      reviewCount: 52,
      isPremium: true,
      ownerPhone: '6281122334455',
      description:
          'Hunian modern strategis tepat di pintu Kukusan Teknik (Kutek) UI Depok. Akses jalan kaki 3 menit ke kampus UI.',
    ),
    const KosModel(
      id: 'kos_jkt_2',
      name: 'Wisma Mahasiswi Barel UI',
      address: 'Jl. Margonda Raya Gg. Barel No. 18',
      district: 'Pondok Cina, Depok',
      price: 1100000,
      pricePeriod: '/ bulan',
      type: 'Putri',
      latitude: -6.361800,
      longitude: 106.831500,
      imageUrl:
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
      remainingRooms: 2,
      totalRooms: 12,
      facilities: ['WiFi', 'Kamar Mandi Dalam', 'Dapur Bersama', 'Akses Stasiun KRL'],
      rating: 4.7,
      reviewCount: 38,
      isPremium: false,
      ownerPhone: '6281223344556',
      description:
          'Kos mahasiswi nyaman dekat Stasiun UI dan Stasiun Pondok Cina. Dekat pusat jajanan Margonda.',
    ),

    // Area Bandung (Dekat ITB)
    const KosModel(
      id: 'kos_bdg_1',
      name: 'Dago Sanctuary Loft ITB',
      address: 'Jl. Cisitu Lama No. 9, Dago',
      district: 'Coblong, Bandung',
      price: 1600000,
      pricePeriod: '/ bulan',
      type: 'Campur',
      latitude: -6.885600,
      longitude: 107.613500,
      imageUrl:
          'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=80',
      remainingRooms: 1,
      totalRooms: 10,
      facilities: ['WiFi 150 Mbps', 'AC', 'Smart TV', 'Water Heater', 'Cafe Space'],
      rating: 4.9,
      reviewCount: 61,
      isPremium: true,
      ownerPhone: '6281334455667',
      description:
          'Kos estetik bergaya industrial di Cisitu Dago. Sangat dekat dengan kampus ITB Ganesha dan pusat kreatif Bandung.',
    ),
    const KosModel(
      id: 'kos_bdg_2',
      name: 'Pondok Kanayakan Ganesha',
      address: 'Jl. Kanayakan No. 5, Dago Atas',
      district: 'Coblong, Bandung',
      price: 950000,
      pricePeriod: '/ bulan',
      type: 'Putra',
      latitude: -6.883200,
      longitude: 107.616800,
      imageUrl:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=80',
      remainingRooms: 3,
      totalRooms: 14,
      facilities: ['Kasur', 'Lemari', 'WiFi', 'Udara Sejuk Dago', 'Parkir Motor'],
      rating: 4.6,
      reviewCount: 27,
      isPremium: false,
      ownerPhone: '6281445566778',
      description:
          'Kos tenang dan berhawa sejuk di kawasan Kanayakan Bandung. Lingkungan kondusif untuk belajar.',
    ),

    // Area Yogyakarta (Dekat UGM)
    const KosModel(
      id: 'kos_jogja_1',
      name: 'Pogung Eco Residence UGM',
      address: 'Jl. Pogung Dalangan No. 34, Sinduadi',
      district: 'Mlati, Sleman',
      price: 1200000,
      pricePeriod: '/ bulan',
      type: 'Putra',
      latitude: -7.764500,
      longitude: 110.375200,
      imageUrl:
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80',
      remainingRooms: 2,
      totalRooms: 16,
      facilities: ['AC', 'WiFi Cepat', 'Kamar Mandi Dalam', 'Parkir Mobil', 'Dapur'],
      rating: 4.8,
      reviewCount: 44,
      isPremium: true,
      ownerPhone: '6281556677889',
      description:
          'Kos strategis di kawasan favorit mahasiswa UGM, Pogung Dalangan. Akses cepat ke Fakultas Teknik dan Kedokteran UGM.',
    ),
    const KosModel(
      id: 'kos_jogja_2',
      name: 'Wisma Muslimah Karangmalang',
      address: 'Jl. Karangmalang No. 7, Caturtunggal',
      district: 'Depok, Sleman',
      price: 850000,
      pricePeriod: '/ bulan',
      type: 'Putri',
      latitude: -7.773800,
      longitude: 110.384500,
      imageUrl:
          'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80',
      remainingRooms: 4,
      totalRooms: 12,
      facilities: ['WiFi', 'Kamar Mandi Dalam', 'Lemari', 'Meja Belajar'],
      rating: 4.5,
      reviewCount: 23,
      isPremium: false,
      ownerPhone: '6281667788990',
      description:
          'Kos putri aman dan ramah di Karangmalang, perbatasan UGM dan UNY. Sangat dekat dengan pusat fotokopi dan kuliner.',
    ),
  ];
}
