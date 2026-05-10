class VehicleProfile {
  final String plateNumber;
  final String model;
  final String color;
  final String type; // 'car' | 'bike'

  const VehicleProfile({
    required this.plateNumber,
    required this.model,
    required this.color,
    required this.type,
  });
}

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String flatNumber;
  final String tower;
  final String? email;
  final String role;
  final List<VehicleProfile> vehicles;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.flatNumber,
    required this.tower,
    this.email,
    required this.role,
    required this.vehicles,
  });

  // Encodes full profile into QR data string
  String get qrData {
    final v = vehicles.isNotEmpty ? vehicles.first : null;
    final plate = v?.plateNumber ?? 'NONE';
    final model = v?.model ?? 'NONE';
    final color = v?.color ?? 'NONE';
    final type = v?.type ?? 'NONE';
    return 'PARKQR|$id|$name|$flatNumber|$tower|$phone|$plate|$model|$color|$type';
  }

  static ScannedProfile? parseQr(String data) {
    if (!data.startsWith('PARKQR|')) return null;
    final p = data.split('|');
    if (p.length < 10) return null;
    return ScannedProfile(
      name: p[2],
      flatNumber: p[3],
      tower: p[4],
      phone: p[5],
      plateNumber: p[6],
      vehicleModel: p[7],
      vehicleColor: p[8],
      vehicleType: p[9],
    );
  }

  UserProfile copyWith({
    String? name,
    String? flatNumber,
    String? tower,
    String? email,
    List<VehicleProfile>? vehicles,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone,
      flatNumber: flatNumber ?? this.flatNumber,
      tower: tower ?? this.tower,
      email: email ?? this.email,
      role: role,
      vehicles: vehicles ?? this.vehicles,
    );
  }
}

class ScannedProfile {
  final String name;
  final String flatNumber;
  final String tower;
  final String phone;
  final String plateNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleType;

  const ScannedProfile({
    required this.name,
    required this.flatNumber,
    required this.tower,
    required this.phone,
    required this.plateNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleType,
  });

  bool get hasVehicle => plateNumber != 'NONE';
}

class AppState {
  static final AppState instance = AppState._();
  AppState._();

  // Persists for the app session (no actual SharedPreferences — mock only)
  bool hasSeenOnboarding = false;
  bool isLoggedIn = false;
  String selectedRole = 'resident';
  UserProfile? currentUser;
}
