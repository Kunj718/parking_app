import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/qr_card_widget.dart';
import '../../widgets/quick_action_card.dart';

class DashboardScreen extends StatelessWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // t — standard Theme handles (scaffoldBackgroundColor, colorScheme, etc.)
    // Each private widget fetches context.colors for custom extension slots.
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
      // Theme.of(context).scaffoldBackgroundColor flips automatically:
      //   light → Color(0xFFF5F7FC)  |  dark → Color(0xFF0F172A)
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
                  _StatRow(vehicleCount: profile.vehicles.length),
                  const SizedBox(height: 20),
                  if (profile.vehicles.isNotEmpty)
                    QuickActionCard(vehicle: profile.vehicles.first)
                  else
                    const _NoVehicleBanner(),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'My Parking QR', action: 'Share'),
                  const SizedBox(height: 12),
                  QrCardWidget(profile: profile),
                  const SizedBox(height: 12),
                  QrCardActions(),
                  const SizedBox(height: 24),
                  if (profile.vehicles.isNotEmpty) ...[
                    _SectionHeader(title: 'My Vehicles', action: 'Add'),
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
                  const SizedBox(height: 100),
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
          const SizedBox(width: 10),
          _Avatar(name: profile.name),
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

  const _StatRow({required this.vehicleCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'My Vehicles',
            value: '$vehicleCount',
            icon: Icons.directions_car_outlined,
            color: AppColors.electricBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'QR Scans',
            value: '14',
            icon: Icons.qr_code_rounded,
            color: AppColors.emerald,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Entry Today',
            value: '27',
            icon: Icons.login_rounded,
            color: const Color(0xFF7C4DFF),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        // Adaptive card surface — white in light, slate-800 in dark
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: t.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoVehicleBanner extends StatelessWidget {
  const _NoVehicleBanner();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car_outlined,
              color: c.textHint, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Vehicle Linked',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: t.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Add a vehicle in Settings to get started.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: c.textSecondary,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({required this.title, required this.action});

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
          onTap: () {},
          child: Text(
            action,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.electricBlue,
            ),
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
