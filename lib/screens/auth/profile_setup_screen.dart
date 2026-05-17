import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../navigation/main_navigation.dart';

// ─── Per-vehicle mutable state ────────────────────────────────────────────────
class _VehicleEntry {
  final TextEditingController plateController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  String type = 'car';
  String color = 'White';

  void dispose() {
    plateController.dispose();
    modelController.dispose();
  }
}

class ProfileSetupScreen extends StatefulWidget {
  final String phone;
  final String role;

  const ProfileSetupScreen({
    super.key,
    required this.phone,
    required this.role,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1 — Personal Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 2 — Society Details
  // Starts null so the address field stays hidden until user picks an option.
  String? _selectedTower;
  final _homeNumberController = TextEditingController();
  final _tenamentController = TextEditingController();
  final _parkingSlotController = TextEditingController();
  final _towers = ['Tower', 'Wing', 'Tenement'];

  // Step 3 — Vehicles (supports multiple)
  bool _hasVehicle = false;
  final List<_VehicleEntry> _vehicleEntries = [_VehicleEntry()];
  static const _colors = ['White', 'Black', 'Silver', 'Grey', 'Red', 'Blue', 'Green', 'Orange'];

  // Step 4 — QR Generated
  UserProfile? _generatedProfile;

  static const _totalSteps = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _homeNumberController.dispose();
    _tenamentController.dispose();
    _parkingSlotController.dispose();
    for (final e in _vehicleEntries) {
      e.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    // UI demo — no field validation, proceed freely
    if (_currentStep == 2) {
      _submit();
      return;
    }
    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    if (_currentStep == 0) return;
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    // UI demo — use defaults for any blank field
    final name = _nameController.text.trim().isEmpty
        ? 'Demo User'
        : _nameController.text.trim();
    final homeNumber = _homeNumberController.text.trim().isEmpty
        ? 'A-101'
        : _homeNumberController.text.trim();

    final vehicles = <VehicleProfile>[];
    if (_hasVehicle) {
      for (final e in _vehicleEntries) {
        vehicles.add(VehicleProfile(
          plateNumber: e.plateController.text.trim().isEmpty
              ? 'MH01AB1234'
              : e.plateController.text.trim().toUpperCase(),
          model: e.modelController.text.trim().isEmpty
              ? 'My Vehicle'
              : e.modelController.text.trim(),
          color: e.color,
          type: e.type,
        ));
      }
    }

    final selectedTower = _selectedTower ?? 'Tower A';
    final isTenement = selectedTower == 'Tenement';

    final profile = UserProfile(
      id: 'RES${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: widget.phone,
      homeNumber: isTenement ? '-' : homeNumber,
      tower: selectedTower,
      tenamentNo: isTenement
          ? (_tenamentController.text.trim().isEmpty
              ? null
              : _tenamentController.text.trim())
          : null,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      role: widget.role,
      vehicles: vehicles,
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    AppState.instance
      ..currentUser = profile
      ..isLoggedIn = true;

    setState(() {
      _generatedProfile = profile;
      _isSubmitting = false;
      _currentStep = _totalSteps;
    });

    _pageController.animateToPage(
      _totalSteps,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onBack: _currentStep > 0 && _currentStep < _totalSteps
                  ? _prevStep
                  : null,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1PersonalInfo(
                    nameController: _nameController,
                    emailController: _emailController,
                    phone: widget.phone,
                  ),
                  _Step2SocietyDetails(
                    selectedTower: _selectedTower,
                    towers: _towers,
                    homeNumberController: _homeNumberController,
                    tenamentController: _tenamentController,
                    parkingSlotController: _parkingSlotController,
                    onTowerChanged: (v) {
                    setState(() {
                      _selectedTower = v;
                      // Clear the address field when the type changes
                      _homeNumberController.clear();
                      _tenamentController.clear();
                    });
                  },
                  ),
                  _Step3Vehicle(
                    hasVehicle: _hasVehicle,
                    vehicleEntries: _vehicleEntries,
                    colors: _colors,
                    onHasVehicleChanged: (v) => setState(() => _hasVehicle = v),
                    onAddVehicle: () =>
                        setState(() => _vehicleEntries.add(_VehicleEntry())),
                    onRemoveVehicle: (i) => setState(() {
                      _vehicleEntries[i].dispose();
                      _vehicleEntries.removeAt(i);
                    }),
                    onRebuild: () => setState(() {}),
                  ),
                  _Step4QrGenerated(
                    profile: _generatedProfile,
                    isLoading: _isSubmitting,
                    onContinue: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) =>
                              MainNavigation(role: widget.role),
                        ),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_currentStep < _totalSteps)
              _BottomActionBar(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                isSubmitting: _isSubmitting,
                onNext: _nextStep,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Progress Bar ────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const _TopBar({
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // QR-generated step — hide the entire top bar, the screen handles its own layout
    if (currentStep >= totalSteps) return const SizedBox.shrink();

    final c = context.colors;
    final progress = (currentStep + 1) / totalSteps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.border),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ),
                )
              else
                const SizedBox(width: 36),
              const Spacer(),
              if (currentStep < totalSteps)
                Text(
                  'Step ${currentStep + 1} of $totalSteps',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              const Spacer(),
              const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 16),
          if (currentStep < totalSteps) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: c.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.electricBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Step 1: Personal Info ────────────────────────────────────────────────────

class _Step1PersonalInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final String phone;

  const _Step1PersonalInfo({
    required this.nameController,
    required this.emailController,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIcon(icon: Icons.person_rounded, gradient: AppColors.blueGradient),
          const SizedBox(height: 24),
          Text(
            'About You',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This info will appear on your parking QR.',
            style: GoogleFonts.inter(fontSize: 14, color: c.textSecondary),
          ),
          const SizedBox(height: 32),
          _FormLabel(label: 'Full Name'),
          const SizedBox(height: 8),
          _StyledTextField(
            controller: nameController,
            hint: 'e.g. Arjun Mehta',
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          _FormLabel(label: 'Email Address'),
          const SizedBox(height: 8),
          _StyledTextField(
            controller: emailController,
            hint: 'Optional',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _FormLabel(label: 'Mobile Number'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_android_rounded,
                    color: c.textHint, size: 20),
                const SizedBox(width: 12),
                Text(
                  phone,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: c.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Verified',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Society Details ──────────────────────────────────────────────────

class _Step2SocietyDetails extends StatelessWidget {
  final String? selectedTower;
  final List<String> towers;
  final TextEditingController homeNumberController;
  final TextEditingController tenamentController;
  final TextEditingController parkingSlotController;
  final ValueChanged<String> onTowerChanged;

  const _Step2SocietyDetails({
    required this.selectedTower,
    required this.towers,
    required this.homeNumberController,
    required this.tenamentController,
    required this.parkingSlotController,
    required this.onTowerChanged,
  });

  bool get _hasSelection => selectedTower != null;
  bool get _isTenement => selectedTower == 'Tenement';
  bool get _isWing => selectedTower?.startsWith('Wing') ?? false;

  // ── Dynamic field properties based on selection type ─────────────────────

  String get _fieldLabel {
    if (_isTenement) return 'Tenement No.';
    if (_isWing) return 'Flat Number';
    return 'Flat / Unit Number';
  }

  String get _fieldSubtitle {
    if (_isTenement) return 'Survey / tenement number from your agreement or society records';
    if (_isWing) return 'Your flat or unit number in ${selectedTower ?? ''}';
    return 'Your flat, unit, or house number in ${selectedTower ?? ''}';
  }

  String get _fieldHint {
    if (_isTenement) return 'e.g. T-1234 or 56/A (optional)';
    if (_isWing) return 'e.g. 304, Flat 12, W1-304';
    return 'e.g. 704, B-12, House 5';
  }

  IconData get _fieldIcon {
    if (_isTenement) return Icons.tag_rounded;
    return Icons.home_outlined;
  }

  TextEditingController get _fieldController =>
      _isTenement ? tenamentController : homeNumberController;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIcon(
            icon: Icons.apartment_rounded,
            gradient: AppColors.emeraldGradient,
          ),
          const SizedBox(height: 24),
          Text(
            'Your Home',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Guards use this to verify where you live in the society.',
            style: GoogleFonts.inter(fontSize: 14, color: c.textSecondary),
          ),
          const SizedBox(height: 32),

          // ── Tower / Wing / Tenement dropdown ───────────────────────────
          _FormLabel(label: 'Tower / Wing / Tenement'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasSelection
                    ? AppColors.electricBlue.withValues(alpha: 0.5)
                    : c.border,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  value: selectedTower,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: c.card,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: c.textSecondary),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 2),
                  // Placeholder shown when nothing is selected yet
                  hint: Row(
                    children: [
                      Icon(Icons.apartment_outlined,
                          color: c.textHint, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Select Any One',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: c.textHint,
                        ),
                      ),
                    ],
                  ),
                  items: towers
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: c.textPrimary,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onTowerChanged(v);
                  },
                ),
              ),
            ),
          ),

          // ── Address field — hidden until a type is selected ─────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _hasSelection
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _FormLabel(label: _fieldLabel),
                      const SizedBox(height: 4),
                      Text(
                        _fieldSubtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: c.textHint),
                      ),
                      const SizedBox(height: 8),
                      _StyledTextField(
                        key: ValueKey(selectedTower),
                        controller: _fieldController,
                        hint: _fieldHint,
                        icon: _fieldIcon,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 20),

                      // ── Parking Slot ──────────────────────────────────
                      _FormLabel(label: 'Parking Slot'),
                      const SizedBox(height: 8),
                      _StyledTextField(
                        controller: parkingSlotController,
                        hint: 'e.g. P1-045 (optional)',
                        icon: Icons.local_parking_rounded,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),

                      // ── Info banner ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.electricBlue
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.electricBlue, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your details are encoded in your QR. Guards see this when they scan.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.electricBlueLight,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // ── Nudge shown while nothing is selected ───────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: !_hasSelection
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: c.border,
                            style: BorderStyle.solid),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_rounded,
                              color: c.textHint, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select your building type above to fill in your unit details.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: c.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Vehicle Details ──────────────────────────────────────────────────

class _Step3Vehicle extends StatelessWidget {
  final bool hasVehicle;
  final List<_VehicleEntry> vehicleEntries;
  final List<String> colors;
  final ValueChanged<bool> onHasVehicleChanged;
  final VoidCallback onAddVehicle;
  final ValueChanged<int> onRemoveVehicle;
  final VoidCallback onRebuild;

  const _Step3Vehicle({
    required this.hasVehicle,
    required this.vehicleEntries,
    required this.colors,
    required this.onHasVehicleChanged,
    required this.onAddVehicle,
    required this.onRemoveVehicle,
    required this.onRebuild,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIcon(
            icon: Icons.directions_car_rounded,
            gradient: [const Color(0xFF7C4DFF), const Color(0xFF512DA8)],
          ),
          const SizedBox(height: 24),
          Text(
            'Your Vehicles',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Link your vehicles to your parking pass.',
            style: GoogleFonts.inter(fontSize: 14, color: c.textSecondary),
          ),
          const SizedBox(height: 28),

          // ── "I own a vehicle" toggle ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'I own a vehicle',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: hasVehicle,
                  onChanged: onHasVehicleChanged,
                  activeTrackColor: AppColors.electricBlue,
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: c.cardElevated,
                ),
              ],
            ),
          ),

          // ── Vehicle cards ───────────────────────────────────────────────
          if (hasVehicle) ...[
            const SizedBox(height: 20),
            ...List.generate(vehicleEntries.length, (i) {
              final entry = vehicleEntries[i];
              return _VehicleCard(
                index: i,
                entry: entry,
                colors: colors,
                canRemove: vehicleEntries.length > 1,
                onRemove: () => onRemoveVehicle(i),
                onRebuild: onRebuild,
              );
            }),

            // ── Add Another Vehicle button ──────────────────────────────
            GestureDetector(
              onTap: onAddVehicle,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.electricBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.electricBlue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Add Another Vehicle',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.no_transfer_rounded,
                      color: c.textHint, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'No vehicle linked',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You can add one later from Settings.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: c.textHint),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Single vehicle card ──────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final int index;
  final _VehicleEntry entry;
  final List<String> colors;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onRebuild;

  const _VehicleCard({
    required this.index,
    required this.entry,
    required this.colors,
    required this.canRemove,
    required this.onRemove,
    required this.onRebuild,
  });

  Color _colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'white':  return const Color(0xFFE0E0E0);
      case 'black':  return const Color(0xFF212121);
      case 'silver': return const Color(0xFFC0C0C0);
      case 'grey':   return Colors.grey;
      case 'red':    return Colors.red;
      case 'blue':   return Colors.blue;
      case 'green':  return Colors.green;
      case 'orange': return Colors.orange;
      default:       return AppColors.electricBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Icon(
                  entry.type == 'bike'
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_outlined,
                  color: AppColors.electricBlue,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Vehicle ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.textPrimary,
                  ),
                ),
                const Spacer(),
                if (canRemove)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.danger, size: 16),
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: cs.divider),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type chips ────────────────────────────────────────
                _FormLabel(label: 'Vehicle Type'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: 'Car',
                        icon: Icons.directions_car_rounded,
                        selected: entry.type == 'car',
                        onTap: () {
                          entry.type = 'car';
                          onRebuild();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeChip(
                        label: 'Bike',
                        icon: Icons.two_wheeler_rounded,
                        selected: entry.type == 'bike',
                        onTap: () {
                          entry.type = 'bike';
                          onRebuild();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Number plate ──────────────────────────────────────
                _FormLabel(label: 'Number Plate'),
                const SizedBox(height: 8),
                _StyledTextField(
                  controller: entry.plateController,
                  hint: 'e.g. MH 02 AB 1234',
                  icon: Icons.credit_card_rounded,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Make & Model ──────────────────────────────────────
                _FormLabel(label: 'Make & Model'),
                const SizedBox(height: 8),
                _StyledTextField(
                  controller: entry.modelController,
                  hint: 'e.g. Honda City',
                  icon: Icons.drive_eta_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // ── Colour ────────────────────────────────────────────
                _FormLabel(label: 'Vehicle Colour'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((colorName) {
                    final selected = colorName == entry.color;
                    return GestureDetector(
                      onTap: () {
                        entry.color = colorName;
                        onRebuild();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.electricBlue
                              : cs.cardElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.electricBlue
                                : cs.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _colorFromName(colorName),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: cs.border, width: 0.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              colorName,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? Colors.white
                                    : cs.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4: QR Generated ─────────────────────────────────────────────────────

class _Step4QrGenerated extends StatelessWidget {
  final UserProfile? profile;
  final bool isLoading;
  final VoidCallback onContinue;

  const _Step4QrGenerated({
    required this.profile,
    required this.isLoading,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || profile == null) {
      return _LoadingState();
    }

    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: AppColors.emeraldGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'Your QR is Ready!',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Print this and stick it on your car dashboard or gate pass.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: c.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          // QR Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: AppColors.blueGradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_parking_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ParkQR · Society Pass',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // QR code
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: profile!.qrData,
                    version: QrVersions.auto,
                    size: 160,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.deepNavy,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.navyMid,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile!.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  '${profile!.tower} · ${profile!.homeNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
                if (profile!.vehicles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      profile!.vehicles.first.plateNumber,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.electricBlueLight,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningDim,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.print_rounded,
                    color: AppColors.warning, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Print this QR and keep it with your vehicle. Guards and residents can scan it to see your details.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.warning,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Continue button
          GestureDetector(
            onTap: onContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.blueGradient),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Open the App →',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Download / Print QR',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.electricBlue),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Generating your QR...',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Setting up your parking pass',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;

  const _StepIcon({required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;

  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;

  const _StyledTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: style ??
          GoogleFonts.inter(
            fontSize: 15,
            color: c.textPrimary,
            fontWeight: FontWeight.w500,
          ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: c.textSecondary, size: 20),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: AppColors.blueGradient)
              : null,
          color: selected ? null : c.cardElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.electricBlue : c.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.white : c.textSecondary,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isSubmitting;
  final VoidCallback onNext;

  const _BottomActionBar({
    required this.currentStep,
    required this.totalSteps,
    required this.isSubmitting,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLast = currentStep == totalSteps - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: GestureDetector(
        onTap: isSubmitting ? null : onNext,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.blueGradient),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    isLast ? 'Create My Pass' : 'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
