import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/qr_card_widget.dart';
import '../../widgets/quick_action_card.dart';
import '../vehicles/add_vehicle_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _guestOpen = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final profile = AppState.instance.currentUser;

    if (profile == null) {
      return Scaffold(
        backgroundColor: t.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.electricBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _AppBar(profile: profile)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _StatRow(
                    vehicleCount: profile.vehicles.length,
                    guestOpen: _guestOpen,
                    onGuestTap: () => setState(() => _guestOpen = !_guestOpen),
                  ),
                  // ── Inline Guest Pass form ────────────────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    child: _guestOpen
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _GuestPassCard(
                              onClose: () =>
                                  setState(() => _guestOpen = false),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  if (profile.vehicles.isNotEmpty)
                    QuickActionCard(vehicles: profile.vehicles)
                  else
                    _AddVehicleBanner(onAdded: () => setState(() {})),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'My Parking QR', action: 'Share'),
                  const SizedBox(height: 12),
                  QrCardWidget(profile: profile),
                  const SizedBox(height: 12),
                  QrCardActions(),
                  const SizedBox(height: 24),
                  if (profile.vehicles.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'My Vehicles',
                      action: 'Add',
                      onAction: () async {
                        final added = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) => const AddVehicleScreen()),
                        );
                        if (added == true) setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    ...profile.vehicles.map(
                      (v) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _VehicleTile(
                          vehicle: v,
                          isPrimary: profile.vehicles.indexOf(v) == 0,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(
                    height: 10 + MediaQuery.of(context).padding.bottom,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final UserProfile profile;

  const _AppBar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: c.textSecondary,
                ),
              ),
              Text(
                profile.name.split(' ').first,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: t.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Spacer(),
          _NotificationBell(),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return Stack(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            // Theme.of(context).colorScheme.surface:
            //   light → Color(0xFFFFFFFF)  |  dark → Color(0xFF1E293B)
            color: t.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.colorScheme.outline),
          ),
          child: Icon(Icons.notifications_outlined,
              color: c.textHint, size: 18),
        ),
        Positioned(
          top: 9,
          right: 9,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.electricBlue.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.electricBlue,
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final int vehicleCount;
  final bool guestOpen;
  final VoidCallback onGuestTap;

  const _StatRow({
    required this.vehicleCount,
    required this.guestOpen,
    required this.onGuestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Vehicles',
            value: '$vehicleCount',
            icon: Icons.directions_car_outlined,
            color: AppColors.electricBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'QR Scans',
            value: '14',
            icon: Icons.qr_code_rounded,
            color: AppColors.emerald,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Guest',
            value: '',
            valueIcon: guestOpen
                ? Icons.keyboard_arrow_up_rounded
                : Icons.add_circle_outline_rounded,
            icon: Icons.person_add_alt_1_outlined,
            color: const Color(0xFFF59E0B),
            onTap: onGuestTap,
            highlighted: guestOpen,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? valueIcon; // shown instead of value text when set
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool highlighted;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.valueIcon,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: highlighted
              ? color.withValues(alpha: 0.08)
              : t.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlighted
                ? color.withValues(alpha: 0.35)
                : t.colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(height: 10),
            // Show icon or text in the value slot
            valueIcon != null
                ? Icon(valueIcon, color: color, size: 24)
                : Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: highlighted ? color : t.colorScheme.onSurface,
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVehicleBanner extends StatelessWidget {
  final VoidCallback onAdded;
  const _AddVehicleBanner({required this.onAdded});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return GestureDetector(
      onTap: () async {
        final added = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
        );
        if (added == true) onAdded();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.electricBlue.withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          children: [
            // Plus circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.electricBlue.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.electricBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Register Your Vehicle',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: t.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to add your car or bike to your parking pass.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: c.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.electricBlue, size: 14),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: t.colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              if (onAction != null)
                const Icon(Icons.add_rounded,
                    color: AppColors.electricBlue, size: 15),
              if (onAction != null) const SizedBox(width: 3),
              Text(
                action,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.electricBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final VehicleProfile vehicle;
  final bool isPrimary;

  const _VehicleTile({required this.vehicle, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final isBike = vehicle.type == 'bike' ||
        vehicle.model.toLowerCase().contains('bike') ||
        vehicle.model.toLowerCase().contains('enfield');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            isBike ? Icons.two_wheeler_rounded : Icons.directions_car_outlined,
            color: c.textHint,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.model,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: t.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${vehicle.plateNumber} · ${vehicle.color}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: c.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (isPrimary)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                // cardElevated has no Theme equivalent → keep from extension
                color: c.cardElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.colorScheme.outline),
              ),
              child: Text(
                'Primary',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: c.textSecondary,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: c.textHint, size: 18),
        ],
      ),
    );
  }
}

// ── Guest Pass inline card ─────────────────────────────────────────────────────

class _GuestPassCard extends StatefulWidget {
  final VoidCallback onClose;
  const _GuestPassCard({required this.onClose});

  @override
  State<_GuestPassCard> createState() => _GuestPassCardState();
}

class _GuestPassCardState extends State<_GuestPassCard> {
  String _vehicleType  = 'car'; // 'car' | 'bike'
  String _durationUnit = 'HR';  // 'HR' | 'Day' | 'Week' | 'Month'
  final _modelCtrl    = TextEditingController();
  final _plateCtrl    = TextEditingController();
  final _durationCtrl = TextEditingController();
  bool _saving = false;
  bool _saved  = false;

  static const _units = ['HR', 'Day', 'Week', 'Month'];

  @override
  void dispose() {
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || _saved) return;
    final model    = _modelCtrl.text.trim();
    final plate    = _plateCtrl.text.trim();
    final durStr   = _durationCtrl.text.trim();

    if (model.isEmpty || plate.isEmpty || durStr.isEmpty) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Persist guest pass to global state
    AppState.instance.guestPasses.insert(0, GuestPass(
      vehicleType: _vehicleType,
      model:       model,
      plateNumber: plate,
      duration:    int.tryParse(durStr) ?? 1,
      unit:        _durationUnit,
      issuedAt:    DateTime.now(),
    ));

    setState(() { _saving = false; _saved = true; });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    const amber = Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: amber.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: amber.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: amber.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.person_add_alt_1_outlined,
                      color: amber, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'Guest Vehicle Pass',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Icon(Icons.close_rounded,
                      color: c.textHint, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _saved
                ? _SuccessBanner()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Vehicle type selector ────────────────────────────
                      _Label('VEHICLE TYPE'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _TypeChip(
                            icon: Icons.directions_car_outlined,
                            label: 'Car',
                            selected: _vehicleType == 'car',
                            onTap: () =>
                                setState(() => _vehicleType = 'car'),
                          ),
                          const SizedBox(width: 10),
                          _TypeChip(
                            icon: Icons.two_wheeler_rounded,
                            label: 'Bike',
                            selected: _vehicleType == 'bike',
                            onTap: () =>
                                setState(() => _vehicleType = 'bike'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Vehicle model ────────────────────────────────────
                      _Label('VEHICLE MODEL'),
                      const SizedBox(height: 8),
                      _GuestField(
                        controller: _modelCtrl,
                        hint: _vehicleType == 'bike'
                            ? 'e.g. Royal Enfield, Honda Activa'
                            : 'e.g. Maruti Swift, Honda City',
                        icon: _vehicleType == 'bike'
                            ? Icons.two_wheeler_rounded
                            : Icons.directions_car_outlined,
                        capitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 14),

                      // ── Plate number ─────────────────────────────────────
                      _Label('NUMBER PLATE'),
                      const SizedBox(height: 8),
                      _GuestField(
                        controller: _plateCtrl,
                        hint: 'e.g. MH 12 AB 3456',
                        icon: Icons.tag_rounded,
                        capitalization: TextCapitalization.characters,
                        inputFormatters: [
                          // Force uppercase as user types
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9 ]')),
                          _UpperCaseFormatter(),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── Duration + unit ───────────────────────────────────
                      _Label('PARKING DURATION'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Number input
                          Expanded(
                            flex: 3,
                            child: _GuestField(
                              controller: _durationCtrl,
                              hint: 'e.g. 2',
                              icon: Icons.access_time_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Unit dropdown
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: t.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: t.colorScheme.outline),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _durationUnit,
                                  isExpanded: true,
                                  icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: c.textSecondary,
                                      size: 18),
                                  dropdownColor: t.colorScheme.surface,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: c.textPrimary,
                                  ),
                                  items: _units
                                      .map((u) => DropdownMenuItem(
                                            value: u,
                                            child: Text(u),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _durationUnit = v!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Save button ──────────────────────────────────────
                      GestureDetector(
                        onTap: _saving ? null : _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: amber,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: amber.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.white,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Issue Guest Pass',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
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

// ── Guest pass helpers ─────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    const amber = Color(0xFFF59E0B);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? amber.withValues(alpha: 0.10)
                : t.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? amber.withValues(alpha: 0.50)
                  : t.colorScheme.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? amber : context.colors.textHint,
                  size: 17),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? amber : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextCapitalization capitalization;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;

  const _GuestField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.capitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: t.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: capitalization,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(
            fontSize: 14,
            color: c.textPrimary,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.inter(fontSize: 14, color: c.textHint),
          prefixIcon: Icon(icon, color: c.textSecondary, size: 18),
          suffixIcon: suffix,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}

// Forces every character to uppercase as the user types
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue updated) =>
      updated.copyWith(text: updated.text.toUpperCase());
}

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.emerald, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Guest Pass Issued!',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The guest vehicle is now registered.',
            style: GoogleFonts.inter(
                fontSize: 12, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
