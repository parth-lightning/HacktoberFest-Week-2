import 'package:flutter/material.dart';

/// Curated color tokens matching Uber's modern dark/light design system.
class AppColors {
  // Base Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkElevated = Color(0xFF2C2C2C);
  
  // Grayscale Gradients & Borders
  static const Color gray100 = Color(0xFFF6F6F6);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray400 = Color(0xFFAFAFAF);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray800 = Color(0xFF333333);
  static const Color borderSubtle = Color(0xFF2A2A2A);

  // Brand & Accent Colors
  static const Color uberBlue = Color(0xFF276EF1);
  static const Color uberGreen = Color(0xFF05A357);
  static const Color uberGold = Color(0xFFFFC043);
  static const Color uberRed = Color(0xFFE11900);

  // Map Colors (Vector display palette matching libubermaps-gl)
  static const Color mapBackgroundDark = Color(0xFF18191D);
  static const Color mapRoadMajor = Color(0xFF2A2C33);
  static const Color mapRoadMinor = Color(0xFF22242A);
  static const Color mapBuilding3D = Color(0xFF2E313A);
  static const Color mapBuildingRoof = Color(0xFF383C47);
  static const Color mapWater = Color(0xFF121620);
  static const Color mapPark = Color(0xFF18221C);

  // Traffic Levels
  static const Color trafficClear = Color(0xFF276EF1);
  static const Color trafficModerate = Color(0xFFFFC043);
  static const Color trafficHeavy = Color(0xFFE11900);
}
