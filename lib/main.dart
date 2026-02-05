import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:e_pay/utils/theme.dart';
import 'package:e_pay/screens/onboarding_screen.dart';
import 'package:e_pay/services/language_service.dart';
import 'package:e_pay/l10n/app_localizations.dart';
import 'package:e_pay/services/theme_service.dart';

import 'package:e_pay/utils/supabase_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseUtils.init();
  await LanguageService().init();
  await ThemeService().init();
  runApp(const EPayApp());
}

class EPayApp extends StatelessWidget {
  const EPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService().localeNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService().themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'E-Pay',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [
                Locale('ar'),
                Locale('fr'),
                Locale('en'),
                Locale('it'),
              ],
              localizationsDelegates: const [
                 AppLocalizations.delegate,
                 GlobalMaterialLocalizations.delegate,
                 GlobalWidgetsLocalizations.delegate,
                 GlobalCupertinoLocalizations.delegate,
              ],
              home: const OnboardingScreen(),
            );
          },
        );
      },
    );
  }
}
