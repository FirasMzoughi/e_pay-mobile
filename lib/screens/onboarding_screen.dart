import 'package:flutter/material.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:e_pay/widgets/glass_container.dart';
import 'package:e_pay/widgets/custom_buttons.dart';
import 'package:e_pay/screens/login_screen.dart';
import 'package:e_pay/l10n/app_localizations.dart';
import 'package:e_pay/widgets/language_selector.dart';
import 'package:e_pay/widgets/theme_toggle.dart';
import 'package:gap/gap.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final List<Map<String, dynamic>> pages = [
      {
        'title': loc.translate('onboarding_title_1'),
        'description': loc.translate('onboarding_desc_1'),
        'icon': Icons.flash_on,
      },
      {
        'title': loc.translate('onboarding_title_2'),
        'description': loc.translate('onboarding_desc_2'),
        'icon': Icons.sports_esports,
      },
      {
        'title': loc.translate('onboarding_title_3'),
        'description': loc.translate('onboarding_desc_3'),
        'icon': Icons.diamond,
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          image: DecorationImage(
            image: NetworkImage("https://images.unsplash.com/photo-1614850523060-8da1d56e37ad?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80"), // Subtle abstract background
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                   GlassContainer(
                      padding: const EdgeInsets.all(4),
                      borderRadius: 20,
                      child: const ThemeToggle(),
                    ),
                    const Gap(8),
                    GlassContainer(
                      padding: const EdgeInsets.all(4),
                      borderRadius: 20,
                      child: const LanguageSelector(compact: true),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassContainer(
                            height: 200,
                            width: 200,
                            borderRadius: 100, // Circle
                            child: Icon(
                              pages[index]['icon'],
                              size: 80,
                              color: AppColors.accent,
                            ),
                          ),
                          const Gap(40),
                          Text(
                            pages[index]['title'],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const Gap(20),
                          Text(
                            pages[index]['description'],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.accent
                                  : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GradientButton(
                        text: _currentPage == pages.length - 1 ? loc.translate('get_started') : loc.translate('next'),
                        onPressed: () {
                          if (_currentPage < pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          } else {
                            // Navigate to login
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          }
                        },
                      ),
                      const Gap(40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
