import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/constants/app_dimensions.dart';
import 'package:toko_emas_digital/core/constants/app_spacing.dart';

// Extension to convert Hex String to Color (Copy from HomeScreen or make it Global)
extension HexColorTheme on String {
  Color toColor() {
    return Color(int.parse(replaceFirst('#', '0xff')));
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.goldAccent.toColor(),
      scaffoldBackgroundColor: AppColors.background.toColor(),
      
      // Font Poppins untuk semua teks
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary.toColor(),
        displayColor: AppColors.textPrimary.toColor(),
      ),

      // Konfigurasi AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.toColor(),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: AppDimensions.appBarHeight, // Perbaikan: toolbarHeight
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary.toColor(),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Konfigurasi Card
      cardTheme: CardTheme(
        color: AppColors.divider.toColor(),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
      ),

      // Konfigurasi Button (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldAccent.toColor(),
          foregroundColor: Colors.black, // Teks tombol emas biasanya hitam agar kontras
          minimumSize: Size.fromHeight(AppDimensions.buttonHeight), // Perbaikan: fixedSize/minimumSize
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Konfigurasi Input (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.divider.toColor(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.padding,
          vertical: AppSpacing.spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          borderSide: BorderSide(color: AppColors.goldAccent.toColor()),
        ),
      ),

      dividerColor: AppColors.divider.toColor(),
    );
  }
}
