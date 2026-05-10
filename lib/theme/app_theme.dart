import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const deepNavy = Color(0xFF1A237E);
  static const navyMid = Color(0xFF283593);
  static const navyLight = Color(0xFF3949AB);

  // Accent
  static const electricBlue = Color(0xFF2979FF);
  static const electricBlueLight = Color(0xFF82B1FF);
  static const electricBlueDark = Color(0xFF0D47A1);
  static const emerald = Color(0xFF00BFA5);
  static const emeraldDark = Color(0xFF00897B);

  // Dark mode surfaces
  static const darkBg = Color(0xFF070B18);
  static const darkSurface = Color(0xFF0F1629);
  static const darkCard = Color(0xFF182038);
  static const darkCardElevated = Color(0xFF1E2A47);
  static const darkBorder = Color(0xFF2A3A5C);
  static const darkDivider = Color(0xFF1A2540);

  // Light mode surfaces
  static const lightBg = Color(0xFFF0F4FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFDDE3F5);

  // Text
  static const textPrimary = Color(0xFFEEF2FF);
  static const textSecondary = Color(0xFF8A9BC4);
  static const textMuted = Color(0xFF4A5880);
  static const textLight = Color(0xFF1A2340);

  // Status
  static const success = Color(0xFF00E5A0);
  static const successDim = Color(0xFF003D2E);
  static const warning = Color(0xFFFFCC00);
  static const warningDim = Color(0xFF3D3000);
  static const danger = Color(0xFFFF4060);
  static const dangerDim = Color(0xFF3D0010);

  // Gradients
  static const List<Color> navyGradient = [Color(0xFF1A237E), Color(0xFF0D47A1)];
  static const List<Color> blueGradient = [Color(0xFF2979FF), Color(0xFF00BCD4)];
  static const List<Color> cardGradient = [Color(0xFF1E2A47), Color(0xFF0F1629)];
  static const List<Color> emeraldGradient = [Color(0xFF00BFA5), Color(0xFF0097A7)];
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.deepNavy,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricBlue,
        primaryContainer: AppColors.electricBlueDark,
        secondary: AppColors.emerald,
        secondaryContainer: AppColors.emeraldDark,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        outline: AppColors.darkBorder,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.electricBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _poppins(14, FontWeight.w400, AppColors.textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCardElevated,
        selectedColor: AppColors.electricBlue,
        labelStyle: _poppins(13, FontWeight.w500, AppColors.textPrimary),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        modalBackgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      textTheme: _buildTextTheme(AppColors.textPrimary),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.deepNavy,
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepNavy,
        primaryContainer: AppColors.navyLight,
        secondary: AppColors.emerald,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSurface: AppColors.textLight,
        outline: AppColors.lightBorder,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: _buildTextTheme(AppColors.textLight),
    );
  }

  static TextTheme _buildTextTheme(Color base) {
    return TextTheme(
      displayLarge: _poppins(32, FontWeight.w700, base),
      displayMedium: _poppins(28, FontWeight.w700, base),
      displaySmall: _poppins(24, FontWeight.w700, base),
      headlineLarge: _poppins(22, FontWeight.w600, base),
      headlineMedium: _poppins(20, FontWeight.w600, base),
      headlineSmall: _poppins(18, FontWeight.w600, base),
      titleLarge: _poppins(17, FontWeight.w600, base),
      titleMedium: _poppins(15, FontWeight.w500, base),
      titleSmall: _poppins(13, FontWeight.w500, base),
      bodyLarge: _inter(16, FontWeight.w400, base),
      bodyMedium: _inter(14, FontWeight.w400, base),
      bodySmall: _inter(12, FontWeight.w400, AppColors.textSecondary),
      labelLarge: _poppins(14, FontWeight.w600, base),
      labelMedium: _poppins(12, FontWeight.w600, base),
      labelSmall: _poppins(11, FontWeight.w500, AppColors.textSecondary),
    );
  }

  static TextStyle _poppins(double size, FontWeight w, Color c) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: w, color: c);

  static TextStyle _inter(double size, FontWeight w, Color c) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: c);
}
