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
