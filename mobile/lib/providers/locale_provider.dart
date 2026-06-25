import 'package:flutter/foundation.dart';

class LocaleProvider extends ChangeNotifier {
  String _locale = 'en';

  String get locale => _locale;

  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
  }
}
