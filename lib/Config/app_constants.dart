import 'package:flutter/material.dart';

/// Constantes globales de la aplicación FitControl
class AppConstants {
  AppConstants._(); // Constructor privado para evitar instanciación

  // ==================== BORDES Y FORMAS ====================
  static const BorderRadius kBorderRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius kBorderRadiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius kBorderRadiusLarge = BorderRadius.all(Radius.circular(20));
  
  static const RoundedRectangleBorder kCardShape = RoundedRectangleBorder(
    borderRadius: kBorderRadius,
  );

  // ==================== ESPACIADO ====================
  static const double kSpacingSmall = 8.0;
  static const double kSpacingMedium = 16.0;
  static const double kSpacingLarge = 24.0;
  static const double kSpacingExtraLarge = 32.0;

  // ==================== ESTILOS DE TEXTO ====================
  static const TextStyle kTextStyleBold = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle kTextStyleSemiBold = TextStyle(fontWeight: FontWeight.w600);
  static const TextStyle kTextStyleMedium = TextStyle(fontWeight: FontWeight.w500);
  static const TextStyle kTextStyleSmall = TextStyle(fontSize: 12);
  static const TextStyle kTextStyleSmallGrey = TextStyle(fontSize: 12, color: Colors.grey);
  
  static const TextStyle kTextStyleTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle kTextStyleSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ==================== DURACIONES ====================
  static const Duration kAnimationDuration = Duration(milliseconds: 300);
  static const Duration kLoadingDelay = Duration(seconds: 1);

  // ==================== TAMAÑOS DE WIDGETS ====================
  static const double kIconSizeSmall = 18.0;
  static const double kIconSizeMedium = 24.0;
  static const double kIconSizeLarge = 28.0;

  // ==================== LÍMITES ====================
  static const int kMaxSearchHistory = 10;
  static const int kMaxRecentMeals = 10;
}
