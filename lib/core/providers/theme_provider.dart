import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // State: false = light, true = dark
  bool _isDark = false;

  /// Getter untuk mendapatkan status tema saat ini
  bool get isDark => _isDark;

  /// Mengembalikan ThemeMode yang akan digunakan oleh MaterialApp
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Fungsi untuk mengubah tema (toggle) dan memberitahu UI untuk update
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  /// (Opsional) Fungsi untuk set tema secara spesifik
  void setDarkTheme(bool isDark) {
    _isDark = isDark;
    notifyListeners();
  }
}
