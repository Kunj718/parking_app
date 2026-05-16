import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Brand palette ──────────────────────────────────────────────────────────
  static const deepNavy = Color(0xFF1A237E);
  static const navyMid = Color(0xFF283593);
  static const navyLight = Color(0xFF3949AB);

  // ── Accent ─────────────────────────────────────────────────────────────────
  static const electricBlue = Color(0xFF2979FF);
  static const electricBlueLight = Color(0xFF82B1FF);
  static const electricBlueDark = Color(0xFF0D47A1);
  static const emerald = Color(0xFF00BFA5);
  static const emeraldDark = Color(0xFF00897B);

  // ── Light mode surfaces ────────────────────────────────────────────────────
  static const lightBg = Color(0xFFF5F7FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardElevated = Color(0xFFF0F4FF);
  static const lightBorder = Color(0xFFE3E9F5);
  static const lightDivider = Color(0xFFF0F4FB);

  // ── Dark mode surfaces — premium midnight blue slate (#0F172A base) ────────
  static const darkBg = Color(0xFF0F172A);           // slate-900 (primary bg)
  static const darkSurface = Color(0xFF1E293B);       // slate-800
  static const darkCard = Color(0xFF1E293B);          // slate-800 (card surface)
  static const darkCardElevated = Color(0xFF273449);  // slate-750 (elevated chips)
  static const darkBorder = Color(0xFF334155);        // slate-700
  static const darkDivider = Color(0xFF1A2535);       // between 800–900

  // ── Text — light mode ──────────────────────────────────────────────────────
  static const textLight = Color(0xFF1A2340);   // primary on white
  static const textDim = Color(0xFF556080);      // secondary on white
  static const textFaint = Color(0xFF8A9BC4);    // hint / muted on white

  // ── Text — dark mode ──────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFEEF2FF);      // near-white
  static const textSecondary = Color(0xFF94A3B8);    // slate-400
  static const textMuted = Color(0xFF475569);        // slate-600 (hint)
  static const textOnDark = Color(0xFF1A2340);       // alias for label helpers

  // Legacy alias kept for backwards compat
  static const textLightAlias = Color(0xFF1A2340);

  // ── Status ────────────────────────────────────────────────────────────────
  static const success = Color(0xFF00E5A0);
  static const successDim = Color(0xFFE8FAF7);   // light-mode tint
  static const warning = Color(0xFFFFCC00);
  static const warningDim = Color(0xFFFFF8E0);
  static const danger = Color(0xFFFF4060);
  static const dangerDim = Color(0xFFFFECEE);    // light-mode tint

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const List<Color> navyGradient = [Color(0xFF1A237E), Color(0xFF0D47A1)];
  static const List<Color> blueGradient = [Color(0xFF2979FF), Color(0xFF00BCD4)];
  static const List<Color> cardGradient = [Color(0xFF1E293B), Color(0xFF0F172A)];
  static const List<Color> emeraldGradient = [Color(0xFF00BFA5), Color(0xFF0097A7)];
}

// ─── Theme extension — custom slots with no standard Theme equivalent ─────────

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.bg,
    required this.card,
    required this.cardElevated,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.successDim,
    required this.dangerDim,
  });

  final Color bg;
  final Color card;
  final Color cardElevated;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color successDim;
  final Color dangerDim;

  // Quick accessor — use context.colors anywhere in build()
  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).extension<AppColorScheme>()!;

  static const light = AppColorScheme(
    bg: AppColors.lightBg,
    card: AppColors.lightCard,
    cardElevated: AppColors.lightCardElevated,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    textPrimary: AppColors.textLight,
    textSecondary: AppColors.textDim,
    textHint: AppColors.textFaint,
    successDim: Color(0xFFE8FAF7),
    dangerDim: Color(0xFFFFECEE),
  );

  static const dark = AppColorScheme(
    bg: AppColors.darkBg,
    card: AppColors.darkCard,
    cardElevated: AppColors.darkCardElevated,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textHint: AppColors.textMuted,
    successDim: Color(0xFF0A2520),
    dangerDim: Color(0xFF2A0A10),
  );

  @override
  AppColorScheme copyWith({
    Color? bg,
    Color? card,
    Color? cardElevated,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? successDim,
    Color? dangerDim,
  }) =>
      AppColorScheme(
        bg: bg ?? this.bg,
        card: card ?? this.card,
        cardElevated: cardElevated ?? this.cardElevated,
        border: border ?? this.border,
        divider: divider ?? this.divider,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textHint: textHint ?? this.textHint,
        successDim: successDim ?? this.successDim,
        dangerDim: dangerDim ?? this.dangerDim,
      );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      successDim: Color.lerp(successDim, other.successDim, t)!,
      dangerDim: Color.lerp(dangerDim, other.dangerDim, t)!,
    );
  }
}

// Shorthand: context.colors.cardElevated instead of AppColorScheme.of(context).cardElevated
extension AppColorSchemeX on BuildContext {
  AppColorScheme get colors => AppColorScheme.of(this);
}

// ─── Theme factory ─────────────────────────────────────────────────────────────

class AppTheme {
  // ── Light theme — clean white ──────────────────────────────────────────────
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.electricBlue,

      // ColorScheme drives Theme.of(context).colorScheme.* reads
      colorScheme: const ColorScheme.light(
        primary: AppColors.electricBlue,
        primaryContainer: AppColors.lightCardElevated,
        secondary: AppColors.emerald,
        secondaryContainer: AppColors.lightCardElevated,
        surface: AppColors.lightCard,         // → Theme.of(ctx).colorScheme.surface
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textLight,       // → primary text colour
        onSurfaceVariant: AppColors.textDim,  // → secondary text colour
        outline: AppColors.lightBorder,       // → border colour
        outlineVariant: AppColors.lightDivider,
        error: AppColors.danger,
        onError: Colors.white,
      ),

      // Global AppBar — light icons on white bg
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),

      // Global Card — white surface, no elevation shadow, subtle border
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Global Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 0,
      ),

      // Global InputDecoration — used by TextFields across all screens
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCardElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.electricBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _inter(14, FontWeight.w400, AppColors.textFaint),
        labelStyle: _inter(14, FontWeight.w400, AppColors.textDim),
      ),

      // Global Switch — no per-widget color overrides needed
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.textFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.electricBlue
              : AppColors.lightBorder,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Global Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCardElevated,
        selectedColor: AppColors.electricBlue,
        labelStyle: _poppins(13, FontWeight.w500, AppColors.textLight),
        side: const BorderSide(color: AppColors.lightBorder),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Global ListTile
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.textDim,
        textColor: AppColors.textLight,
      ),

      // Global BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightCard,
        modalBackgroundColor: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Global NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        indicatorColor:
            AppColors.electricBlue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          _inter(11, FontWeight.w500, AppColors.textDim),
        ),
      ),

      // Global TextTheme — Poppins headings / Inter body
      textTheme: _buildTextTheme(AppColors.textLight, AppColors.textFaint),

      extensions: const [AppColorScheme.light],
    );
  }

  // ── Dark theme — premium midnight blue (#0F172A) ────────────────────────────
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.electricBlue,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricBlue,
        primaryContainer: AppColors.darkCardElevated,
        secondary: AppColors.emerald,
        secondaryContainer: AppColors.darkCardElevated,
        surface: AppColors.darkCard,            // → Theme.of(ctx).colorScheme.surface
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,       // → primary text
        onSurfaceVariant: AppColors.textSecondary, // → secondary text
        outline: AppColors.darkBorder,          // → border colour
        outlineVariant: AppColors.darkDivider,
        error: AppColors.danger,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
          borderSide:
              const BorderSide(color: AppColors.electricBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _poppins(14, FontWeight.w400, AppColors.textMuted),
        labelStyle: _inter(14, FontWeight.w400, AppColors.textSecondary),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.electricBlue
              : AppColors.darkCardElevated,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCardElevated,
        selectedColor: AppColors.electricBlue,
        labelStyle: _poppins(13, FontWeight.w500, AppColors.textPrimary),
        side: const BorderSide(color: AppColors.darkBorder),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        modalBackgroundColor: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        indicatorColor:
            AppColors.electricBlue.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.all(
          _inter(11, FontWeight.w500, AppColors.textSecondary),
        ),
      ),

      textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textMuted),

      extensions: const [AppColorScheme.dark],
    );
  }

  // ── TextTheme — Poppins headings, Inter body ───────────────────────────────
  // [faint] is used for hint-level styles (bodySmall, labelSmall)
  static TextTheme _buildTextTheme(Color base, Color faint) {
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
      bodySmall: _inter(12, FontWeight.w400, faint),
      labelLarge: _poppins(14, FontWeight.w600, base),
      labelMedium: _poppins(12, FontWeight.w600, base),
      labelSmall: _poppins(11, FontWeight.w500, faint),
    );
  }

  static TextStyle _poppins(double size, FontWeight w, Color c) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: w, color: c);

  static TextStyle _inter(double size, FontWeight w, Color c) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: c);
}
