import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the Cozy High Fantasy / Pastoral design system inspired by the mood of Frieren.
/// Replaces the cyber-blue tactical palette with parchment cream, moss green, and antique gold.
class AppTheme {
  // --- Light Menu Theme Tokens (Parchment & Moss) ---
  static const Color parchmentBackground = Color(0xFFF5EFE0); // Parchment cream
  static const Color parchmentCard = Color(0xFFFFF8E7);       // Warm ivory card
  static const Color mossGreen = Color(0xFF5A7D5A);           // Primary moss green
  static const Color mossGreenDark = Color(0xFF3F5D3F);       // Deeper moss
  static const Color antiqueGold = Color(0xFFC9A86A);         // Accent gold border/trim
  static const Color antiqueGoldLight = Color(0xFFDFCA9B);    // Highlight gold
  static const Color softMagic = Color(0xFF8FBFB5);           // Soft blue-green mana
  static const Color textOlive = Color(0xFF2B2B26);           // Dark olive text on parchment
  static const Color textOliveMuted = Color(0xFF75756B);      // Muted grimoire text

  // --- Dark Arena Theme Tokens (Deep Forest Glade) ---
  static const Color forestBackground = Color(0xFF1E2F23);    // Deep forest green
  static const Color forestSurface = Color(0xFF2A3D2E);       // Glade surface
  static const Color forestCard = Color(0xFF324937);          // Ancient ruin card
  static const Color textForestLight = Color(0xFFF5EFE0);     // Light parchment text on forest
  static const Color textForestMuted = Color(0xFFA2B4A6);     // Muted foliage text

  // --- Combat & Status Tokens ---
  static const Color pastoralHealthGreen = Color(0xFF5A9E66); // Pastoral vitality green
  static const Color softDamageRed = Color(0xFFC25450);       // Soft crimson only for damage

  // Backward-compatibility aliases for existing controller/widget bindings
  static const Color primaryAccent = softMagic;
  static const Color primaryAccentDark = mossGreen;
  static const Color primaryAccentLight = softMagic;
  static const Color darkBackground = forestBackground;
  static const Color surfaceColor = forestSurface;
  static const Color cardColor = forestCard;
  static const Color cardBorderColor = Color(0x66C9A86A);
  static const Color textPrimary = textForestLight;
  static const Color textSecondary = textForestMuted;
  static const Color textMuted = Color(0xFF7D8F82);
  static const Color onlineGreen = pastoralHealthGreen;
  static const Color dangerRed = softDamageRed;

  /// Typography styles using Cinzel (grimoire serif) and Nunito (clean readable body)
  static TextStyle get grimoireTitleStyle => GoogleFonts.cinzel(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.5,
        color: textOlive,
      );

  static TextStyle get grimoireButtonTextStyle => GoogleFonts.cinzel(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      );

  static TextStyle get grimoireRankStyle => GoogleFonts.cinzel(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: antiqueGold,
      );

  static TextStyle get bodyTextStyle => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textOlive,
      );

  /// Complete Light Menu Theme (Parchment, Moss Green, Antique Gold)
  static ThemeData get lightMenuTheme {
    final colorScheme = const ColorScheme.light(
      primary: mossGreen,
      onPrimary: Colors.white,
      secondary: antiqueGold,
      onSecondary: textOlive,
      surface: parchmentCard,
      onSurface: textOlive,
      error: softDamageRed,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: parchmentBackground,
      primaryColor: mossGreen,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: textOlive,
        displayColor: textOlive,
      ),
      cardTheme: CardThemeData(
        color: parchmentCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: antiqueGold, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mossGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: antiqueGoldLight, width: 1.2),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: mossGreen,
        inactiveTrackColor: antiqueGold.withValues(alpha: 0.25),
        thumbColor: antiqueGold,
        overlayColor: antiqueGold.withValues(alpha: 0.2),
        trackHeight: 5.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9.0),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return antiqueGold;
          }
          return textOliveMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return mossGreen.withValues(alpha: 0.5);
          }
          return Colors.black12;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: parchmentCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: textOliveMuted.withValues(alpha: 0.6),
          fontSize: 15,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.nunito().fontFamily,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: antiqueGold.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: mossGreen,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  /// Complete Dark Forest Arena Theme (Deep Green, Ancient Ruins, Soft Mana Light)
  static ThemeData get darkForestArenaTheme {
    final colorScheme = const ColorScheme.dark(
      primary: softMagic,
      onPrimary: textOlive,
      secondary: antiqueGold,
      onSecondary: textForestLight,
      surface: forestSurface,
      onSurface: textForestLight,
      error: softDamageRed,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: forestBackground,
      primaryColor: softMagic,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: textForestLight,
        displayColor: textForestLight,
      ),
      cardTheme: CardThemeData(
        color: forestCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: antiqueGold.withValues(alpha: 0.4), width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mossGreen,
          foregroundColor: textForestLight,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: antiqueGold, width: 1.0),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: softMagic,
        inactiveTrackColor: forestCard,
        thumbColor: antiqueGold,
        overlayColor: softMagic.withValues(alpha: 0.2),
        trackHeight: 5.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9.0),
      ),
    );
  }

  // Alias getter for any existing calls referencing darkTheme
  static ThemeData get darkTheme => darkForestArenaTheme;
}
