import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class QuickActionCard extends StatelessWidget {
  final VehicleProfile vehicle;
  final VoidCallback onAddGuest;

  const QuickActionCard({
    super.key,
    required this.vehicle,
    required this.onAddGuest,
  });

  @override
  Widget build(BuildContext context) {
    final isBike = vehicle.type == 'bike' ||
        vehicle.model.toLowerCase().contains('bike') ||
        vehicle.model.toLowerCase().contains('enfield');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'My Vehicle',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              _StatusChip(label: 'Registered', color: AppColors.emerald),
            ],
          ),
          const SizedBox(height: 14),
          // Vehicle row
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.darkCardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
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
                        color: Colors.white,
                      ),
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
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vehicle.color,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
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
          const Divider(height: 1, color: AppColors.darkDivider),
          const SizedBox(height: 14),
          // Footer row — plate + add guest
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Plate',
                  value: vehicle.plateNumber,
                  icon: Icons.credit_card_outlined,
                ),
              ),
              GestureDetector(
                onTap: onAddGuest,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          color: AppColors.emerald, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Add Guest',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald,
                        ),
                      ),
                    ],
                  ),
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
    if (lower.contains('white')) return Colors.white;
    if (lower.contains('black')) return const Color(0xFF424242);
    if (lower.contains('red')) return Colors.red;
    if (lower.contains('blue')) return AppColors.electricBlue;
    if (lower.contains('grey') || lower.contains('gray')) return Colors.grey;
    if (lower.contains('silver')) return const Color(0xFFC0C0C0);
    if (lower.contains('orange')) return Colors.orange;
    return AppColors.textSecondary;
  }
}

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
        border: Border.all(color: color.withValues(alpha: 0.25)),
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

  const _InfoTile(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
