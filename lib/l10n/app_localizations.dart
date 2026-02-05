import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'onboarding_title_1': 'دفع سريع وآمن',
      'onboarding_desc_1': 'ادفع مقابل خدماتك الدولية المفضلة باستخدام طرق دفع تونسية محلية.',
      'onboarding_title_2': 'كل ألعابك في مكان واحد',
      'onboarding_desc_2': 'احصل على جواهر ورصيد واشتراكات لـ Free Fire و PUBG والمزيد.',
      'onboarding_title_3': 'تجربة مميزة',
      'onboarding_desc_3': 'استنتع بافضل تطبيق شحن في تونس',
      'get_started': 'ابدأ الآن',
      'next': 'التالي',
      'hello_user': 'مرحبًا',
      'discover_games': 'اكتشف الألعاب',
      'cat_all': 'الكل',
      'cat_games': 'ألعاب',
      'cat_streaming': 'بث',
      'cat_shopping': 'تسوق',
    },
    'fr': {
      'onboarding_title_1': 'Paiements Rapides\net Sécurisés',
      'onboarding_desc_1': 'Payez vos services internationaux préférés avec des méthodes tunisiennes locales.',
      'onboarding_title_2': 'Tous Vos Jeux\nAu Même Endroit',
      'onboarding_desc_2': 'Obtenez diamants, pièces et abonnements pour Free Fire, PUBG et plus.',
      'onboarding_title_3': 'Expérience\nPremium',
      'onboarding_desc_3': 'Profitez d\'une interface fluide de style glassmorphism conçue pour vous.',
      'get_started': 'Commencer',
      'next': 'Suivant',
      'hello_user': 'Bonjour',
      'discover_games': 'Découvrir les Jeux',
      'cat_all': 'Tout',
      'cat_games': 'Jeux',
      'cat_streaming': 'Streaming',
      'cat_shopping': 'Shopping',
    },
    'en': {
      'onboarding_title_1': 'Fast & Secure\nPayments',
      'onboarding_desc_1': 'Pay for your favorite international services using local Tunisian methods.',
      'onboarding_title_2': 'All Your Games\nOne Place',
      'onboarding_desc_2': 'Get diamonds, coins, and subscriptions for Free Fire, PUBG, and more.',
      'onboarding_title_3': 'Premium\nExperience',
      'onboarding_desc_3': 'Enjoy a smooth, glassmorphic interface designed for you.',
      'get_started': 'Get Started',
      'next': 'Next',
      'hello_user': 'Hello',
      'discover_games': 'Discover Games',
      'cat_all': 'All',
      'cat_games': 'Games',
      'cat_streaming': 'Streaming',
      'cat_shopping': 'Shopping',
    },
    'it': {
      'onboarding_title_1': 'Pagamenti Veloci\ne Sicuri',
      'onboarding_desc_1': 'Paga i tuoi servizi internazionali preferiti usando metodi locali tunisini.',
      'onboarding_title_2': 'Tutti i Tuoi Giochi\nin Un Posto',
      'onboarding_desc_2': 'Ottieni diamanti, monete e abbonamenti per Free Fire, PUBG e altro.',
      'onboarding_title_3': 'Esperienza\nPremium',
      'onboarding_desc_3': 'Goditi un\'interfaccia fluida in stile glassmorphism progettata per te.',
      'get_started': 'Inizia',
      'next': 'Avanti',
      'hello_user': 'Ciao',
      'discover_games': 'Scopri Giochi',
      'cat_all': 'Tutti',
      'cat_games': 'Giochi',
      'cat_streaming': 'Streaming',
      'cat_shopping': 'Shopping',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en', 'fr', 'it'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
