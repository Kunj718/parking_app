import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  final String role;

  const PhoneAuthScreen({super.key, required this.role});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Available height = screen height minus status bar, nav bar
    final minHeight = mq.size.height - mq.padding.top - mq.padding.bottom;

    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      // Scaffold shrinks body when keyboard appears; SingleChildScrollView
      // lets content scroll up instead of overflowing.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            // ConstrainedBox guarantees the column is at least full-screen tall
            // so Spacer() pushes the button to the bottom in normal state.
            constraints: BoxConstraints(minHeight: minHeight),
            child: IntrinsicHeight(
              // IntrinsicHeight makes the Column expand to fill the constrained
              // height, which is what Spacer needs to do its job.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _BackButton(),
                  const SizedBox(height: 40),
                  _headerSection(),
                  const SizedBox(height: 48),
                  _PhoneInputCard(
                    controller: _phoneController,
                    focusNode: _focusNode,
                    shakeAnim: _shakeAnim,
                    role: widget.role,
                  ),
                  const Spacer(),
                  _SendOtpButton(
                    isSending: _isSending,
                    onTap: _sendOtp,
                  ),
                  const SizedBox(height: 16),
                  _termsText(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerSection() {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.blueGradient),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.phone_android_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter your\nmobile number',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We\'ll send a one-time password to verify your identity.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: c.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _termsText() {
    final c = context.colors;
    return Center(
      child: Text(
        'By continuing, you agree to our Terms & Privacy Policy.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: c.textHint,
          height: 1.5,
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    // UI demo — no validation, any number (or blank) proceeds
    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSending = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: phone.isEmpty ? '+91 9800000000' : '+91 $phone',
          role: widget.role,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    final c = context.colors;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

class _PhoneInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Animation<double> shakeAnim;
  final String role;

  const _PhoneInputCard({
    required this.controller,
    required this.focusNode,
    required this.shakeAnim,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: shakeAnim,
      builder: (_, child) {
        final shake =
            (shakeAnim.value < 0.5 ? shakeAnim.value : 1.0 - shakeAnim.value) *
                12;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Country code — inline, no heavy box
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Row(
                children: [
                  Text('🇮🇳', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    '+91',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 1,
                    height: 22,
                    color: c.border,
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
            // Phone number input
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: '00000 00000',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: c.textHint,
                    letterSpacing: 2,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}

class _SendOtpButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onTap;

  const _SendOtpButton({required this.isSending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSending ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.blueGradient),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isSending
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Send OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
