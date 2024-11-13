import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/theme.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeDate = lightMode;

  ThemeData get themeData => _themeDate;

  bool get isDarkMode => _themeDate == darkMode;

  set themeData(ThemeData themeData) {
    _themeDate = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if( _themeDate == lightMode){
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}