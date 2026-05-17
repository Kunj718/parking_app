import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Always read from the live theme so the toggle never shows a stale value.
  // Theme.of(context).brightness flips the instant MaterialApp rebuilds.
  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;

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
    final isAdmin = resident.role == 'admin';

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
          SliverAppBar(
            backgroundColor: t.scaffoldBackgroundColor,
            floating: true,
            toolbarHeight: 64,
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: t.colorScheme.onSurface,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileCard(
                  resident: resident,
                  onEdit: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _EditProfileSheet(resident: resident),
                    );
                    // Refresh card after sheet closes
                    setState(() {});
                  },
                ),
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
                      // Single-line toggle — updates global ThemeMode instantly.
                      // ValueListenableBuilder in main.dart propagates the change
                      // to every Theme.of(context) call in the entire widget tree.
                      onChanged: (v) => AppState.instance.themeMode =
                          v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isAdmin)
                  // ── Admin Tools — replaces resident Account items ──────────
                  _SettingsGroup(
                    title: 'Admin Tools',
                    tiles: [
                      _NavTile(
                        icon: Icons.people_outline_rounded,
                        iconColor: AppColors.electricBlue,
                        title: 'Manage Residents',
                        subtitle: 'View and edit all registrations',
                      ),
                      _NavTile(
                        icon: Icons.bar_chart_rounded,
                        iconColor: AppColors.emerald,
                        title: 'Society Reports',
                        subtitle: 'Occupancy & activity overview',
                      ),
                      _NavTile(
                        icon: Icons.download_outlined,
                        iconColor: const Color(0xFF7C4DFF),
                        title: 'Export Data',
                        subtitle: 'Download tenement records',
                      ),
                    ],
                  )
                else
                  // ── Resident Account items ────────────────────────────────
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
                    ],
                  ),
                const SizedBox(height: 15),
                _LogoutButton(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile resident;
  final VoidCallback onEdit;

  const _ProfileCard({required this.resident, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.colorScheme.outline),
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
                  resident.name.isNotEmpty
                      ? resident.name[0].toUpperCase()
                      : '?',
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
                      color: t.colorScheme.onSurface,
                    ),
                  ),
                  // Admin: show phone; Resident: show tower · home
                  Text(
                    resident.role == 'admin'
                        ? resident.phone.isNotEmpty
                            ? resident.phone
                            : 'Society Admin'
                        : '${resident.tower} · ${resident.homeNumber}',
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: AppColors.electricBlue, size: 16),
            ),
          ],
        ),
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
    final t = Theme.of(context);
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
            color: t.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.colorScheme.outline),
          ),
          child: Column(
            children: tiles,
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
    final t = Theme.of(context);
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
                        color: t.colorScheme.onSurface)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          // No explicit color properties — they come from the global
          // AppTheme.switchTheme defined in app_theme.dart.
          Switch(
            value: value,
            onChanged: onChanged,
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
    final t = Theme.of(context);
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
                        color: t.colorScheme.onSurface)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: c.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textHint, size: 18),
        ],
      ),
    );
  }
}

// ── Edit Profile Bottom Sheet ─────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final UserProfile resident;
  const _EditProfileSheet({required this.resident});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _homeCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.resident.name);
    _homeCtrl = TextEditingController(
      text: widget.resident.homeNumber == '-'
          ? ''
          : widget.resident.homeNumber,
    );
    _phoneCtrl = TextEditingController(text: widget.resident.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _homeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final updated = AppState.instance.currentUser!.copyWith(
      name: _nameCtrl.text.trim().isEmpty
          ? widget.resident.name
          : _nameCtrl.text.trim(),
      homeNumber: _homeCtrl.text.trim().isEmpty
          ? widget.resident.homeNumber
          : _homeCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty
          ? widget.resident.phone
          : _phoneCtrl.text.trim(),
    );

    // Brief delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    AppState.instance.currentUser = updated;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final isAdmin = widget.resident.role == 'admin';
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: t.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Title row ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: AppColors.electricBlue, size: 17),
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: t.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Full Name ────────────────────────────────────────────────────
          _SheetLabel(label: 'Full Name'),
          const SizedBox(height: 8),
          _SheetField(
            controller: _nameCtrl,
            hint: 'e.g. Arjun Mehta',
            icon: Icons.person_outline_rounded,
            capitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 16),

          // ── Home Number (residents only) ─────────────────────────────────
          if (!isAdmin) ...[
            _SheetLabel(label: 'Home / Flat Number'),
            const SizedBox(height: 8),
            _SheetField(
              controller: _homeCtrl,
              hint: 'e.g. 704, A-12',
              icon: Icons.home_outlined,
              capitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
          ],

          // ── Mobile Number ────────────────────────────────────────────────
          _SheetLabel(label: 'Mobile Number'),
          const SizedBox(height: 8),
          _SheetField(
            controller: _phoneCtrl,
            hint: '+91 98765 43210',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(
              RegExp(r'[0-9 +\-]'),
            )],
          ),

          const SizedBox(height: 28),

          // ── Save button ──────────────────────────────────────────────────
          GestureDetector(
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String label;
  const _SheetLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextCapitalization capitalization;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.capitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      textCapitalization: capitalization,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: c.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: c.textSecondary, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
