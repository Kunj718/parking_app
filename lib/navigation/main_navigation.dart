import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
import '../screens/scanner/scanner_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/qr_card_widget.dart';

// ── Nav item descriptor ────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── Resident tabs (5)  ·  Scanner sits at index 2 (center) ───────────────────
const _residentItems = [
  _NavItem(icon: Icons.grid_view_rounded,       label: 'Home'),
  _NavItem(icon: Icons.directions_car_outlined,  label: 'Vehicle'),
  _NavItem(icon: Icons.qr_code_scanner_rounded,  label: 'Scanner'), // circle
  _NavItem(icon: Icons.qr_code_rounded,          label: 'My QR'),
  _NavItem(icon: Icons.settings_outlined,        label: 'Account'),
];

// ── Admin tabs (3)  ·  Scanner sits at index 1 (center) ──────────────────────
const _adminItems = [
  _NavItem(icon: Icons.apartment_rounded,       label: 'Tenements'),
  _NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner'), // circle
  _NavItem(icon: Icons.settings_outlined,       label: 'Settings'),
];

// ── Main shell ─────────────────────────────────────────────────────────────────

class MainNavigation extends StatefulWidget {
  final String role;
  const MainNavigation({super.key, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  bool get _isAdmin => widget.role == 'admin';
  int  get _scannerIndex => _isAdmin ? 1 : 2;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _isAdmin
            ? [
                const AdminDashboardScreen(),
                const ScannerScreen(),
                const SettingsScreen(),
              ]
            : [
                DashboardScreen(role: widget.role), // 0 – Home
                const _MyVehiclesScreen(),           // 1 – Vehicle
                const ScannerScreen(),               // 2 – Scanner
                const _MyQrScreen(),                 // 3 – My QR
                const SettingsScreen(),              // 4 – Account
              ],
      ),
      bottomNavigationBar: _BottomNavBar(
        items: _isAdmin ? _adminItems : _residentItems,
        currentIndex: _currentIndex,
        scannerIndex: _scannerIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Bottom nav bar ─────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final int scannerIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.scannerIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPad > 0 ? bottomPad : 12),
      // Reduced vertical padding → shorter bar
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final i      = e.key;
          final item   = e.value;
          final sel    = i == currentIndex;

          if (i == scannerIndex) {
            return _ScannerTab(selected: sel, onTap: () => onTap(i));
          }
          return _NavTab(item: item, selected: sel, onTap: () => onTap(i));
        }).toList(),
      ),
    );
  }
}

// ── Regular tab ────────────────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.electricBlue.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: selected ? AppColors.electricBlue : c.textHint,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.electricBlue : c.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scanner tab — solid circle, always dark ────────────────────────────────────

class _ScannerTab extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _ScannerTab({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Circle is always deep navy when idle, electric-blue when active.
    final bgColor = selected ? AppColors.electricBlue : const Color(0xFF0A1628);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ── Resident: My Vehicles screen ───────────────────────────────────────────────

class _MyVehiclesScreen extends StatelessWidget {
  const _MyVehiclesScreen();

  @override
  Widget build(BuildContext context) {
    final t        = Theme.of(context);
    final c        = context.colors;
    final vehicles = AppState.instance.currentUser?.vehicles ?? [];

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Vehicles',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: t.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${vehicles.length} registered',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car_outlined,
                              color: c.textHint, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No vehicles linked',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add a vehicle in Account settings.',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: c.textHint),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _VehicleTile(
                        vehicle: vehicles[i],
                        isPrimary: i == 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final VehicleProfile vehicle;
  final bool isPrimary;

  const _VehicleTile({required this.vehicle, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    final t      = Theme.of(context);
    final c      = context.colors;
    final isBike = vehicle.type == 'bike';

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
            isBike
                ? Icons.two_wheeler_rounded
                : Icons.directions_car_outlined,
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
          if (isPrimary) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
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
          ],
          Icon(Icons.chevron_right_rounded, color: c.textHint, size: 18),
        ],
      ),
    );
  }
}

// ── Resident: My QR Code screen ────────────────────────────────────────────────

class _MyQrScreen extends StatelessWidget {
  const _MyQrScreen();

  @override
  Widget build(BuildContext context) {
    final t       = Theme.of(context);
    final c       = context.colors;
    final profile = AppState.instance.currentUser;

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My QR Code',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: t.colorScheme.onSurface,
                      ),
                    ),
                    // Text(
                    //   'Show this at the gate to verify your entry.',
                    //   style: GoogleFonts.inter(
                    //       fontSize: 13, color: c.textSecondary),
                    // ),
                  ],
                ),
              ),
            ),
            if (profile != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    QrCardWidget(profile: profile),
                    const SizedBox(height: 12),
                    QrCardActions(),
                  ]),
                ),
              )
            else
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No profile found.',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: c.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
