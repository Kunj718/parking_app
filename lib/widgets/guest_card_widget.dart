import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/mock_data.dart';
import 'license_plate_widget.dart';

class GuestCardWidget extends StatefulWidget {
  final GuestEntry entry;
  final VoidCallback? onRevoke;

  const GuestCardWidget({super.key, required this.entry, this.onRevoke});

  @override
  State<GuestCardWidget> createState() => _GuestCardWidgetState();
}

class _GuestCardWidgetState extends State<GuestCardWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.entry.remaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _remaining = widget.entry.remaining);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final progress = entry.progressFraction;
    final isExpiring = _remaining.inMinutes < 30 && !entry.isExpired;
    final isExpired = entry.isExpired;

    final statusColor = isExpired
        ? AppColors.danger
        : isExpiring
            ? AppColors.warning
            : AppColors.emerald;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired
              ? AppColors.dangerDim
              : isExpiring
                  ? AppColors.warningDim
                  : AppColors.darkBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CarThumbnail(color: statusColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LicensePlateWidget(plateNumber: entry.plateNumber),
                      const SizedBox(height: 8),
                      Text(
                        '${entry.vehicleModel} · ${entry.vehicleColor}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.apartment_rounded,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Host: ${entry.hostName} · ${entry.hostFlatNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _TimerBadge(remaining: _remaining, isExpired: isExpired, color: statusColor),
              ],
            ),
          ),
          // Progress bar
          _TimerProgressBar(
            progress: progress,
            isExpired: isExpired,
            isExpiring: isExpiring,
            allowedHours: entry.allowedHours,
          ),
        ],
      ),
    );
  }
}

class _CarThumbnail extends StatelessWidget {
  final Color color;

  const _CarThumbnail({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(Icons.directions_car_rounded, color: color, size: 26),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final Duration remaining;
  final bool isExpired;
  final Color color;

  const _TimerBadge({
    required this.remaining,
    required this.isExpired,
    required this.color,
  });

  String get _formatted {
    if (isExpired) return 'Expired';
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Icon(
            isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(height: 2),
          Text(
            _formatted,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerProgressBar extends StatelessWidget {
  final double progress;
  final bool isExpired;
  final bool isExpiring;
  final int allowedHours;

  const _TimerProgressBar({
    required this.progress,
    required this.isExpired,
    required this.isExpiring,
    required this.allowedHours,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = isExpired
        ? AppColors.danger
        : isExpiring
            ? AppColors.warning
            : AppColors.emerald;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entry time',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
              ),
              Text(
                '${allowedHours}h limit',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.02, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [barColor.withOpacity(0.7), barColor],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
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
