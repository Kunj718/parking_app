import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/mock_data.dart';
import '../../widgets/license_plate_widget.dart';

class TenementDetailScreen extends StatelessWidget {
  final TenementRecord record;

  const TenementDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    // AdminTheme applies the shadcn/Tailwind admin palette to this pushed route.
    // The Builder provides a new ctx so Theme.of(ctx) returns the admin theme.
    return AdminTheme(
      child: Builder(
        builder: (ctx) {
          final t = Theme.of(ctx);

          return Scaffold(
            backgroundColor: t.scaffoldBackgroundColor,
            body: Column(
              children: [
                // ── Custom App Bar ─────────────────────────────────────────
                _DetailAppBar(unitNumber: record.unitNumber),

                // ── Scrollable body ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileCard(record: record),
                        const SizedBox(height: 20),
                        _SectionLabel(label: 'Contact Information'),
                        const SizedBox(height: 10),
                        _ContactCard(phone: record.phone),
                        const SizedBox(height: 20),
                        _SectionLabel(label: 'Vehicle Details'),
                        const SizedBox(height: 10),
                        _VehicleCard(record: record),
                        const SizedBox(height: 20),
                        _SectionLabel(label: 'Tenement Information'),
                        const SizedBox(height: 10),
                        _TenementInfoRow(record: record),
                        // ── Tenant details block ───────────────────────────
                        if (record.isTenant) ...[
                          const SizedBox(height: 20),
                          _SectionLabel(label: 'Tenant Information'),
                          const SizedBox(height: 10),
                          _TenantInfoCard(record: record),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── Bottom action buttons ──────────────────────────────────
                _BottomActions(phone: record.phone),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Custom app bar ─────────────────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  final String unitNumber;
  const _DetailAppBar({required this.unitNumber});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: t.scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: t.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.colorScheme.outline),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: c.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tenement Details',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: t.colorScheme.onSurface,
                  ),
                ),
                Text(
                  unitNumber,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Share icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.colorScheme.outline),
            ),
            child: Icon(
              Icons.ios_share_rounded,
              color: c.textSecondary,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile card ───────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final TenementRecord record;
  const _ProfileCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final active = record.isQrActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar circle
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.emerald,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.residentName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: t.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Chip row: status + optional tenant badge
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Registration status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.emerald.withValues(alpha: 0.10)
                                : c.cardElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? AppColors.emerald.withValues(alpha: 0.30)
                                  : t.colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.emerald
                                      : c.textHint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                active
                                    ? 'Active Registration'
                                    : 'App Pending',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: active
                                      ? AppColors.emerald
                                      : c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tenant badge — only when occupant is renting
                        if (record.isTenant)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.key_rounded,
                                  size: 11,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Tenant',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Contact card ───────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final String phone;
  const _ContactCard({required this.phone});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.cardElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_outlined,
              color: t.colorScheme.onSurface,
              size: 17,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: phone));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Phone number copied',
                      style: GoogleFonts.inter(fontSize: 13)),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Icon(Icons.copy_rounded, color: c.textHint, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Vehicle card ───────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final TenementRecord record;
  const _VehicleCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final isBike = record.vehicleType == 'bike';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: c.cardElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isBike
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_outlined,
                  color: c.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.vehicleModel,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: t.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _ColorDot(colorName: record.vehicleColor),
                      const SizedBox(width: 6),
                      Text(
                        record.vehicleColor,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          LicensePlateWidget(plateNumber: record.vehiclePlate),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final String colorName;
  const _ColorDot({required this.colorName});

  Color _resolve() {
    final l = colorName.toLowerCase();
    if (l.contains('white')) return const Color(0xFFE0E0E0);
    if (l.contains('black')) return const Color(0xFF424242);
    if (l.contains('red')) return Colors.red;
    if (l.contains('blue')) return AppColors.electricBlue;
    if (l.contains('grey') || l.contains('gray')) return Colors.grey;
    if (l.contains('silver')) return const Color(0xFFC0C0C0);
    if (l.contains('orange')) return Colors.orange;
    return AppColors.textFaint;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _resolve(),
        shape: BoxShape.circle,
        border: Border.all(
            color: Theme.of(context).colorScheme.outline, width: 1),
      ),
    );
  }
}

// ── Tenement info row (2 tiles) ────────────────────────────────────────────────

class _TenementInfoRow extends StatelessWidget {
  final TenementRecord record;
  const _TenementInfoRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final active = record.isQrActive;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Unit Number',
                value: record.unitNumber,
                valueColor: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                label: 'Status',
                value: active ? 'Active' : 'Pending',
                valueColor: active ? AppColors.emerald : AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoTile(
          label: 'Occupancy Type',
          value: record.isTenant ? 'Tenant (Renting)' : 'Owner',
          valueColor: record.isTenant
              ? const Color(0xFFF59E0B)
              : null,
          icon: record.isTenant
              ? Icons.key_rounded
              : Icons.home_rounded,
        ),
      ],
    );
  }
}

// ── Tenant information card ────────────────────────────────────────────────────
// Shown only when record.isTenant == true. Consolidates name, contact and
// vehicle so the admin can see all tenant-specific details at a glance.

class _TenantInfoCard extends StatelessWidget {
  final TenementRecord record;
  const _TenantInfoCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    const amber = Color(0xFFF59E0B);
    final isBike = record.vehicleType == 'bike';

    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: amber.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: amber.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.key_rounded, size: 15, color: amber),
                const SizedBox(width: 8),
                Text(
                  'Tenant Occupant',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: amber,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: amber.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'Renting',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: amber,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Name row ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: amber.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: amber, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.residentName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: t.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.phone,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: c.textSecondary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Copy phone icon
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: record.phone));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Phone number copied',
                            style: GoogleFonts.inter(fontSize: 13)),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Icon(Icons.copy_rounded,
                      color: c.textHint, size: 16),
                ),
              ],
            ),
          ),

          // ── Vehicle row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TENANT\'S VEHICLE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: c.textHint,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.cardElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isBike
                            ? Icons.two_wheeler_rounded
                            : Icons.directions_car_outlined,
                        color: c.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.vehicleModel,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: t.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _ColorDot(colorName: record.vehicleColor),
                              const SizedBox(width: 6),
                              Text(
                                record.vehicleColor,
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
                const SizedBox(height: 12),
                LicensePlateWidget(plateNumber: record.vehiclePlate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final textColor = valueColor ?? t.colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 5),
              ],
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bottom action buttons ──────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final String phone;
  const _BottomActions({required this.phone});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding:
          EdgeInsets.fromLTRB(20, 12, 20, bottomPad > 0 ? bottomPad : 20),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        border: Border(top: BorderSide(color: t.colorScheme.outline)),
      ),
      child: Row(
        children: [
          // Call — outlined, uses primary as text/icon colour
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: t.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.colorScheme.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_outlined,
                        color: t.colorScheme.onSurface, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Call',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Message — filled primary button (#030213 light / #fafafa dark)
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: t.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        color: t.colorScheme.onPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Message',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
