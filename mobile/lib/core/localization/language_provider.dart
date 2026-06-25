import 'package:flutter/material.dart';
import 'supported_locales.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = SupportedLocales.english;

  Locale get locale => _locale;
  bool get isRTL => SupportedLocales.isRTL(_locale);

  void setLocale(Locale locale) {
    if (!SupportedLocales.locales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void setLocaleByCode(String languageCode) {
    final locale = SupportedLocales.locales.firstWhere(
      (l) => l.languageCode == languageCode,
      orElse: () => SupportedLocales.english,
    );
    setLocale(locale);
  }
}
