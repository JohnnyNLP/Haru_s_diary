import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';
SharedPreferences? _prefs;

abstract class CustomTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static CustomTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? DarkModeTheme()
          : LightModeTheme();

  late Color primaryColor;
  late Color secondaryColor;
  late Color tertiaryColor;
  late Color alternate;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color primaryText;
  late Color secondaryText;

  late Color primaryBtnText;
  late Color lineColor;

  late Color gray600;
  late Color accent1;
  late Color primaryButtonText;
  late Color primary;
  late Color white70;
  late Color tertiary;

  late Map<String, Color> sentimentColor;

  TextStyle get title1 => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.sp,
      );
  TextStyle get title2 => GoogleFonts.getFont(
        'Poppins',
        color: secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.sp,
      );
  TextStyle get title3 => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
      );
  TextStyle get subtitle1 => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18.sp,
      );
  TextStyle get subtitle2 => GoogleFonts.getFont(
        'Poppins',
        color: secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      );
  TextStyle get bodyText1 => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      );
  TextStyle get bodyText2 => GoogleFonts.getFont(
        'Poppins',
        color: secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      );
  TextStyle get headlineSmall => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 24.sp,
      );
  TextStyle get headlineMedium => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 28.sp,
      );
  TextStyle get titleSmall => GoogleFonts.getFont(
        'Poppins',
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
      );
  TextStyle get bodySmall => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
      );
  TextStyle get bodyMedium => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
      );
  TextStyle get displaySmall => GoogleFonts.getFont(
        'Poppins',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 36.sp,
      );
  TextStyle get labelLarge => GoogleFonts.getFont(
        'Poppins',
        color: secondaryText,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
      );
  TextStyle get labelMedium => GoogleFonts.getFont(
        'Poppins',
        color: secondaryText,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
      );
}

class LightModeTheme extends CustomTheme {
  late Color primaryColor = const Color(0xFF4B39EF);
  late Color secondaryColor = const Color(0xFF39D2C0);
  late Color tertiaryColor = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFFE0E3E7);
  late Color primaryBackground = const Color(0xFFF5F7FA);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color primaryText = const Color(0xFF101213);
  late Color secondaryText = const Color(0xFF57636C);

  late Color primaryBtnText = Color(0xFFFFFFFF);
  late Color lineColor = Color(0xFFE0E3E7);

  late Color gray600 = Color(Colors.grey[600].hashCode);
  late Color white70 = Color(Colors.white70.hashCode);
  late Color accent1 = Color(0xFFEEEEEE);
  late Color primaryButtonText = const Color(0xFFFFFFFF);
  late Color primary = const Color(0xFF012A4A);
  late Color tertiary = Color(0XFFEE8B60);

  late Map<String, Color> sentimentColor = {
    '기쁨': Color.fromARGB(255, 248, 234, 110),
    '기대': Color.fromARGB(255, 73, 178, 223),
    '애정': Color.fromARGB(255, 247, 124, 124),
    '열정': Color.fromARGB(255, 247, 158, 42),
    '슬픔': Color.fromARGB(255, 57, 105, 138),
    '분노': Color.fromARGB(255, 245, 96, 70),
    '우울': Color.fromARGB(255, 194, 61, 194),
    '혐오': Color.fromARGB(255, 216, 74, 74), // 스트레스?
    '중립': Color.fromARGB(255, 171, 167, 167),
  };
}

class DarkModeTheme extends CustomTheme {
  late Color primaryColor = const Color(0xFF4B39EF);
  late Color secondaryColor = const Color(0xFF39D2C0);
  late Color tertiaryColor = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFFFF5963);
  late Color primaryBackground = const Color(0xFF1A1F24);
  late Color secondaryBackground = const Color(0xFF101213);
  late Color primaryText = const Color(0xFFFFFFFF);
  late Color secondaryText = const Color(0xFF95A1AC);

  late Color primaryBtnText = Color(0xFFFFFFFF);
  late Color lineColor = Color(0xFF22282F);

  late Color gray600 = Color(Colors.grey[600].hashCode);
  late Color white70 = Color(Colors.white70.hashCode);
  late Color accent1 = const Color(0xFFEEEEEE);
  late Color primaryButtonText = const Color(0xFFFFFFFF);
  late Color primary = const Color(0xFF012A4A);
  late Color tertiary = Color(0XFFEE8B60);

  late Map<String, Color> sentimentColor = {
    '기쁨': Color.fromARGB(255, 248, 234, 110),
    '기대': Color.fromARGB(255, 73, 178, 223),
    '애정': Color.fromARGB(255, 247, 124, 124),
    '열정': Color.fromARGB(255, 247, 158, 42),
    '슬픔': Color.fromARGB(255, 57, 105, 138),
    '분노': Color.fromARGB(255, 245, 96, 70),
    '우울': Color.fromARGB(255, 194, 61, 194),
    '혐오': Color.fromARGB(255, 216, 74, 74), // 스트레스?
    '중립': Color.fromARGB(255, 171, 167, 167),
  };
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
    double? letterSpacing,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily!,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              decoration: decoration,
              height: lineHeight,
              letterSpacing: letterSpacing,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              decoration: decoration,
              height: lineHeight,
              letterSpacing: letterSpacing,
            );
}
