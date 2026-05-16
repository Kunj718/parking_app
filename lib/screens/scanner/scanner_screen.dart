import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/scanner_overlay_painter.dart';
import '../../widgets/license_plate_widget.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnim;
  bool _isScanned = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanAnim =
        CurvedAnimation(parent: _scanController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _simulateScan() async {
    if (_isScanning || _isScanned) return;
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isScanned = true;
      _isScanning = false;
    });
    _scanController.stop();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _showResultSheet();
  }

  void _resetScan() {
    if (!mounted) return;
    setState(() => _isScanned = false);
    _scanController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _SimulatedCamera(),
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) => CustomPaint(
              painter: ScannerOverlayPainter(
                animValue: _scanAnim.value,
                isScanned: _isScanned,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: _TopBar(),
          ),
          if (!_isScanned)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 40 + 145,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Point camera at a ParkQR code',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomPanel(
              isScanned: _isScanned,
              isScanning: _isScanning,
              onSimulate: _simulateScan,
              onReset: _resetScan,
            ),
          ),
        ],
      ),
    );
  }

  void _showResultSheet() {
    // Simulate reading the currently logged-in user's QR data
    final currentUser = AppState.instance.currentUser;
    ScannedProfile? scanned;

    if (currentUser != null) {
      scanned = UserProfile.parseQr(currentUser.qrData);
    }

    // Fallback demo profile if no real user exists
    scanned ??= const ScannedProfile(
      name: 'Arjun Mehta',
      homeNumber: 'A-704',
      tower: 'Tower A',
      phone: '+91 98765 43210',
      tenamentNo: 'T-1234',
      plateNumber: 'MH 02 AB 1234',
      vehicleModel: 'Honda City',
      vehicleColor: 'Pearl White',
      vehicleType: 'car',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => _ScanResultSheet(
        profile: scanned!,
        onClose: () {
          Navigator.of(context).pop();
          _resetScan();
        },
      ),
    ).whenComplete(_resetScan);
  }
}

// ─── Simulated Camera ─────────────────────────────────────────────────────────

class _SimulatedCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.4,
          colors: [const Color(0xFF1A2040), const Color(0xFF050810)],
        ),
      ),
      child: Opacity(
        opacity: 0.06,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 20,
            childAspectRatio: 1,
          ),
          itemCount: 400,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _GlassButton(icon: Icons.close_rounded, onTap: () {}),
          const Spacer(),
          Text(
            'QR Scanner',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _GlassButton(icon: Icons.flash_off_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Bottom Panel ─────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final bool isScanned;
  final bool isScanning;
  final VoidCallback onSimulate;
  final VoidCallback onReset;

  const _BottomPanel({
    required this.isScanned,
    required this.isScanning,
    required this.onSimulate,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isScanned ? onReset : onSimulate,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isScanned
                      ? AppColors.emeraldGradient
                      : AppColors.blueGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isScanned
                            ? AppColors.emerald
                            : AppColors.electricBlue)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: isScanning
                  ? const Padding(
                      padding: EdgeInsets.all(22),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isScanned
                          ? Icons.refresh_rounded
                          : Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isScanned
                ? 'Tap to scan again'
                : isScanning
                    ? 'Reading QR code...'
                    : 'Tap to simulate scan',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

// ─── Scan Result Sheet ────────────────────────────────────────────────────────

class _ScanResultSheet extends StatelessWidget {
  final ScannedProfile profile;
  final VoidCallback onClose;

  const _ScanResultSheet({required this.profile, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Verified badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: AppColors.emeraldGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.verified_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            'Resident Verified',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          Text(
            'Registered society member',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Profile details card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.cardElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                // Owner section header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: AppColors.blueGradient),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                        Text(
                          '${profile.tower} · ${profile.homeNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: c.border, height: 1),
                const SizedBox(height: 16),
                // Contact
                _InfoRow(
                  icon: Icons.phone_android_rounded,
                  label: 'Mobile',
                  value: profile.phone,
                  valueColor: c.textPrimary,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.apartment_rounded,
                  label: 'Address',
                  value: '${profile.tower}, ${profile.homeNumber}',
                  valueColor: c.textPrimary,
                ),
                if (profile.hasTenament) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.tag_rounded,
                    label: 'Tenament No.',
                    value: profile.tenamentNo!,
                    valueColor: AppColors.electricBlueLight,
                  ),
                ],
                if (profile.hasVehicle) ...[
                  const SizedBox(height: 16),
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        profile.vehicleType == 'bike'
                            ? Icons.two_wheeler_rounded
                            : Icons.directions_car_rounded,
                        color: AppColors.electricBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Registered Vehicle',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.vehicleModel,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                            Text(
                              profile.vehicleColor,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      LicensePlateWidget(plateNumber: profile.plateNumber),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.no_transfer_rounded,
                          color: c.textHint, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'No vehicle registered',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: c.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: c.cardElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border),
                    ),
                    child: Center(
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: AppColors.blueGradient),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Allow Entry',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 15, color: c.textHint),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 13, color: c.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
