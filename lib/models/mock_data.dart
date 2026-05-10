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

class GuestEntry {
  final String id;
  final String plateNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String hostFlatNumber;
  final String hostName;
  final DateTime entryTime;
  final int allowedHours;

  const GuestEntry({
    required this.id,
    required this.plateNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.hostFlatNumber,
    required this.hostName,
    required this.entryTime,
    required this.allowedHours,
  });

  DateTime get expiryTime => entryTime.add(Duration(hours: allowedHours));

  Duration get remaining {
    final diff = expiryTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  double get progressFraction {
    final total = allowedHours * 3600;
    final elapsed = DateTime.now().difference(entryTime).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);
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

  static final List<GuestEntry> guestEntries = [
    GuestEntry(
      id: 'G001',
      plateNumber: 'MH 04 KL 9988',
      vehicleModel: 'Maruti Swift',
      vehicleColor: 'Red',
      hostFlatNumber: 'B-302',
      hostName: 'Priya Sharma',
      entryTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      allowedHours: 2,
    ),
    GuestEntry(
      id: 'G002',
      plateNumber: 'GJ 01 TZ 4455',
      vehicleModel: 'Toyota Fortuner',
      vehicleColor: 'Grey',
      hostFlatNumber: 'C-1102',
      hostName: 'Rahul Verma',
      entryTime: DateTime.now().subtract(const Duration(hours: 3)),
      allowedHours: 5,
    ),
    GuestEntry(
      id: 'G003',
      plateNumber: 'KA 09 MM 7722',
      vehicleModel: 'Hyundai i20',
      vehicleColor: 'Blue',
      hostFlatNumber: 'A-401',
      hostName: 'Sneha Patel',
      entryTime: DateTime.now().subtract(const Duration(minutes: 45)),
      allowedHours: 12,
    ),
    GuestEntry(
      id: 'G004',
      plateNumber: 'DL 7C AA 2233',
      vehicleModel: 'Kia Seltos',
      vehicleColor: 'Black',
      hostFlatNumber: 'D-801',
      hostName: 'Vikram Singh',
      entryTime: DateTime.now().subtract(const Duration(hours: 10, minutes: 10)),
      allowedHours: 12,
    ),
    GuestEntry(
      id: 'G005',
      plateNumber: 'MH 12 XY 6601',
      vehicleModel: 'Tata Nexon',
      vehicleColor: 'Orange',
      hostFlatNumber: 'B-501',
      hostName: 'Neha Joshi',
      entryTime: DateTime.now().subtract(const Duration(minutes: 10)),
      allowedHours: 5,
    ),
  ];

  static const List<Map<String, dynamic>> onboardingSlides = [
    {
      'title': 'Smart Parking\nfor Your Society',
      'subtitle': 'Manage resident and guest vehicles with a tap. No more chaos at the gate.',
      'icon': 0xf065f, // car icon codepoint
    },
    {
      'title': 'QR-Powered\nEntry System',
      'subtitle': 'Each resident gets a unique QR code. Guards scan to verify instantly.',
      'icon': 0xf0396,
    },
    {
      'title': 'Real-Time\nGuest Tracking',
      'subtitle': 'Know who is parked, for how long, and whose guest they are — live.',
      'icon': 0xf03a0,
    },
  ];
}
