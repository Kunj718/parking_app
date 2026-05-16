import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../models/mock_data.dart';
import 'tenement_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _filterIndex = 0; // 0=All  1=1-10  2=11-20  3=21-30

  static const _filters = ['All', '1-10', '11-20', '21-30'];

  List<TenementRecord> get _visible {
    switch (_filterIndex) {
      case 1:
        return MockData.tenements
            .where((r) => r.unitIndex >= 101 && r.unitIndex <= 110)
            .toList();
      case 2:
        return MockData.tenements
            .where((r) => r.unitIndex >= 111 && r.unitIndex <= 120)
            .toList();
      case 3:
        return MockData.tenements
            .where((r) => r.unitIndex >= 121 && r.unitIndex <= 130)
            .toList();
      default:
        return MockData.tenements;
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _visible;

    // AdminTheme injects the admin colour palette (shadcn CSS vars) for this
    // screen and all its descendants, while honouring the global ThemeMode.
    // The Builder gives us a fresh ctx whose Theme.of() returns the admin theme.
    return AdminTheme(
      child: Builder(
        builder: (ctx) {
          final t = Theme.of(ctx);
          final c = ctx.colors;
          final qrActive = records.where((r) => r.isQrActive).length;
          final appPending = records.where((r) => !r.isQrActive).length;

          return Scaffold(
            backgroundColor: t.scaffoldBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  // ── App Bar ───────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Dashboard',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: t.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Tenement Management',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Admin avatar
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: t.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: t.colorScheme.outline),
                            ),
                            child: Center(
                              child: Text(
                                _adminInitial,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: t.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: const SizedBox(height: 20)),

                  // ── Filter tabs ───────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _FilterTabs(
                        labels: _filters,
                        selected: _filterIndex,
                        onTap: (i) => setState(() => _filterIndex = i),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: const SizedBox(height: 16)),

                  // ── Stat cards ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'QR Active',
                              count: qrActive,
                              color: AppColors.emerald,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'App Pending',
                              count: appPending,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: const SizedBox(height: 16)),

                  // ── 2-column tenement grid ────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (gridCtx, i) => _TenementCard(
                          record: records[i],
                          onTap: () => Navigator.of(ctx).push(
                            MaterialPageRoute(
                              builder: (_) => TenementDetailScreen(
                                  record: records[i]),
                            ),
                          ),
                        ),
                        childCount: records.length,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: const SizedBox(height: 110)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String get _adminInitial {
    final name = AppState.instance.currentUser?.name ?? 'Admin';
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }
}

// ── Filter tab row ─────────────────────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onTap;

  const _FilterTabs({
    required this.labels,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return Row(
      children: labels.asMap().entries.map((e) {
        final i = e.key;
        final label = e.value;
        final isSelected = i == selected;
        return Padding(
          padding: EdgeInsets.only(right: i < labels.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Selected: primary (near-black light / near-white dark)
                // Unselected: transparent card surface
                color: isSelected
                    ? t.colorScheme.primary
                    : t.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? t.colorScheme.primary
                      : t.colorScheme.outline,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  // onPrimary flips between white (light) and dark bg (dark)
                  color: isSelected
                      ? t.colorScheme.onPrimary
                      : c.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Stat card (QR Active / App Pending) ───────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2-col tenement card ────────────────────────────────────────────────────────

class _TenementCard extends StatelessWidget {
  final TenementRecord record;
  final VoidCallback onTap;

  const _TenementCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final active = record.isQrActive;
    final accentColor = active ? AppColors.emerald : c.textHint;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? AppColors.emerald.withValues(alpha: 0.30)
                : t.colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.emerald.withValues(alpha: 0.12)
                    : c.cardElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_rounded,
                color: accentColor,
                size: 20,
              ),
            ),
            const Spacer(),
            // Unit number
            Text(
              record.unitNumber,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: t.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.emerald.withValues(alpha: 0.10)
                    : c.cardElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: active
                      ? AppColors.emerald.withValues(alpha: 0.28)
                      : t.colorScheme.outline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    active ? 'QR Active' : 'App Pending',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            // Tenant badge — shown only when the occupant is renting
            if (record.isTenant) ...[
              const SizedBox(height: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.key_rounded,
                      size: 9,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tenant',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
