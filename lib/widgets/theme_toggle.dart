import 'package:flutter/material.dart';
import 'package:e_pay/services/theme_service.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:e_pay/widgets/glass_container.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark;
        
        return GestureDetector(
          onTap: () => ThemeService().toggleTheme(),
          child: GlassContainer(
            padding: const EdgeInsets.all(8),
            borderRadius: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey<bool>(isDark),
                color: isDark ? Colors.amber : AppColors.textDark,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
