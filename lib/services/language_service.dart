import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('ar'));

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('language_code');
      if (savedCode != null) {
        localeNotifier.value = Locale(savedCode);
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> changeLanguage(String code) async {
    localeNotifier.value = Locale(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', code);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }
}
