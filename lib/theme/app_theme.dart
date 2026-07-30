import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color surfaceWarm;
  final Color fg;
  final Color fg2;
  final Color muted;
  final Color accent;
  final Color accentOn;
  final Color border;
  final Color borderSoft;
  final Color success;
  final Color warn;
  final Color danger;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceWarm,
    required this.fg,
    required this.fg2,
    required this.muted,
    required this.accent,
    required this.accentOn,
    required this.border,
    required this.borderSoft,
    required this.success,
    required this.warn,
    required this.danger,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceWarm,
    Color? fg,
    Color? fg2,
    Color? muted,
    Color? accent,
    Color? accentOn,
    Color? border,
    Color? borderSoft,
    Color? success,
    Color? warn,
    Color? danger,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceWarm: surfaceWarm ?? this.surfaceWarm,
      fg: fg ?? this.fg,
      fg2: fg2 ?? this.fg2,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      accentOn: accentOn ?? this.accentOn,
      border: border ?? this.border,
      borderSoft: borderSoft ?? this.borderSoft,
      success: success ?? this.success,
      warn: warn ?? this.warn,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceWarm: Color.lerp(surfaceWarm, other.surfaceWarm, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      fg2: Color.lerp(fg2, other.fg2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentOn: Color.lerp(accentOn, other.accentOn, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }

  static const light = AppColors(
    bg: Color(0xFFF2FAF7),
    surface: Color(0xFFFFFFFF),
    surfaceWarm: Color(0xFFE6F7F0),
    fg: Color(0xFF111B17),
    fg2: Color(0xFF3A5249),
    muted: Color(0xFF6B8F80),
    accent: Color(0xFF10B981),
    accentOn: Color(0xFFFFFFFF),
    border: Color(0xFFC8E0D6),
    borderSoft: Color(0xFFE0F0EA),
    success: Color(0xFF10B981),
    warn: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
  );

  static const dark = AppColors(
    bg: Color(0xFF0C1210),
    surface: Color(0xFF141E1A),
    surfaceWarm: Color(0xFF1A2822),
    fg: Color(0xFFE8F5F0),
    fg2: Color(0xFFA8C4B8),
    muted: Color(0xFF6B8F80),
    accent: Color(0xFF34D399),
    accentOn: Color(0xFF0C1210),
    border: Color(0xFF1E332B),
    borderSoft: Color(0xFF1A2822),
    success: Color(0xFF34D399),
    warn: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.bg,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: AppColors.light.fg,
        displayColor: AppColors.light.fg,
      ),
      extensions: [AppColors.light],
      colorScheme: ColorScheme.light(
        primary: AppColors.light.accent,
        onPrimary: AppColors.light.accentOn,
        surface: AppColors.light.surface,
        onSurface: AppColors.light.fg,
        error: AppColors.light.danger,
        onError: Colors.white,
      ),
      iconTheme: IconThemeData(color: AppColors.light.fg2),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.bg,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppColors.dark.fg,
        displayColor: AppColors.dark.fg,
      ),
      extensions: [AppColors.dark],
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark.accent,
        onPrimary: AppColors.dark.accentOn,
        surface: AppColors.dark.surface,
        onSurface: AppColors.dark.fg,
        error: AppColors.dark.danger,
        onError: Colors.white,
      ),
      iconTheme: IconThemeData(color: AppColors.dark.fg2),
    );
  }
}
