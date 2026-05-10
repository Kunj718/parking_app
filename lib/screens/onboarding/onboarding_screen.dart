import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import '../auth/role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<_SlideData> _slides = const [
    _SlideData(
      title: 'Smart Parking\nfor Your Society',
      subtitle:
          'Manage resident and guest vehicles with a tap. No more chaos at the gate.',
      gradientColors: [Color(0xFF1A237E), Color(0xFF0D2060)],
      accentColor: AppColors.electricBlue,
      icon: Icons.local_parking_rounded,
    ),
    _SlideData(
      title: 'QR-Powered\nEntry System',
      subtitle:
          'Each resident gets a unique QR code. Guards scan to verify identity instantly.',
      gradientColors: [Color(0xFF0A3D2E), Color(0xFF051A14)],
      accentColor: AppColors.emerald,
      icon: Icons.qr_code_scanner_rounded,
    ),
    _SlideData(
      title: 'Real-Time\nGuest Tracking',
      subtitle:
          'Know who is parked, for how long, and whose guest they are — all live.',
      gradientColors: [Color(0xFF2A1A4E), Color(0xFF140A2A)],
      accentColor: Color(0xFFAB47BC),
      icon: Icons.sensors_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _slides.length,
            itemBuilder: (_, i) => _SlidePage(data: _slides[i]),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              controller: _controller,
              currentPage: _currentPage,
              total: _slides.length,
              onFinish: _goToRoleSelection,
            ),
          ),
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: GestureDetector(
              onTap: _goToRoleSelection,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToRoleSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });
}

class _SlidePage extends StatelessWidget {
  final _SlideData data;

  const _SlidePage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Illustration area
              _IllustrationCircle(color: data.accentColor, icon: data.icon),
              const Spacer(flex: 2),
              // Text
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.65),
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustrationCircle extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _IllustrationCircle({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.1), width: 1),
          ),
        ),
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.18), width: 1.5),
          ),
        ),
        // Main circle
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 64),
        ),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final int total;
  final VoidCallback onFinish;

  const _BottomControls({
    required this.controller,
    required this.currentPage,
    required this.total,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == total - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        32,
        24,
        32,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmoothPageIndicator(
            controller: controller,
            count: total,
            effect: const ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 6,
              activeDotColor: AppColors.electricBlue,
              dotColor: AppColors.darkBorder,
            ),
          ),
          GestureDetector(
            onTap: isLast
                ? onFinish
                : () => controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.blueGradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
