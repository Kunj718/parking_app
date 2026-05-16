import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
import '../screens/scanner/scanner_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final String role;

  const MainNavigation({super.key, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  bool get _isAdmin => widget.role == 'admin';

  late final List<_NavItem> _items = [
    _NavItem(
      icon: _isAdmin ? Icons.apartment_rounded : Icons.grid_view_rounded,
      label: _isAdmin ? 'Tenements' : 'Dashboard',
    ),
    _NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Admin → tenement grid dashboard  |  Resident → personal dashboard
          _isAdmin
              ? const AdminDashboardScreen()
              : DashboardScreen(role: widget.role),
          const ScannerScreen(),
          const SettingsScreen(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _BottomNavBar(
        items: _items,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPad > 0 ? bottomPad : 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final selected = i == currentIndex;

          // Scanner tab (index 1) gets the pill treatment
          if (i == 1) {
            return _ScannerTab(selected: selected, onTap: () => onTap(i));
          }

          return _NavTab(item: item, selected: selected, onTap: () => onTap(i));
        }).toList(),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab(
      {required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.electricBlue.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
                fontSize: 10,
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

class _ScannerTab extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _ScannerTab({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? AppColors.electricBlue : c.cardElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.electricBlue : c.border,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: selected ? Colors.white : c.textHint,
              size: 20,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Scanner',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.electricBlue : c.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
