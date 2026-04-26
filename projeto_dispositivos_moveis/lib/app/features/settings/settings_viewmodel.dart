import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    darkModeEnabled = value;
    notifyListeners();
  }
}