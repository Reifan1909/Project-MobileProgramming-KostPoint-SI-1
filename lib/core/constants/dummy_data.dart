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

  /// Pilihan Titik Tujuan Populer di Berbagai Kampus & Kota di Indonesia
  static const List<DestinationTarget> popularDestinations = [
    defaultDestination,
    DestinationTarget(
      id: 'unand',
      name: 'Universitas Andalas (UNAND)',
      address: 'Limau Manis, Kec. Pauh',
      city: 'Padang',
      latitude: -0.914562,
      longitude: 100.460831,
    ),
    DestinationTarget(
      id: 'unp',
      name: 'Universitas Negeri Padang (UNP)',
      address: 'Jl. Prof. Dr. Hamka, Air Tawar Barat',
      city: 'Padang',
      latitude: -0.895123,
      longitude: 100.352418,
    ),
    DestinationTarget(
      id: 'pnp',
      name: 'Politeknik Negeri Padang (PNP)',
      address: 'Kampus Limau Manis, Kec. Pauh',
      city: 'Padang',
      latitude: -0.913200,
      longitude: 100.458900,
    ),
    DestinationTarget(
      id: 'ui_depok',
      name: 'Universitas Indonesia (UI Depok)',
      address: 'Jl. Margonda Raya, Pondok Cina, Beji',
      city: 'Depok / Jakarta',
      latitude: -6.363300,
      longitude: 106.828700,
    ),
    DestinationTarget(
      id: 'itb_bandung',
      name: 'Institut Teknologi Bandung (ITB)',
      address: 'Jl. Ganesa No. 10, Coblong',
      city: 'Bandung',
      latitude: -6.891500,
      longitude: 107.610700,
    ),
    DestinationTarget(
      id: 'telkom_univ',
      name: 'Telkom University Bandung',
      address: 'Jl. Telekomunikasi No. 1, Bojongsoang',
      city: 'Bandung',
      latitude: -6.974400,
      longitude: 107.630300,
    ),
    DestinationTarget(
      id: 'unpad_jatinangor',
      name: 'Universitas Padjadjaran (UNPAD)',
      address: 'Jl. Raya Bandung Sumedang KM. 21, Jatinangor',
      city: 'Bandung',
      latitude: -6.927200,
      longitude: 107.774500,
    ),
    DestinationTarget(
      id: 'ugm_jogja',
      name: 'Universitas Gadjah Mada (UGM)',
      address: 'Bulaksumur, Caturtunggal, Sleman',
      city: 'Yogyakarta',
      latitude: -7.771300,
      longitude: 110.377600,
    ),
    DestinationTarget(
      id: 'uny_jogja',
      name: 'Universitas Negeri Yogyakarta (UNY)',
      address: 'Jl. Colombo No. 1, Karang Malang, Caturtunggal',
      city: 'Yogyakarta',
      latitude: -7.774800,
      longitude: 110.386900,
    ),
    DestinationTarget(
      id: 'its_surabaya',
      name: 'Institut Teknologi Sepuluh Nopember (ITS)',
      address: 'Jl. Raya ITS, Keputih, Sukolilo',
      city: 'Surabaya',
      latitude: -7.282400,
      longitude: 112.794400,
    ),
    DestinationTarget(
      id: 'unair_surabaya',
      name: 'Universitas Airlangga (UNAIR Kampus C)',
      address: 'Mulyorejo, Kec. Mulyorejo',
      city: 'Surabaya',
      latitude: -7.268800,
      longitude: 112.784600,
    ),
    DestinationTarget(
      id: 'ub_malang',
      name: 'Universitas Brawijaya (UB Malang)',
      address: 'Jl. Veteran, Ketawanggede, Lowokwaru',
      city: 'Malang',
      latitude: -7.952500,
      longitude: 112.614400,
    ),
    DestinationTarget(
      id: 'undip_semarang',
      name: 'Universitas Diponegoro (UNDIP Tembalang)',
      address: 'Jl. Prof. Sudarto, Tembalang',
      city: 'Semarang',
      latitude: -7.050500,
      longitude: 110.435700,
    ),
    DestinationTarget(
      id: 'uns_solo',
      name: 'Universitas Sebelas Maret (UNS Solo)',
      address: 'Jl. Ir. Sutami No. 36A, Jebres',
      city: 'Surakarta / Solo',
      latitude: -7.558700,
      longitude: 110.855900,
    ),
    DestinationTarget(
      id: 'usu_medan',
      name: 'Universitas Sumatera Utara (USU)',
      address: 'Jl. Dr. Mansyur No. 9, Medan Baru',
      city: 'Medan',
      latitude: 3.565100,
      longitude: 98.657500,
    ),
    DestinationTarget(
      id: 'unhas_makassar',
      name: 'Universitas Hasanuddin (UNHAS)',
      address: 'Jl. Perintis Kemerdekaan KM. 10, Tamalanrea',
      city: 'Makassar',
      latitude: -5.135400,
      longitude: 119.489700,
    ),
    DestinationTarget(
      id: 'unud_bali',
      name: 'Universitas Udayana (UNUD Jimbaran)',
      address: 'Jl. Kampus Udayana, Jimbaran, Kuta Selatan',
      city: 'Bali',
      latitude: -8.798100,
      longitude: 115.170600,
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

    // Area Surabaya (Dekat ITS Sukolilo & UNAIR)
    const KosModel(
      id: 'kos_sby_1',
      name: 'Gebang Modern Residence ITS',
      address: 'Jl. Gebang Putih No. 18, Sukolilo',
      district: 'Sukolilo, Surabaya',
      price: 1100000,
      pricePeriod: '/ bulan',
      type: 'Campur',
      latitude: -7.284500,
      longitude: 112.791200,
      imageUrl:
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
      remainingRooms: 2,
      totalRooms: 15,
      facilities: ['AC', 'WiFi Cepat', 'Kamar Mandi Dalam', 'Dapur Bersama', 'Parkir Luas'],
      rating: 4.8,
      reviewCount: 39,
      isPremium: true,
      ownerPhone: '6281778899001',
      description:
          'Kos nyaman strategis tepat di samping kampus ITS Sukolilo. Akses mudah ke Asrama ITS dan warung makan mahasiswa.',
    ),

    // Area Malang (Dekat UB Brawijaya)
    const KosModel(
      id: 'kos_mlg_1',
      name: 'Watugong Brawijaya Premiere',
      address: 'Jl. Watugong No. 12, Ketawanggede',
      district: 'Lowokwaru, Malang',
      price: 950000,
      pricePeriod: '/ bulan',
      type: 'Putra',
      latitude: -7.954200,
      longitude: 112.611800,
      imageUrl:
          'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800&q=80',
      remainingRooms: 3,
      totalRooms: 14,
      facilities: ['WiFi', 'Kamar Mandi Dalam', 'Kasur Springbed', 'Air Hangat'],
      rating: 4.7,
      reviewCount: 31,
      isPremium: true,
      ownerPhone: '6281889900112',
      description:
          'Kos favorit mahasiswa Universitas Brawijaya di Watugong. Suasana sejuk khas Malang dengan fasilitas lengkap.',
    ),

    // Area Medan (Dekat USU)
    const KosModel(
      id: 'kos_mdn_1',
      name: 'Graha Mansyur Asri USU',
      address: 'Jl. Dr. Mansyur Gg. Sehat No. 4, Padang Bulan',
      district: 'Medan Baru, Medan',
      price: 850000,
      pricePeriod: '/ bulan',
      type: 'Putri',
      latitude: -3.567200,
      longitude: 98.654800,
      imageUrl:
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80',
      remainingRooms: 2,
      totalRooms: 10,
      facilities: ['WiFi', 'AC', 'Kamar Mandi Dalam', 'CCTV 24 Jam'],
      rating: 4.6,
      reviewCount: 20,
      isPremium: true,
      ownerPhone: '6281990011223',
      description:
          'Kos putri nyaman di kawasan Dr. Mansyur Medan, 2 menit jalan kaki ke gerbang utama Universitas Sumatera Utara.',
    ),
  ];
}
