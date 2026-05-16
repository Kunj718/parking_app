import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../auth/role_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _guestAlerts = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final resident = AppState.instance.currentUser ??
        const UserProfile(
          id: '',
          name: 'User',
          phone: '',
          homeNumber: '-',
          tower: '-',
          role: 'resident',
          vehicles: [],
        );

    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: c.bg,
            floating: true,
            toolbarHeight: 64,
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileCard(resident: resident),
                const SizedBox(height: 24),
                _SettingsGroup(
                  title: 'Notifications',
                  tiles: [
                    _ToggleTile(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.electricBlue,
                      title: 'Push Notifications',
                      subtitle: 'Alerts for entries and exits',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    _ToggleTile(
                      icon: Icons.person_add_outlined,
                      iconColor: AppColors.emerald,
                      title: 'Guest Alerts',
                      subtitle: 'Notify when guests arrive',
                      value: _guestAlerts,
                      onChanged: (v) => setState(() => _guestAlerts = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsGroup(
                  title: 'Appearance',
                  tiles: [
                    _ToggleTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: const Color(0xFF7C4DFF),
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme throughout',
                      value: _darkMode,
                      onChanged: (v) {
                        setState(() => _darkMode = v);
                        AppState.instance.themeMode =
                            v ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsGroup(
                  title: 'Account',
                  tiles: [
                    _NavTile(
                      icon: Icons.directions_car_outlined,
                      iconColor: AppColors.electricBlue,
                      title: 'My Vehicles',
                      subtitle: '${resident.vehicles.length} registered',
                    ),
                    _NavTile(
                      icon: Icons.qr_code_rounded,
                      iconColor: AppColors.emerald,
                      title: 'My QR Code',
                      subtitle: 'View or regenerate',
                    ),
                    _NavTile(
                      icon: Icons.history_rounded,
                      iconColor: const Color(0xFFFFCC00),
                      title: 'Entry History',
                      subtitle: 'Past 30 days',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsGroup(
                  title: 'Support',
                  tiles: [
                    _NavTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: c.textSecondary,
                      title: 'Help & FAQ',
                      subtitle: 'Common questions',
                    ),
                    _NavTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: c.textSecondary,
                      title: 'Privacy Policy',
                      subtitle: '',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _LogoutButton(),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Society Parking QR · v1.0.0',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: c.textHint),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile resident;

  const _ProfileCard({required this.resident});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.electricBlue.withValues(alpha: 0.18)),
            ),
            child: Center(
              child: Text(
                resident.name.substring(0, 1),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resident.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  '${resident.tower} · ${resident.homeNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  resident.role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: c.textHint,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: c.textHint, size: 18),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _SettingsGroup({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: c.textHint,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
          ),
          child: Column(
            children: tiles.asMap().entries.map((e) {
              final isLast = e.key == tiles.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: c.divider),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: c.textPrimary)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.electricBlue,
            inactiveThumbColor: c.textHint,
            inactiveTrackColor: c.cardElevated,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: c.textPrimary)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: c.textHint, size: 18),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Clear session state
        AppState.instance
          ..currentUser = null
          ..isLoggedIn = false
          ..selectedRole = '';

        // Remove every route and land on role selection
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (_) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded,
                  color: AppColors.danger, size: 18),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
