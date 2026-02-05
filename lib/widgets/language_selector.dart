import 'package:flutter/material.dart';
import 'package:e_pay/services/language_service.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:gap/gap.dart';

class LanguageSelector extends StatelessWidget {
  final bool compact;
  
  const LanguageSelector({Key? key, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService().localeNotifier,
      builder: (context, locale, child) {
        return PopupMenuButton<String>(
          initialValue: locale.languageCode,
          onSelected: (String code) {
            LanguageService().changeLanguage(code);
          },
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          color: Theme.of(context).cardColor.withOpacity(0.9),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(compact ? 4 : 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            child: Text(
              _getFlag(locale.languageCode),
              style: TextStyle(
                fontSize: compact ? 24 : 32,
              ),
            ),
          ),
          itemBuilder: (BuildContext context) {
            final languages = ['ar', 'fr', 'en', 'it'];
            return languages.map((String code) {
              return PopupMenuItem<String>(
                value: code,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                child: Row(
                  children: [
                    Text(
                      _getFlag(code),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Gap(12),
                    Text(
                      _getName(code),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'ar': return '🇹🇳';
      case 'fr': return '🇫🇷';
      case 'en': return '🇺🇸';
      case 'it': return '🇮🇹';
      default: return '🇹🇳';
    }
  }

  String _getName(String code) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'it': return 'Italiano';
      default: return '';
    }
  }

  Widget _buildFlag(BuildContext context, String code, String flag, bool isSelected) {
    // Legacy method kept if needed, but unused in new design
    return Text(flag);
  }
}
