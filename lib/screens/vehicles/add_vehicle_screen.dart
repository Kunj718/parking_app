import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';

// ── Per-vehicle mutable state (mirrors the one in profile_setup_screen) ────────
class _VehicleEntry {
  final TextEditingController plateController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  String type  = 'car';
  String color = 'White';

  void dispose() {
    plateController.dispose();
    modelController.dispose();
  }
}

// ── Colour palette (same as profile setup) ────────────────────────────────────
const _kColors = [
  'White', 'Black', 'Silver', 'Grey',
  'Red',   'Blue',  'Green',  'Orange',
];

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final List<_VehicleEntry> _entries = [_VehicleEntry()];
  bool _saving = false;

  @override
  void dispose() {
    for (final e in _entries) e.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final newVehicles = _entries.map((e) => VehicleProfile(
      plateNumber: e.plateController.text.trim().isEmpty
          ? 'MH01AB0000'
          : e.plateController.text.trim().toUpperCase(),
      model: e.modelController.text.trim().isEmpty
          ? 'My Vehicle'
          : e.modelController.text.trim(),
      color: e.color,
      type:  e.type,
    )).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final existing = AppState.instance.currentUser!.vehicles;
    AppState.instance.currentUser =
        AppState.instance.currentUser!.copyWith(
      vehicles: [...existing, ...newVehicles],
    );

    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.of(context).pop(true); // true = vehicles updated
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: t.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.colorScheme.outline),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register Vehicle',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Add your vehicle to your parking pass',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: c.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Scrollable form ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  // Vehicle cards
                  ...List.generate(_entries.length, (i) => _VehicleCard(
                    index: i,
                    entry: _entries[i],
                    canRemove: _entries.length > 1,
                    onRemove: () => setState(() {
                      _entries[i].dispose();
                      _entries.removeAt(i);
                    }),
                    onRebuild: () => setState(() {}),
                  )),

                  // Add another vehicle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _entries.add(_VehicleEntry())),
                    child: Container(
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

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Save button ─────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: t.scaffoldBackgroundColor,
                border: Border(
                    top: BorderSide(color: t.colorScheme.outline)),
              ),
              child: GestureDetector(
                onTap: _saving ? null : _save,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: AppColors.blueGradient),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricBlue.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Save Vehicle',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vehicle form card ──────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final int index;
  final _VehicleEntry entry;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onRebuild;

  const _VehicleCard({
    required this.index,
    required this.entry,
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
    final t  = Theme.of(context);
    final c  = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.colorScheme.outline),
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
                    color: t.colorScheme.onSurface,
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

          Divider(height: 1, color: t.colorScheme.outline),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type chips
                _Label('VEHICLE TYPE'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: 'Car',
                        icon: Icons.directions_car_rounded,
                        selected: entry.type == 'car',
                        onTap: () { entry.type = 'car'; onRebuild(); },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeChip(
                        label: 'Bike',
                        icon: Icons.two_wheeler_rounded,
                        selected: entry.type == 'bike',
                        onTap: () { entry.type = 'bike'; onRebuild(); },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Number plate
                _Label('NUMBER PLATE'),
                const SizedBox(height: 8),
                _Field(
                  controller: entry.plateController,
                  hint: 'e.g. MH 02 AB 1234',
                  icon: Icons.credit_card_rounded,
                  capitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                    _UpperCaseFormatter(),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 16),

                // Make & model
                _Label('MAKE & MODEL'),
                const SizedBox(height: 8),
                _Field(
                  controller: entry.modelController,
                  hint: entry.type == 'bike'
                      ? 'e.g. Royal Enfield, Honda Activa'
                      : 'e.g. Honda City, Maruti Swift',
                  icon: Icons.drive_eta_rounded,
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Colour picker
                _Label('VEHICLE COLOUR'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kColors.map((name) {
                    final sel = name == entry.color;
                    return GestureDetector(
                      onTap: () { entry.color = name; onRebuild(); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.electricBlue : c.cardElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel ? AppColors.electricBlue : c.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _colorFromName(name),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: c.border, width: 0.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: sel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: sel
                                    ? Colors.white
                                    : c.textSecondary,
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

// ── Helpers ────────────────────────────────────────────────────────────────────

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue updated) =>
      updated.copyWith(text: updated.text.toUpperCase());
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: context.colors.textSecondary,
          letterSpacing: 1.2,
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextCapitalization capitalization;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double letterSpacing;
  final FontWeight fontWeight;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.capitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.letterSpacing = 0,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return TextField(
      controller: controller,
      textCapitalization: capitalization,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: c.textPrimary,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: c.textSecondary, size: 20),
        filled: true,
        fillColor: t.scaffoldBackgroundColor,
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
                    color: AppColors.electricBlue.withValues(alpha: 0.28),
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
