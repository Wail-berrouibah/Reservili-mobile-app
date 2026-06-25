import 'package:flutter/material.dart';

class SupportedLocales {
  SupportedLocales._();

  static const Locale english = Locale('en', 'US');
  static const Locale french = Locale('fr', 'FR');
  static const Locale arabic = Locale('ar', 'SA');

  static const List<Locale> locales = [english, french, arabic];

  static const Locale fallback = english;

  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  static bool isRTL(Locale locale) {
    return locale.languageCode == 'ar';
  }
}
