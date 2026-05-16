import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
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
      bgColors: [Color(0xFFEEF3FF), Color(0xFFF5F8FF)],
      accentColor: AppColors.electricBlue,
      icon: Icons.local_parking_rounded,
    ),
    _SlideData(
      title: 'QR-Powered\nEntry System',
      subtitle:
          'Each resident gets a unique QR code. Guards scan to verify identity instantly.',
      bgColors: [Color(0xFFEBFAF7), Color(0xFFF3FBF9)],
      accentColor: AppColors.emerald,
      icon: Icons.qr_code_scanner_rounded,
    ),
    _SlideData(
      title: 'Real-Time\nGuest Tracking',
      subtitle:
          'Know who is parked, for how long, and whose guest they are — all live.',
      bgColors: [Color(0xFFF3EEFF), Color(0xFFF8F5FF)],
      accentColor: Color(0xFF7C4DFF),
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
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _slides.length,
            itemBuilder: (_, i) => _SlidePage(data: _slides[i]),
          ),
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: GestureDetector(
              onTap: _goToRoleSelection,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
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
    AppState.instance.hasSeenOnboarding = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;
  final List<Color> bgColors;
  final Color accentColor;
  final IconData icon;

  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.bgColors,
    required this.accentColor,
    required this.icon,
  });
}

class _SlidePage extends StatelessWidget {
  final _SlideData data;

  const _SlidePage({required this.data});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.bgColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _IllustrationCircle(color: data.accentColor, icon: data.icon),
              const Spacer(flex: 2),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: c.textSecondary,
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
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.08), width: 1),
          ),
        ),
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.14), width: 1.5),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.10),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 56),
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
    final c = context.colors;
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
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 6,
              activeDotColor: AppColors.electricBlue,
              dotColor: c.border,
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.blueGradient),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
