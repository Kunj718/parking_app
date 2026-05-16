class Vehicle {
  final String id;
  final String plateNumber;
  final String model;
  final String color;
  final bool isPrimary;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.color,
    this.isPrimary = false,
  });
}

class Resident {
  final String id;
  final String name;
  final String flatNumber;
  final String tower;
  final String phone;
  final List<Vehicle> vehicles;
  final String role; // 'admin' | 'resident'

  const Resident({
    required this.id,
    required this.name,
    required this.flatNumber,
    required this.tower,
    required this.phone,
    required this.vehicles,
    required this.role,
  });

  String get qrData => 'PARKQR:$id:$flatNumber:$tower';
}

// ─── Admin: Tenement record ───────────────────────────────────────────────────

class TenementRecord {
  final String unitNumber;
  final String residentName;
  final String phone;
  final String status; // 'qr_active' | 'app_pending'
  final String vehicleModel;
  final String vehicleColor;
  final String vehiclePlate;
  final String vehicleType; // 'car' | 'bike'
  /// True when the current occupant is a tenant (renting) rather than the owner.
  final bool isTenant;

  const TenementRecord({
    required this.unitNumber,
    required this.residentName,
    required this.phone,
    required this.status,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehiclePlate,
    this.vehicleType = 'car',
    this.isTenant = false,
  });

  bool get isQrActive => status == 'qr_active';

  /// Returns the numeric suffix of the unit number (A-101 → 101)
  int get unitIndex {
    final match = RegExp(r'(\d+)$').firstMatch(unitNumber);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }
}

class MockData {
  static final currentResident = Resident(
    id: 'RES001',
    name: 'Arjun Mehta',
    flatNumber: 'A-704',
    tower: 'Tower A',
    phone: '+91 98765 43210',
    role: 'resident',
    vehicles: [
      const Vehicle(
        id: 'V001',
        plateNumber: 'MH 02 AB 1234',
        model: 'Honda City',
        color: 'Pearl White',
        isPrimary: true,
      ),
      const Vehicle(
        id: 'V002',
        plateNumber: 'MH 02 CD 5678',
        model: 'Royal Enfield',
        color: 'Stealth Black',
      ),
    ],
  );

  static const List<Map<String, dynamic>> onboardingSlides = [
    {
      'title': 'Smart Parking\nfor Your Society',
      'subtitle':
          'Manage resident and guest vehicles with a tap. No more chaos at the gate.',
      'icon': 0xf065f,
    },
    {
      'title': 'QR-Powered\nEntry System',
      'subtitle':
          'Each resident gets a unique QR code. Guards scan to verify instantly.',
      'icon': 0xf0396,
    },
    {
      'title': 'Real-Time\nGuest Tracking',
      'subtitle':
          'Know who is parked, for how long, and whose guest they are — live.',
      'icon': 0xf03a0,
    },
  ];

  // ── Admin mock tenement list (A-101 … A-130) ──────────────────────────────
  static const List<TenementRecord> tenements = [
    // Range 1–10
    TenementRecord(
      unitNumber: 'A-101', residentName: 'Rajesh Kumar',
      phone: '+91 9876543210', status: 'qr_active',
      vehicleModel: 'Honda City', vehicleColor: 'White',
      vehiclePlate: 'MH 01 AB 1234',
    ),
    TenementRecord(
      unitNumber: 'A-102', residentName: 'Priya Sharma',
      phone: '+91 9823456701', status: 'app_pending',
      vehicleModel: 'Maruti Swift', vehicleColor: 'Red',
      vehiclePlate: 'MH 01 CD 5678',
      isTenant: true,
    ),
    TenementRecord(
      unitNumber: 'A-103', residentName: 'Vikram Nair',
      phone: '+91 9812345602', status: 'qr_active',
      vehicleModel: 'Toyota Fortuner', vehicleColor: 'Black',
      vehiclePlate: 'MH 01 EF 9012',
    ),
    TenementRecord(
      unitNumber: 'A-104', residentName: 'Sunita Patel',
      phone: '+91 9856781203', status: 'app_pending',
      vehicleModel: 'Royal Enfield', vehicleColor: 'Grey',
      vehiclePlate: 'MH 01 GH 3456',
      vehicleType: 'bike',
    ),
    TenementRecord(
      unitNumber: 'A-105', residentName: 'Anil Desai',
      phone: '+91 9867890104', status: 'qr_active',
      vehicleModel: 'Hyundai Creta', vehicleColor: 'Silver',
      vehiclePlate: 'MH 01 IJ 7890',
    ),
    TenementRecord(
      unitNumber: 'A-106', residentName: 'Meera Joshi',
      phone: '+91 9878901205', status: 'qr_active',
      vehicleModel: 'Tata Nexon', vehicleColor: 'Blue',
      vehiclePlate: 'MH 01 KL 1122',
    ),
    TenementRecord(
      unitNumber: 'A-107', residentName: 'Suresh Iyer',
      phone: '+91 9889012306', status: 'app_pending',
      vehicleModel: 'Honda Activa', vehicleColor: 'White',
      vehiclePlate: 'MH 01 MN 3344',
      vehicleType: 'bike',
      isTenant: true,
    ),
    TenementRecord(
      unitNumber: 'A-108', residentName: 'Kavita Reddy',
      phone: '+91 9890123407', status: 'qr_active',
      vehicleModel: 'Kia Seltos', vehicleColor: 'Orange',
      vehiclePlate: 'MH 01 OP 5566',
    ),
    TenementRecord(
      unitNumber: 'A-109', residentName: 'Deepak Verma',
      phone: '+91 9801234508', status: 'app_pending',
      vehicleModel: 'Maruti Baleno', vehicleColor: 'Grey',
      vehiclePlate: 'MH 01 QR 7788',
    ),
    TenementRecord(
      unitNumber: 'A-110', residentName: 'Anita Singh',
      phone: '+91 9812340609', status: 'qr_active',
      vehicleModel: 'Mahindra XUV700', vehicleColor: 'Black',
      vehiclePlate: 'MH 01 ST 9900',
    ),
    // Range 11–20
    TenementRecord(
      unitNumber: 'A-111', residentName: 'Rohit Malhotra',
      phone: '+91 9823451710', status: 'app_pending',
      vehicleModel: 'Skoda Slavia', vehicleColor: 'White',
      vehiclePlate: 'MH 02 AB 1111',
    ),
    TenementRecord(
      unitNumber: 'A-112', residentName: 'Neha Kapoor',
      phone: '+91 9834562811', status: 'qr_active',
      vehicleModel: 'Renault Kwid', vehicleColor: 'Red',
      vehiclePlate: 'MH 02 CD 2222',
    ),
    TenementRecord(
      unitNumber: 'A-113', residentName: 'Ajay Gupta',
      phone: '+91 9845673912', status: 'qr_active',
      vehicleModel: 'Nissan Magnite', vehicleColor: 'Blue',
      vehiclePlate: 'MH 02 EF 3333',
    ),
    TenementRecord(
      unitNumber: 'A-114', residentName: 'Shilpa Tiwari',
      phone: '+91 9856785013', status: 'app_pending',
      vehicleModel: 'Honda Shine', vehicleColor: 'Black',
      vehiclePlate: 'MH 02 GH 4444',
      vehicleType: 'bike',
      isTenant: true,
    ),
    TenementRecord(
      unitNumber: 'A-115', residentName: 'Manoj Pandey',
      phone: '+91 9867896114', status: 'qr_active',
      vehicleModel: 'Volkswagen Polo', vehicleColor: 'Silver',
      vehiclePlate: 'MH 02 IJ 5555',
    ),
    TenementRecord(
      unitNumber: 'A-116', residentName: 'Geeta Nambiar',
      phone: '+91 9878907215', status: 'app_pending',
      vehicleModel: 'Bajaj Pulsar', vehicleColor: 'Black',
      vehiclePlate: 'MH 02 KL 6666',
      vehicleType: 'bike',
    ),
    TenementRecord(
      unitNumber: 'A-117', residentName: 'Rajan Bose',
      phone: '+91 9889018316', status: 'qr_active',
      vehicleModel: 'MG Hector', vehicleColor: 'White',
      vehiclePlate: 'MH 02 MN 7777',
    ),
    TenementRecord(
      unitNumber: 'A-118', residentName: 'Pooja Menon',
      phone: '+91 9890129417', status: 'app_pending',
      vehicleModel: 'Hyundai i20', vehicleColor: 'Grey',
      vehiclePlate: 'MH 02 OP 8888',
      isTenant: true,
    ),
    TenementRecord(
      unitNumber: 'A-119', residentName: 'Sanjay Rao',
      phone: '+91 9801230518', status: 'qr_active',
      vehicleModel: 'Ford EcoSport', vehicleColor: 'Blue',
      vehiclePlate: 'MH 02 QR 9999',
    ),
    TenementRecord(
      unitNumber: 'A-120', residentName: 'Divya Pillai',
      phone: '+91 9812341619', status: 'qr_active',
      vehicleModel: 'Tata Tiago', vehicleColor: 'Red',
      vehiclePlate: 'MH 02 ST 0101',
    ),
    // Range 21–30
    TenementRecord(
      unitNumber: 'A-121', residentName: 'Harish Shetty',
      phone: '+91 9823452720', status: 'qr_active',
      vehicleModel: 'Suzuki Ciaz', vehicleColor: 'Silver',
      vehiclePlate: 'MH 03 AB 1212',
    ),
    TenementRecord(
      unitNumber: 'A-122', residentName: 'Lalita Choudhary',
      phone: '+91 9834563821', status: 'app_pending',
      vehicleModel: 'Bajaj Dominar', vehicleColor: 'Black',
      vehiclePlate: 'MH 03 CD 2323',
      vehicleType: 'bike',
      isTenant: true,
    ),
    TenementRecord(
      unitNumber: 'A-123', residentName: 'Vivek Kulkarni',
      phone: '+91 9845674922', status: 'qr_active',
      vehicleModel: 'Honda Jazz', vehicleColor: 'White',
      vehiclePlate: 'MH 03 EF 3434',
    ),
    TenementRecord(
      unitNumber: 'A-124', residentName: 'Asha Krishnan',
      phone: '+91 9856786023', status: 'app_pending',
      vehicleModel: 'Maruti Ertiga', vehicleColor: 'Grey',
      vehiclePlate: 'MH 03 GH 4545',
    ),
    TenementRecord(
      unitNumber: 'A-125', residentName: 'Nitin Bhatt',
      phone: '+91 9867897124', status: 'qr_active',
      vehicleModel: 'Kia Carnival', vehicleColor: 'Black',
      vehiclePlate: 'MH 03 IJ 5656',
    ),
    TenementRecord(
      unitNumber: 'A-126', residentName: 'Rekha Ghosh',
      phone: '+91 9878908225', status: 'app_pending',
      vehicleModel: 'TVS Apache', vehicleColor: 'Red',
      vehiclePlate: 'MH 03 KL 6767',
      vehicleType: 'bike',
      isTenant: true,
    ),
    TenementRecord(
      unitNumber: 'A-127', residentName: 'Ashok Tripathi',
      phone: '+91 9889019326', status: 'qr_active',
      vehicleModel: 'Toyota Innova', vehicleColor: 'White',
      vehiclePlate: 'MH 03 MN 7878',
    ),
    TenementRecord(
      unitNumber: 'A-128', residentName: 'Jayalakshmi R',
      phone: '+91 9890120427', status: 'app_pending',
      vehicleModel: 'Hyundai Venue', vehicleColor: 'Blue',
      vehiclePlate: 'MH 03 OP 8989',
    ),
    TenementRecord(
      unitNumber: 'A-129', residentName: 'Dinesh Varma',
      phone: '+91 9801231528', status: 'qr_active',
      vehicleModel: 'Tata Punch', vehicleColor: 'Orange',
      vehiclePlate: 'MH 03 QR 9090',
    ),
    TenementRecord(
      unitNumber: 'A-130', residentName: 'Kamala Subramaniam',
      phone: '+91 9812342629', status: 'app_pending',
      vehicleModel: 'Maruti WagonR', vehicleColor: 'Grey',
      vehiclePlate: 'MH 03 ST 0202',
    ),
  ];
}
