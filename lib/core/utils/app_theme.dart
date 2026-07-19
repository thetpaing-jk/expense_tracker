import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();
 
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
 
      // ── Color scheme ───────────────────────
      colorScheme:  ColorScheme.dark(
        primary:        AppColor.buttonColor,
        onPrimary:      AppColor.onButton,
        secondary:      AppColor.cardBackgroundColor,
        onSecondary:    AppColor.primaryTextColor,
        surface:        AppColor.cardBackgroundColor,
        onSurface:      AppColor.primaryTextColor,
        error:          AppColor.dangerColor,
        onError:        AppColor.primaryTextColor,
        outline:        AppColor.borderColor,
        outlineVariant: AppColor.borderColor,
        surfaceContainerHighest: AppColor.inputBackgroundColor,
      ),
 
      scaffoldBackgroundColor: AppColor.primaryColor,
 
      // ── AppBar ─────────────────────────────
      appBarTheme:  AppBarTheme(
        backgroundColor:     AppColor.primaryColor,
        foregroundColor:     AppColor.primaryTextColor,
        surfaceTintColor:    Colors.transparent,
        elevation:           0,
        centerTitle:         true,
        titleTextStyle: TextStyle(
          color:      AppColor.primaryTextColor,
          fontSize:   17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColor.primaryTextColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:           Colors.transparent,
          statusBarIconBrightness:  Brightness.light,
          statusBarBrightness:      Brightness.dark,
        ),
      ),
 
      // ── Card ───────────────────────────────
      cardTheme: CardThemeData(
        color:        AppColor.cardBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation:    0,
        margin:       EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColor.borderColor, width: 1),
        ),
      ),
 
      // ── Input / TextField ──────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   AppColor.inputBackgroundColor,
        hintStyle:   TextStyle(color: AppColor.placeholderColor, fontSize: 15),
        labelStyle:  TextStyle(color: AppColor.secondaryTextColor, fontSize: 13),
        prefixIconColor: AppColor.secondaryTextColor,
        suffixIconColor: AppColor.secondaryTextColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.buttonColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.dangerColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.dangerColor, width: 1.5),
        ),
      ),
 
      // ── ElevatedButton ─────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:   AppColor.buttonColor,
          foregroundColor:   AppColor.onButton,
          disabledBackgroundColor: AppColor.borderColor,
          disabledForegroundColor: AppColor.placeholderColor,
          elevation:         0,
          minimumSize:       const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0,
          ),
        ),
      ),
 
      // ── TextButton ─────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.buttonColor,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
 
      // ── OutlinedButton ─────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.buttonColor,
          side: BorderSide(color: AppColor.buttonColor, width: 1.5),
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
          foregroundColor:  AppColor.primaryTextColor,
          backgroundColor:  AppColor.inputBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
 
      // ── BottomNavigationBar ────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      AppColor.cardBackgroundColor,
        selectedItemColor:    AppColor.buttonColor,
        unselectedItemColor:  AppColor.placeholderColor,
        selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        type:      BottomNavigationBarType.fixed,
        elevation: 0,
      ),
 
      // ── Divider ────────────────────────────
      dividerTheme: DividerThemeData(
        color:     AppColor.borderColor,
        thickness: 1,
        space:     1,
      ),
 
      // ── ListTile ───────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor:       AppColor.cardBackgroundColor,
        iconColor:       AppColor.secondaryTextColor,
        textColor:       AppColor.primaryTextColor,
        titleTextStyle:  TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.primaryTextColor),
        subtitleTextStyle: TextStyle(fontSize: 12, color: AppColor.secondaryTextColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
 
      // ── Chip ───────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:    AppColor.inputBackgroundColor,
        selectedColor:      AppColor.buttonColor,
        labelStyle:         TextStyle(color: AppColor.primaryTextColor, fontSize: 12),
        side: BorderSide(color: AppColor.borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
 
      // ── SnackBar ───────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.cardBackgroundColor,
        contentTextStyle: TextStyle(color: AppColor.primaryTextColor, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
 
      // ── Dialog ─────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:  AppColor.cardBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation:        0,
        titleTextStyle:   TextStyle(color: AppColor.primaryTextColor, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: AppColor.secondaryTextColor, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColor.borderColor),
        ),
      ),
 
      // ── Switch ─────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColor.onButton : AppColor.placeholderColor),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColor.buttonColor : AppColor.inputBackgroundColor),
      ),
 
      // ── DropdownMenu ───────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColor.cardBackgroundColor),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColor.borderColor),
            ),
          ),
        ),
      ),
 
      // ── Typography ─────────────────────────
      textTheme: TextTheme(
        displayLarge:  TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w700),
        displaySmall:  TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w600),
        titleLarge:    TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium:   TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall:    TextStyle(color: AppColor.primaryTextColor,   fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge:     TextStyle(color: AppColor.primaryTextColor,   fontSize: 16),
        bodyMedium:    TextStyle(color: AppColor.primaryTextColor,   fontSize: 14),
        bodySmall:     TextStyle(color: AppColor.secondaryTextColor, fontSize: 12),
        labelLarge:    TextStyle(color: AppColor.secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w600),
        labelMedium:   TextStyle(color: AppColor.secondaryTextColor, fontSize: 12),
        labelSmall:    TextStyle(color: AppColor.placeholderColor,   fontSize: 11),
      ),
    );
  }
}