import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';



const supportedLocales = [Locale('fr'), Locale('ar')];

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'app_locale';

  @override
  Locale build() => const Locale('fr');

  Future<SharedPreferences> get _storage => SharedPreferences.getInstance();

  Future<void> loadSaved() async {
    final prefs = await _storage;
    final code = prefs.getString(_key);
    if (code != null && supportedLocales.any((l) => l.languageCode == code)) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await _storage;
    await prefs.setString(_key, locale.languageCode);
  }

  bool get isArabic => state.languageCode == 'ar';
}
