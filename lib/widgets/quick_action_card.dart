import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class QuickActionCard extends StatefulWidget {
  final List<VehicleProfile> vehicles;

  const QuickActionCard({
    super.key,
    required this.vehicles,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final count    = widget.vehicles.length;
    final hasMany  = count > 1;

    return Column(
      children: [
        // ── Swipeable card ───────────────────────────────────────────────────
        SizedBox(
          // Fixed height so the PageView doesn't expand unboundedly
          height: 188,
          child: PageView.builder(
            controller: _pageController,
            itemCount: count,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) =>
                _VehiclePage(vehicle: widget.vehicles[i], index: i, total: count),
          ),
        ),

        // ── Dot indicators (only when >1 vehicle) ────────────────────────────
        if (hasMany) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) {
              final active = i == _currentPage;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width:  active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.electricBlue
                        : c.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

// ── Single vehicle page inside the PageView ────────────────────────────────────

class _VehiclePage extends StatelessWidget {
  final VehicleProfile vehicle;
  final int index;
  final int total;

  const _VehiclePage({
    required this.vehicle,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final isBike = vehicle.type == 'bike' ||
        vehicle.model.toLowerCase().contains('bike') ||
        vehicle.model.toLowerCase().contains('enfield');

    return Container(
      // Small horizontal margin so adjacent cards peek slightly on swipe
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────────────────────
          Row(
            children: [
              Text(
                total > 1 ? 'Vehicle ${index + 1} of $total' : 'My Vehicle',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: c.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              _StatusChip(label: 'Registered', color: AppColors.emerald),
            ],
          ),

          const SizedBox(height: 14),

          // ── Vehicle icon + name + colour ─────────────────────────────────
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: c.cardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border),
                ),
                child: Icon(
                  isBike
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_outlined,
                  color: AppColors.electricBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.model,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _colorFromName(vehicle.color),
                            shape: BoxShape.circle,
                            border: Border.all(color: c.border, width: 1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vehicle.color,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: c.divider),
          const SizedBox(height: 14),

          // ── Plate + Type ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Plate',
                  value: vehicle.plateNumber,
                  icon: Icons.credit_card_outlined,
                ),
              ),
              Expanded(
                child: _InfoTile(
                  label: 'Type',
                  value: vehicle.type == 'bike'
                      ? 'Two Wheeler'
                      : 'Four Wheeler',
                  icon: Icons.category_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('white'))  return const Color(0xFFE0E0E0);
    if (lower.contains('black'))  return const Color(0xFF424242);
    if (lower.contains('red'))    return Colors.red;
    if (lower.contains('blue'))   return AppColors.electricBlue;
    if (lower.contains('grey') || lower.contains('gray')) return Colors.grey;
    if (lower.contains('silver')) return const Color(0xFFC0C0C0);
    if (lower.contains('orange')) return Colors.orange;
    return AppColors.textDim;
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 14, color: c.textHint),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(fontSize: 10, color: c.textHint)),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
