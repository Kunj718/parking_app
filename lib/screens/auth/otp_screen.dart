import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import 'profile_setup_screen.dart';
import '../../../navigation/main_navigation.dart';

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
  static const _validOtp = '123456'; // mock OTP

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
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

  String get _currentOtp =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _errorMsg = null);
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_currentOtp.length == _otpLength) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;
    final otp = _currentOtp;
    if (otp.length != _otpLength) return;

    setState(() {
      _isVerifying = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    if (otp == _validOtp) {
      setState(() => _isSuccess = true);
      _successController.forward();
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      AppState.instance.selectedRole = widget.role;

      // If user already has a profile (returning user), go to app
      if (AppState.instance.currentUser != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                MainNavigation(role: AppState.instance.selectedRole),
          ),
          (_) => false,
        );
      } else {
        // New user → profile setup
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProfileSetupScreen(
              phone: widget.phone,
              role: widget.role,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isVerifying = false;
        _errorMsg = 'Incorrect OTP. Try again or use 123456 for demo.';
        for (final c in _controllers) c.clear();
      });
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _BackButton(),
              const SizedBox(height: 40),
              _headerSection(),
              const SizedBox(height: 48),
              _otpBoxes(),
              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: _errorMsg!),
              ],
              const SizedBox(height: 32),
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
    );
  }

  Widget _headerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.emerald.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.emerald.withOpacity(0.3)),
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
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
                fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            children: [
              const TextSpan(text: 'We sent a 6-digit OTP to '),
              TextSpan(
                text: widget.phone,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
    return Center(
      child: _resendSeconds > 0
          ? RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary),
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

class _OtpBox extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final borderColor = isSuccess
        ? AppColors.emerald
        : isError
            ? AppColors.danger
            : AppColors.darkBorder;
    final bgColor = isSuccess
        ? AppColors.successDim
        : isError
            ? AppColors.dangerDim
            : AppColors.darkCard;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppColors.electricBlue
              : borderColor,
          width: focusNode.hasFocus ? 1.5 : 1,
        ),
      ),
      child: ListenableBuilder(
        listenable: focusNode,
        builder: (_, __) => TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isSuccess ? AppColors.emerald : Colors.white,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

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
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.danger,
              ),
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
            gradient:
                const LinearGradient(colors: AppColors.emeraldGradient),
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
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}
