import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  // Enhancement 3: the Settings screen updates the application theme through
  // this provider. notifyListeners() immediately rebuilds MaterialApp.
  void setDarkMode(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
  }
}
