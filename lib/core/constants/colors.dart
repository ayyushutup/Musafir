import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color primary = Color(0xFFFF6B35); // Warm Orange - "Musafir Orange"
  static const Color secondary = Color(0xFF1A1A2E); // Deep Navy
  static const Color accent = Color(0xFFE94560); // Coral Red

  // Dark Theme Surface Colors
  static const Color background = Color(0xFF0A0A0F); // Near Black
  static const Color surface = Color(0xFF141420); // Dark Card
  static const Color surfaceElevated = Color(0xFF1E1E30); // Elevated Card
  static const Color surfaceOverlay = Color(0xFF282840); // Modal/Sheet

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF9898A6);
  static const Color textTertiary = Color(0xFF5C5C6E);

  // Border & Dividers
  static const Color border = Color(0xFF2A2A3C);
  static const Color divider = Color(0xFF1E1E2E);

  // Semantic
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Interest Category Colors
  static const Map<String, Color> categoryColors = {
    'AI & Tech': Color(0xFF6C5CE7),
    'Cycling': Color(0xFF00B894),
    'Photography': Color(0xFFE17055),
    'Music': Color(0xFFA29BFE),
    'Startups': Color(0xFFFDCB6E),
    'Running': Color(0xFF74B9FF),
    'Cricket': Color(0xFF55E6C1),
    'Books': Color(0xFFFDA7DF),
    'Food': Color(0xFFF8B739),
    'Trekking': Color(0xFF58B19F),
    'Fitness': Color(0xFFFF6348),
    'Pets': Color(0xFFC8D6E5),
  };
}
