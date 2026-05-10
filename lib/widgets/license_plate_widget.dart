import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LicensePlateWidget extends StatelessWidget {
  final String plateNumber;
  final bool large;

  const LicensePlateWidget({
    super.key,
    required this.plateNumber,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = large ? 22 : 15;
    final double vPad = large ? 10 : 6;
    final double hPad = large ? 16 : 12;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF176), // Indian license plate yellow
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        border: Border.all(
          color: const Color(0xFF212121),
          width: large ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left blue strip (IND)
          Container(
            width: large ? 20 : 14,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
            ),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'IND',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: large ? 7 : 5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            plateNumber,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212121),
              letterSpacing: large ? 3 : 2,
            ),
          ),
        ],
      ),
    );
  }
}
