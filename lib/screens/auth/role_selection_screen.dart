import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'phone_auth_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _header(),
              const SizedBox(height: 28),
              _RoleCard(
                role: 'resident',
                title: 'Resident',
                subtitle:
                    'Manage your vehicle\'s QR code, add guests, and track parking status.',
                icon: Icons.home_rounded,
                accentColor: AppColors.electricBlue,
                features: const ['Personal QR Code', 'Guest Entry', 'My Vehicles'],
                isSelected: _selectedRole == 'resident',
                onTap: () => setState(() => _selectedRole = 'resident'),
              ),
              const SizedBox(height: 14),
              _RoleCard(
                role: 'admin',
                title: 'Admin / Guard',
                subtitle:
                    'Scan resident QR codes, oversee the live parking feed, and manage access.',
                icon: Icons.shield_rounded,
                accentColor: AppColors.emerald,
                features: const ['QR Scanner', 'Live Feed Control', 'Full Access'],
                isSelected: _selectedRole == 'admin',
                onTap: () => setState(() => _selectedRole = 'admin'),
              ),
              const Spacer(),
              _ContinueButton(enabled: _selectedRole != null, onTap: _proceed),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.blueGradient),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.local_parking_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(height: 24),
        Text(
          'Who are\nyou today?',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your role to continue.',
          style: GoogleFonts.inter(fontSize: 15, color: c.textSecondary),
        ),
      ],
    );
  }

  void _proceed() {
    if (_selectedRole == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhoneAuthScreen(role: _selectedRole!),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.05)
              : c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : c.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? accentColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? accentColor : c.border,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 12)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: c.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: features.map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _ContinueButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(colors: AppColors.blueGradient)
              : null,
          color: enabled ? null : c.cardElevated,
          borderRadius: BorderRadius.circular(16),
          border: enabled ? null : Border.all(color: c.border),
        ),
        child: Center(
          child: Text(
            enabled ? 'Continue →' : 'Select a role to continue',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.white : c.textHint,
            ),
          ),
        ),
      ),
    );
  }
}
