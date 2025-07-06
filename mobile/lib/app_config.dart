import 'package:flutter/material.dart';

class AppConfig {
  // Configuration des performances
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const Duration cacheDuration = Duration(minutes: 5);
  static const int maxCacheSize = 50;

  // Configuration des images
  static const double defaultImageSize = 64.0;
  static const double avatarRadius = 22.0;

  // Configuration des listes
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.85;
  static const double gridCrossAxisSpacing = 12.0;
  static const double gridMainAxisSpacing = 12.0;

  // Configuration des animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Curve defaultAnimationCurve = Curves.easeInOut;

  // Configuration du cache
  static const String doctorsCacheKey = 'doctors_list';
  static const String appointmentsCacheKey = 'appointments_list';
  static const String availabilityCacheKey = 'availability_list';
}
