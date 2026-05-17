import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'phone_auth_screen.dart';
import 'admin_login_screen.dart';

// ── Brand constants used inside the always-white role cards ───────────────────
// Cards are white in both light and dark modes (React design intent), so
// the card-internal colours are always the same dark-navy values.
const _cardNavy = Color(0xFF0A1628);          // icon circle bg + card title
const _cardSubtitleColor = Color(0x990A1628); // title @ 60% opacity
const _cardChevronColor = Color(0x660A1628);  // chevron @ 40% opacity

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _navigate(BuildContext context, String role) {
    if (role == 'admin') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PhoneAuthScreen(role: role)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.colors;
    final isDark = t.brightness == Brightness.dark;

    return Scaffold(
      // Status bar blends into gradient (dark) or scaffold bg (light)
      backgroundColor: isDark ? const Color(0xFF0A1628) : t.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Dark  → deep navy gradient (from React)
        // Light → flat scaffold background colour
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A1628), Color(0xFF1A2942)],
                ),
              )
            : BoxDecoration(color: t.scaffoldBackgroundColor),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 56),

                    // ── Swap-arrows icon circle ──────────────────────────────
                    // Dark  → bg-white/10 (glass circle on dark bg)
                    // Light → card surface with border
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : c.card,
                        shape: BoxShape.circle,
                        border: isDark
                            ? null
                            : Border.all(color: c.border),
                      ),
                      child: Icon(
                        Icons.compare_arrows_rounded,
                        color: isDark ? Colors.white : t.colorScheme.onSurface,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── App title ────────────────────────────────────────────
                    Text(
                      'Society Parking',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        // Dark → white  |  Light → theme primary text
                        color: isDark ? Colors.white : t.colorScheme.onSurface,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Tagline ──────────────────────────────────────────────
                    Text(
                      'Secure. Simple. Smart.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        // Dark → white/70  |  Light → electricBlue (brand accent)
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.70)
                            : AppColors.electricBlue,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Section heading ──────────────────────────────────────
                    Text(
                      'Who are you?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : t.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Resident card ────────────────────────────────────────
                    _RoleCard(
                      icon: Icons.person_rounded,
                      title: 'I am a Resident',
                      subtitle: 'Register your vehicle',
                      isDark: isDark,
                      onTap: () => _navigate(context, 'resident'),
                    ),

                    const SizedBox(height: 16),

                    // ── Admin card ───────────────────────────────────────────
                    _RoleCard(
                      icon: Icons.shield_rounded,
                      title: 'I am a Society Admin',
                      subtitle: 'Manage tenements',
                      isDark: isDark,
                      onTap: () => _navigate(context, 'admin'),
                    ),

                    const Spacer(),

                    const SizedBox(height: 32),

                    // ── Version footer ────────────────────────────────────────
                    Text(
                      'v1.0.0 • Secure Parking Management',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        // Dark → white/50  |  Light → textHint
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.50)
                            : context.colors.textHint,
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role card ──────────────────────────────────────────────────────────────────
// The card itself is ALWAYS white with dark-navy internals — this is the
// intentional React design. What changes per mode is the shadow vs border.

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // Card bg is always white in both modes — high contrast on dark
            // gradient and clean separation on light scaffold.
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: widget.isDark
                ? null
                // Light mode: subtle border instead of heavy shadow
                : Border.all(color: const Color(0xFFE3E9F5)),
            boxShadow: widget.isDark
                // Dark mode: deep shadow lifts card off the gradient
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 24,
                      spreadRadius: -4,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 8,
                      spreadRadius: -4,
                      offset: const Offset(0, 4),
                    ),
                  ]
                // Light mode: softer shadow for depth on light bg
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      spreadRadius: -2,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Dark navy icon circle — unchanged in both modes
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: _cardNavy,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: Colors.white, size: 24),
              ),

              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: _cardNavy,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: _cardSubtitleColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
                color: _cardChevronColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
