import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import 'profile_setup_screen.dart';
import 'admin_profile_setup_screen.dart';
import '../../navigation/main_navigation.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;

  const OtpScreen({super.key, required this.phone, required this.role});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const _otpLength = 6;
  static const _validOtp = '123456';

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  int _resendSeconds = 60;
  Timer? _resendTimer;
  bool _isVerifying = false;
  bool _isSuccess = false;
  String? _errorMsg;

  late AnimationController _successController;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (_errorMsg != null) setState(() => _errorMsg = null);

    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all 6 digits are entered
    if (_currentOtp.length == _otpLength) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
      _errorMsg = null;
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // UI demo — always succeed regardless of what was entered
    setState(() => _isSuccess = true);
    _successController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    AppState.instance.selectedRole = widget.role;

    if (AppState.instance.currentUser != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainNavigation(role: AppState.instance.selectedRole),
        ),
        (_) => false,
      );
    } else if (widget.role == 'admin') {
      // Admin skips the 3-step resident flow — goes straight to name-only screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AdminProfileSetupScreen(phone: widget.phone),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(
            phone: widget.phone,
            role: widget.role,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final minHeight = mq.size.height - mq.padding.top - mq.padding.bottom;

    return Scaffold(
      backgroundColor: context.colors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _BackButton(),
                  const SizedBox(height: 40),
                  _headerSection(),
                  const SizedBox(height: 40),
                  _otpBoxes(),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 16),
                    _ErrorBanner(message: _errorMsg!),
                  ],
                  const SizedBox(height: 24),
                  _resendRow(),
                  const Spacer(),
                  _VerifyButton(
                    isVerifying: _isVerifying,
                    isSuccess: _isSuccess,
                    successScale: _successScale,
                    onTap: _verifyOtp,
                  ),
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
            color: AppColors.emerald.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
          ),
          child: const Icon(Icons.sms_rounded,
              color: AppColors.emerald, size: 28),
        ),
        const SizedBox(height: 24),
        Text(
          'Verify your\nnumber',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
                fontSize: 15, color: c.textSecondary, height: 1.5),
            children: [
              const TextSpan(text: 'We sent a 6-digit OTP to '),
              TextSpan(
                text: widget.phone,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _otpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) {
        return _OtpBox(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          isSuccess: _isSuccess,
          isError: _errorMsg != null,
          onChanged: (v) => _onDigitChanged(i, v),
        );
      }),
    );
  }

  Widget _resendRow() {
    final c = context.colors;
    return Center(
      child: _resendSeconds > 0
          ? RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                    fontSize: 14, color: c.textSecondary),
                children: [
                  const TextSpan(text: 'Resend OTP in '),
                  TextSpan(
                    text: '${_resendSeconds}s',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.electricBlue,
                    ),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTap: _startResendTimer,
              child: Text(
                'Resend OTP',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricBlue,
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP Box — StatefulWidget so it can reactively update the border when focus
// changes WITHOUT rebuilding (and therefore resetting) the TextField.
// The old ListenableBuilder approach rebuilt the TextField on every focus
// change, destroying the input connection and making typed digits vanish.
// ─────────────────────────────────────────────────────────────────────────────
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSuccess;
  final bool isError;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isSuccess,
    required this.isError,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    // Rebuild only the border decoration when focus changes — the TextField
    // itself is never destroyed, so the input connection stays intact.
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isFocused = widget.focusNode.hasFocus;

    final borderColor = widget.isSuccess
        ? AppColors.emerald
        : widget.isError
            ? AppColors.danger
            : isFocused
                ? AppColors.electricBlue
                : c.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Stack keeps the hint centered independently of TextField metrics.
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "0" hint — visible only when the box is empty
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (_, value, __) {
              if (value.text.isNotEmpty) return const SizedBox.shrink();
              return Text(
                '0',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: c.textHint,
                ),
              );
            },
          ),
          // TextField — transparent bg, no built-in hint
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: AppColors.electricBlue,
            cursorWidth: 2,
            contextMenuBuilder: (_, __) => const SizedBox.shrink(),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: widget.isSuccess ? AppColors.emerald : c.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isCollapsed: true,
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final bool isVerifying;
  final bool isSuccess;
  final Animation<double> successScale;
  final VoidCallback onTap;

  const _VerifyButton({
    required this.isVerifying,
    required this.isSuccess,
    required this.successScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSuccess) {
      return ScaleTransition(
        scale: successScale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.emeraldGradient),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'Verified!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isVerifying ? null : onTap,
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
          child: isVerifying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  'Verify OTP',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
