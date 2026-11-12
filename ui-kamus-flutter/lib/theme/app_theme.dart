import 'package:flutter/material.dart';

/// Palet terang: hijau tua, olive, dan krem.
const Color kamusGreen = Color(0xFF2C432D);
const Color kamusSecondary = Color(0xFF5B623C);
const Color kamusCream = Color(0xFFF8FBED);
const Color kamusPaleGreen = Color(0xFFE0E7B6);

/// Palet gelap yang sengaja dibuat "lembut":
/// - dasar memakai abu hangat, bukan hitam/putih murni, supaya mata tidak
///   silau saat layar menyala di waktu malam;
/// - aksen sage diredam (bukan hijau neon) supaya judul dan ikon tidak
///   menyilaukan;
/// - jarak antar permukaan dibuat kecil supaya tidak terlihat seperti
///   garis-garis kotak yang silau.
const Color kamusDarkSurface = Color(0xFF171918);
const Color kamusDarkSurfaceDim = Color(0xFF141615);
const Color kamusDarkSurfaceBright = Color(0xFF3D403D);
const Color kamusDarkSurfaceLowest = Color(0xFF212523);
const Color kamusDarkSurfaceLow = Color(0xFF262A27);
const Color kamusDarkSurfaceContainer = Color(0xFF2C302D);
const Color kamusDarkSurfaceHigh = Color(0xFF343835);
const Color kamusDarkSurfaceHighest = Color(0xFF3D413E);

/// Teks gelap memakai putih hangat (bukan #FFF) agar kontras tetap adem.
const Color kamusDarkOnSurface = Color(0xFFDCDEDA);
const Color kamusDarkOnSurfaceVariant = Color(0xFFA7ACA6);

/// Garis pemisah sengaja redup.
const Color kamusDarkOutline = Color(0xFF7C827B);
const Color kamusDarkOutlineVariant = Color(0xFF3A3E3A);

/// Aksen diredam.
const Color kamusDarkPrimary = Color(0xFFA2BAA0);
const Color kamusDarkOnPrimary = Color(0xFF16221A);
const Color kamusDarkPrimaryContainer = Color(0xFF2B3A2E);
const Color kamusDarkOnPrimaryContainer = Color(0xFFC2D8C0);
const Color kamusDarkSecondary = Color(0xFFB2BA92);
const Color kamusDarkOnSecondary = Color(0xFF232718);
const Color kamusDarkSecondaryContainer = Color(0xFF333B2A);
const Color kamusDarkOnSecondaryContainer = Color(0xFFCBD9AE);
const Color kamusDarkTertiary = Color(0xFFAFBDC0);
const Color kamusDarkOnTertiary = Color(0xFF1B2123);
const Color kamusDarkTertiaryContainer = Color(0xFF2C3436);
const Color kamusDarkOnTertiaryContainer = Color(0xFFC7D5D8);

/// Merah lembut supaya tidak menyala saat error.
const Color kamusDarkError = Color(0xFFDFAFA3);
const Color kamusDarkOnError = Color(0xFF3B1512);
const Color kamusDarkErrorContainer = Color(0xFF522723);
const Color kamusDarkOnErrorContainer = Color(0xFFF7DCD5);

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: kamusGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: kamusGreen,
      secondary: kamusSecondary,
      surface: kamusCream,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF2F5E8),
      surfaceContainer: const Color(0xFFECEFE2),
      surfaceContainerHigh: const Color(0xFFE6EADC),
      secondaryContainer: kamusPaleGreen,
      onSecondaryContainer: const Color(0xFF3D4827),
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: kamusDarkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: kamusDarkPrimary,
      onPrimary: kamusDarkOnPrimary,
      primaryContainer: kamusDarkPrimaryContainer,
      onPrimaryContainer: kamusDarkOnPrimaryContainer,
      secondary: kamusDarkSecondary,
      onSecondary: kamusDarkOnSecondary,
      secondaryContainer: kamusDarkSecondaryContainer,
      onSecondaryContainer: kamusDarkOnSecondaryContainer,
      tertiary: kamusDarkTertiary,
      onTertiary: kamusDarkOnTertiary,
      tertiaryContainer: kamusDarkTertiaryContainer,
      onTertiaryContainer: kamusDarkOnTertiaryContainer,
      error: kamusDarkError,
      onError: kamusDarkOnError,
      errorContainer: kamusDarkErrorContainer,
      onErrorContainer: kamusDarkOnErrorContainer,
      surface: kamusDarkSurface,
      onSurface: kamusDarkOnSurface,
      onSurfaceVariant: kamusDarkOnSurfaceVariant,
      surfaceDim: kamusDarkSurfaceDim,
      surfaceBright: kamusDarkSurfaceBright,
      surfaceContainerLowest: kamusDarkSurfaceLowest,
      surfaceContainerLow: kamusDarkSurfaceLow,
      surfaceContainer: kamusDarkSurfaceContainer,
      surfaceContainerHigh: kamusDarkSurfaceHigh,
      surfaceContainerHighest: kamusDarkSurfaceHighest,
      outline: kamusDarkOutline,
      outlineVariant: kamusDarkOutlineVariant,
      inverseSurface: kamusDarkOnSurface,
      onInverseSurface: kamusDarkSurface,
      inversePrimary: kamusGreen,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final borderAlpha = dark ? 0.45 : 0.6;
    final inputBorderAlpha = dark ? 0.5 : 0.7;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: borderAlpha)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: inputBorderAlpha)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: inputBorderAlpha)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.85), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: dark ? 0.3 : 0.5)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: dark ? 0.4 : 0.6),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
