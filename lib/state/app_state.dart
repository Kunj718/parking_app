import 'package:flutter/material.dart';

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
  final String homeNumber;   // renamed from flatNumber — covers flats, houses, units
  final String tower;
  final String? tenamentNo; // Tenament / Survey / Unit No. (optional)
  final String? email;
  final String role;
  final List<VehicleProfile> vehicles;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.homeNumber,
    required this.tower,
    this.tenamentNo,
    this.email,
    required this.role,
    required this.vehicles,
  });

  // ── QR encoding ────────────────────────────────────────────────────────────
  // Format: PARKQR|id|name|homeNumber|tower|phone|tenamentNo|plate|model|color|type
  String get qrData {
    final v = vehicles.isNotEmpty ? vehicles.first : null;
    final plate = v?.plateNumber ?? 'NONE';
    final model = v?.model ?? 'NONE';
    final color = v?.color ?? 'NONE';
    final type = v?.type ?? 'NONE';
    final tenament = tenamentNo?.isNotEmpty == true ? tenamentNo! : 'NONE';
    return 'PARKQR|$id|$name|$homeNumber|$tower|$phone|$tenament|$plate|$model|$color|$type';
  }

  static ScannedProfile? parseQr(String data) {
    if (!data.startsWith('PARKQR|')) return null;
    final p = data.split('|');
    if (p.length < 11) return null;
    return ScannedProfile(
      name: p[2],
      homeNumber: p[3],
      tower: p[4],
      phone: p[5],
      tenamentNo: p[6] == 'NONE' ? null : p[6],
      plateNumber: p[7],
      vehicleModel: p[8],
      vehicleColor: p[9],
      vehicleType: p[10],
    );
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? homeNumber,
    String? tower,
    String? tenamentNo,
    String? email,
    List<VehicleProfile>? vehicles,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      homeNumber: homeNumber ?? this.homeNumber,
      tower: tower ?? this.tower,
      tenamentNo: tenamentNo ?? this.tenamentNo,
      email: email ?? this.email,
      role: role,
      vehicles: vehicles ?? this.vehicles,
    );
  }
}

class ScannedProfile {
  final String name;
  final String homeNumber;
  final String tower;
  final String phone;
  final String? tenamentNo;
  final String plateNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleType;

  const ScannedProfile({
    required this.name,
    required this.homeNumber,
    required this.tower,
    required this.phone,
    this.tenamentNo,
    required this.plateNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleType,
  });

  bool get hasVehicle => plateNumber != 'NONE';
  bool get hasTenament => tenamentNo != null && tenamentNo!.isNotEmpty;
}

// ─── Guest Pass ───────────────────────────────────────────────────────────────

class GuestPass {
  final String vehicleType;   // 'car' | 'bike'
  final String model;
  final String plateNumber;
  final int duration;
  final String unit;          // 'HR' | 'Day' | 'Week' | 'Month'
  final DateTime issuedAt;

  const GuestPass({
    required this.vehicleType,
    required this.model,
    required this.plateNumber,
    required this.duration,
    required this.unit,
    required this.issuedAt,
  });
}

// ─── Global app state ─────────────────────────────────────────────────────────

class AppState {
  static final AppState instance = AppState._();
  AppState._();

  bool hasSeenOnboarding = false;
  bool isLoggedIn = false;
  String selectedRole = 'resident';
  UserProfile? currentUser;
  final List<GuestPass> guestPasses = [];

  // ── Reactive theme mode ───────────────────────────────────────────────────
  // ValueNotifier<ThemeMode> is lightweight — no ChangeNotifier overhead.
  // ValueListenableBuilder in main.dart rebuilds MaterialApp on every change,
  // which propagates the new ThemeData to every Theme.of(context) call in the
  // widget tree immediately.
  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier(ThemeMode.light);

  ThemeMode get themeMode => themeModeNotifier.value;
  set themeMode(ThemeMode mode) => themeModeNotifier.value = mode;
}
