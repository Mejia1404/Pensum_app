import 'package:flutter/material.dart';

/// Sistema de colores de la aplicación
/// Tema azul consistente entre modo claro y oscuro
class AppColors {
  AppColors._();

  // ============== MODO OSCURO ==============
  static const darkBackground = Color(0xFF030B18);
  static const darkSurface = Color(0xFF081A33);
  static const darkCard = Color(0xFF10284A);
  static const darkBorder = Color(0xFF17406B);

  // ============== MODO CLARO ==============
  static const lightBackground = Color(0xFFEDF4FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF4F9FF);
  static const lightBorder = Color(0xFFD7E4F8);

  // ============== COLORES PRIMARIOS ==============
  static const primary = Color(0xFF3465DD); // Azul principal
  static const primaryLight = Color(0xFF7EA4FF);
  static const primaryDark = Color(0xFF1747B3);

  // ============== COLORES DE ACENTO ==============
  static const accent = Color(0xFF57C7FF); // Azul cian suave
  static const accentLight = Color(0xFF9FE9FF);
  static const accentDark = Color(0xFF258CC1);

  // ============== COLORES SECUNDARIOS ==============
  static const secondary = Color(0xFF7FA8FF); // Azul suave
  static const secondaryDark = Color(0xFF4E76C8);

  // ============== ESTADOS ==============
  static const success = Color(0xFF46D6FF);
  static const successLight = Color(0xFF9BE9FF);
  static const warning = Color(0xFF8FAEFF);
  static const warningLight = Color(0xFFCADBFF);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFF87171);

  // ============== TEXTO - MODO OSCURO ==============
  static const textDarkPrimary = Color(0xFFF3F8FF);
  static const textDarkSecondary = Color(0xFF9CB5D6);
  static const textDarkMuted = Color(0xFF7D95B8);

  // ============== TEXTO - MODO CLARO ==============
  static const textLightPrimary = Color(0xFF112A4B);
  static const textLightSecondary = Color(0xFF4C6B96);
  static const textLightMuted = Color(0xFF7A8FB5);

  // ============== GRADIENTES ==============
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const gradientDarkCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCard, darkSurface],
  );
}
