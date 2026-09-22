import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColor.primaryColor
        : const Color(0xFFF4F6FA);
    final cardBackgroundColor = isDark
        ? AppColor.cardBackgroundColor
        : const Color(0xFFFFFFFF);
    final inputBackgroundColor = isDark
        ? AppColor.inputBackgroundColor
        : const Color(0xFFE8EDF5);
    final elevatedCardColor = isDark
        ? AppColor.inputBackgroundColor
        : const Color(0xFFF1F5F9);
    final highlightColor = isDark
        ? const Color(0xFF102A25)
        : const Color(0xFFF0FAF6);
    final accentBorderColor = isDark
        ? const Color(0xFF245647)
        : const Color(0xFFD1EEE4);
    final buttonColor = isDark ? AppColor.buttonColor : const Color(0xFF1A9E6E);
    final onButton = isDark ? AppColor.onButton : const Color(0xFFFFFFFF);
    final primaryTextColor = isDark
        ? AppColor.primaryTextColor
        : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? AppColor.secondaryTextColor
        : const Color(0xFF475569);
    final placeholderColor = isDark
        ? AppColor.placeholderColor
        : const Color(0xFF94A3B8);
    final borderColor = isDark ? AppColor.borderColor : const Color(0xFFDDE3EE);
    final dangerColor = isDark ? AppColor.dangerColor : const Color(0xFFDC2626);
    final warningColor = isDark
        ? AppColor.warrningColor
        : const Color(0xFFD97706);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // ── Color scheme ───────────────────────
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: buttonColor,
            brightness: brightness,
          ).copyWith(
            primary: buttonColor,
            onPrimary: onButton,
            secondary: cardBackgroundColor,
            onSecondary: secondaryTextColor,
            secondaryContainer: highlightColor,
            onSecondaryContainer: primaryTextColor,
            tertiary: warningColor,
            surface: cardBackgroundColor,
            onSurface: primaryTextColor,
            onSurfaceVariant: secondaryTextColor,
            error: dangerColor,
            onError: isDark ? primaryTextColor : Colors.white,
            outline: borderColor,
            outlineVariant: accentBorderColor,
            surfaceContainerLow: cardBackgroundColor,
            surfaceContainer: elevatedCardColor,
            surfaceContainerHigh: elevatedCardColor,
            surfaceContainerHighest: inputBackgroundColor,
          ),

      scaffoldBackgroundColor: backgroundColor,

      // ── AppBar ─────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: primaryTextColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),

      // ── Card ───────────────────────────────
      cardTheme: CardThemeData(
        color: cardBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),

      // ── Input / TextField ──────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackgroundColor,
        hintStyle: TextStyle(color: placeholderColor, fontSize: 15),
        labelStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
        prefixIconColor: secondaryTextColor,
        suffixIconColor: secondaryTextColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: buttonColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dangerColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dangerColor, width: 1.5),
        ),
      ),

      // ── ElevatedButton ─────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: onButton,
          disabledBackgroundColor: borderColor,
          disabledForegroundColor: placeholderColor,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: buttonColor,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── OutlinedButton ─────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── IconButton ─────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(0),
          foregroundColor: primaryTextColor,
          backgroundColor: inputBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // ── BottomNavigationBar ────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackgroundColor,
        selectedItemColor: buttonColor,
        unselectedItemColor: placeholderColor,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Divider ────────────────────────────
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ───────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: cardBackgroundColor,
        iconColor: secondaryTextColor,
        textColor: primaryTextColor,
        titleTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
        ),
        subtitleTextStyle: TextStyle(fontSize: 12, color: secondaryTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ── Chip ───────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: inputBackgroundColor,
        selectedColor: buttonColor,
        labelStyle: TextStyle(color: primaryTextColor, fontSize: 12),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── SnackBar ───────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBackgroundColor,
        contentTextStyle: TextStyle(color: primaryTextColor, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ─────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: secondaryTextColor, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
      ),

      // ── Switch ─────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? onButton
              : placeholderColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? buttonColor
              : inputBackgroundColor,
        ),
      ),

      // ── DropdownMenu ───────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(cardBackgroundColor),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor),
            ),
          ),
        ),
      ),

      // ── Typography ─────────────────────────
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(color: primaryTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: primaryTextColor, fontSize: 14),
        bodySmall: TextStyle(color: secondaryTextColor, fontSize: 12),
        labelLarge: TextStyle(
          color: secondaryTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(color: secondaryTextColor, fontSize: 12),
        labelSmall: TextStyle(color: placeholderColor, fontSize: 11),
      ),
    );
  }
}
