import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF5B5CF6);
  static const Color primaryLight = Color(0xFF8B7CFF);
  static const Color primaryDark = Color(0xFF4849D7);
  static const Color accentColor = Color(0xFFA78BFA);
  static const Color goldColor = Color(0xFFF3C969);
  static const Color goldLight = Color(0xFFFFDF92);
  static const Color successColor = Color(0xFF63D39B);
  static const Color warningColor = Color(0xFFE97800);
  static const Color errorColor = Color(0xFFFF6B6B);

  static const Color scaffoldBackgroundLight = Color(0xFFF6F7FB);
  static const Color scaffoldBackgroundDark = Color(0xFF0B0B0F);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF171B24);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF262D3A);
  static const Color elevatedCardDark = Color(0xFF303848);

  static const Color textPrimaryLight = Color(0xFF181B24);
  static const Color textSecondaryLight = Color(0xFF5F677A);
  static const Color textHintLight = Color(0xFF97A0B6);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFA8B0C4);
  static const Color textHintDark = Color(0xFF6D7385);

  static const Color dividerLight = Color(0xFFE8EBF3);
  static const Color dividerDark = Color(0x1FFFFFFF);
  static const Color warningCard = Color(0xFFFFF4D9);

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusXxl = 36;
  static const double radiusFull = 999;

  static const double radiusSmall = radiusSm;
  static const double radiusMedium = radiusMd;
  static const double radiusLarge = radiusLg;
  static const double radiusXLarge = radiusXl;

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 20;
  static const double spacingXxl = 24;

  static const double fontXs = 10;
  static const double fontSm = 12;
  static const double fontMd = 14;
  static const double fontLg = 16;
  static const double fontXl = 18;
  static const double fontXxl = 24;
  static const double fontTitle = 28;
  static const double fontHero = 34;

  static const double bottomNavHeight = 108;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF0B0B0F),
      Color(0xFF10131C),
      Color(0xFF171B24),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purpleGlowGradient = LinearGradient(
    colors: [
      Color(0x665B5CF6),
      Color(0x338B5CF6),
      Color(0x005B5CF6),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xB708080C),
      Color(0xA114141C),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient profileGradient = LinearGradient(
    colors: [
      Color(0xFF5B5CF6),
      Color(0xFF8B5CF6),
      Color(0xFF9B88FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stageBackgroundDark = LinearGradient(
    colors: [
      Color(0xFF11131A),
      Color(0xFF0B0B0F),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient stageBackgroundLight = LinearGradient(
    colors: [
      Color(0xFFF4F5FA),
      Color(0xFFE9ECF5),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> get softShadow => const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get primaryGlow => const [
        BoxShadow(
          color: Color(0x555B5CF6),
          blurRadius: 28,
          offset: Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get navShadow => const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 32,
          offset: Offset(0, 12),
        ),
      ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: scaffoldBackgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: goldColor,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: cardBackgroundLight,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F3F8),
      hintStyle: const TextStyle(
        color: textHintLight,
        fontSize: fontMd,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryColor),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerLight,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: scaffoldBackgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      secondary: goldColor,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: cardBackgroundDark,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x14FFFFFF),
      hintStyle: const TextStyle(
        color: textHintDark,
        fontSize: fontMd,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: dividerDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: dividerDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryLight),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerDark,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0x14FFFFFF),
      selectedColor: primaryColor,
      disabledColor: const Color(0x0FFFFFFF),
      side: const BorderSide(color: dividerDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
      ),
      labelStyle: const TextStyle(
        color: textSecondaryDark,
        fontSize: fontSm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
    ),
  );

  static const Color secondaryColor = goldColor;
  static const Color inkColor = scaffoldBackgroundDark;
}
