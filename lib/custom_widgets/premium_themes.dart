import 'package:flutter/material.dart';

/// Premium theme data for gpt_markdown
class PremiumMarkdownTheme {
  const PremiumMarkdownTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.accentGradient,
    this.codeBlockColor,
    this.linkColor,
    this.quoteBarColor,
  });

  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Gradient accentGradient;
  final Color? codeBlockColor;
  final Color? linkColor;
  final Color? quoteBarColor;

  /// Get code block color or default
  Color get codeBlock => codeBlockColor ?? primaryColor.withOpacity(0.1);

  /// Get link color or default
  Color get link => linkColor ?? primaryColor;

  /// Get quote bar color or default
  Color get quoteBar => quoteBarColor ?? secondaryColor;
}

/// Collection of premium built-in themes
class PremiumThemes {
  /// Midnight Purple - Deep purple with neon accents
  static const midnightPurple = PremiumMarkdownTheme(
    name: 'Midnight Purple',
    primaryColor: Color(0xFF7B61FF),
    secondaryColor: Color(0xFFB084FF),
    backgroundColor: Color(0xFF0D0221),
    surfaceColor: Color(0xFF1A0B3F),
    textColor: Color(0xFFE8E4F3),
    accentGradient: LinearGradient(
      colors: [Color(0xFF7B61FF), Color(0xFFB084FF), Color(0xFFFF006E)],
    ),
    codeBlockColor: Color(0xFF241955),
    linkColor: Color(0xFFB084FF),
    quoteBarColor: Color(0xFF7B61FF),
  );

  /// Forest Zen - Green gradients with nature vibes
  static const forestZen = PremiumMarkdownTheme(
    name: 'Forest Zen',
    primaryColor: Color(0xFF2D8659),
    secondaryColor: Color(0xFF5FB88A),
    backgroundColor: Color(0xFF0D1F17),
    surfaceColor: Color(0xFF1A3F2E),
    textColor: Color(0xFFE8F3ED),
    accentGradient: LinearGradient(
      colors: [Color(0xFF2D8659), Color(0xFF5FB88A), Color(0xFF9FE2BF)],
    ),
    codeBlockColor: Color(0xFF1A3329),
    linkColor: Color(0xFF5FB88A),
    quoteBarColor: Color(0xFF2D8659),
  );

  /// Sunset Glow - Orange/pink warm gradients
  static const sunsetGlow = PremiumMarkdownTheme(
    name: 'Sunset Glow',
    primaryColor: Color(0xFFFF6B35),
    secondaryColor: Color(0xFFFF9F66),
    backgroundColor: Color(0xFF1F0E08),
    surfaceColor: Color(0xFF3F1D14),
    textColor: Color(0xFFFFF5F0),
    accentGradient: LinearGradient(
      colors: [Color(0xFFFF6B35), Color(0xFFFF9F66), Color(0xFFFFB88C)],
    ),
    codeBlockColor: Color(0xFF332116),
    linkColor: Color(0xFFFF9F66),
    quoteBarColor: Color(0xFFFF6B35),
  );

  /// Arctic Blue - Cool blue with ice effects
  static const arcticBlue = PremiumMarkdownTheme(
    name: 'Arctic Blue',
    primaryColor: Color(0xFF00B4D8),
    secondaryColor: Color(0xFF48CAE4),
    backgroundColor: Color(0xFF011627),
    surfaceColor: Color(0xFF0A2F4D),
    textColor: Color(0xFFE3F2FD),
    accentGradient: LinearGradient(
      colors: [Color(0xFF00B4D8), Color(0xFF48CAE4), Color(0xFF90E0EF)],
    ),
    codeBlockColor: Color(0xFF0D3B5C),
    linkColor: Color(0xFF48CAE4),
    quoteBarColor: Color(0xFF00B4D8),
  );

  /// Neon Cyberpunk - High-contrast neon on dark
  static const neonCyberpunk = PremiumMarkdownTheme(
    name: 'Neon Cyberpunk',
    primaryColor: Color(0xFF00FFF0),
    secondaryColor: Color(0xFFFF006E),
    backgroundColor: Color(0xFF000000),
    surfaceColor: Color(0xFF1A1A1A),
    textColor: Color(0xFFFFFFFF),
    accentGradient: LinearGradient(
      colors: [Color(0xFF00FFF0), Color(0xFFFF006E), Color(0xFFFFBE0B)],
    ),
    codeBlockColor: Color(0xFF0D0D0D),
    linkColor: Color(0xFF00FFF0),
    quoteBarColor: Color(0xFFFF006E),
  );

  /// Rose Gold - Elegant rose gold accents
  static const roseGold = PremiumMarkdownTheme(
    name: 'Rose Gold',
    primaryColor: Color(0xFFB76E79),
    secondaryColor: Color(0xFFE8B4B8),
    backgroundColor: Color(0xFF1F1618),
    surfaceColor: Color(0xFF362B2D),
    textColor: Color(0xFFFFF5F5),
    accentGradient: LinearGradient(
      colors: [Color(0xFFB76E79), Color(0xFFE8B4B8), Color(0xFFFFC9CE)],
    ),
    codeBlockColor: Color(0xFF2E2325),
    linkColor: Color(0xFFE8B4B8),
    quoteBarColor: Color(0xFFB76E79),
  );

  /// Ocean Deep - Blue depths with wave effects
  static const oceanDeep = PremiumMarkdownTheme(
    name: 'Ocean Deep',
    primaryColor: Color(0xFF0077B6),
    secondaryColor: Color(0xFF0096C7),
    backgroundColor: Color(0xFF03045E),
    surfaceColor: Color(0xFF023E8A),
    textColor: Color(0xFFCAF0F8),
    accentGradient: LinearGradient(
      colors: [Color(0xFF0077B6), Color(0xFF0096C7), Color(0xFF00B4D8)],
    ),
    codeBlockColor: Color(0xFF024A7A),
    linkColor: Color(0xFF0096C7),
    quoteBarColor: Color(0xFF0077B6),
  );

  /// Cherry Blossom - Soft pink Japanese aesthetics
  static const cherryBlossom = PremiumMarkdownTheme(
    name: 'Cherry Blossom',
    primaryColor: Color(0xFFFFB7C5),
    secondaryColor: Color(0xFFFFD6E0),
    backgroundColor: Color(0xFF2B1F23),
    surfaceColor: Color(0xFF463339),
    textColor: Color(0xFFFFFAFB),
    accentGradient: LinearGradient(
      colors: [Color(0xFFFFB7C5), Color(0xFFFFD6E0), Color(0xFFFFF0F3)],
    ),
    codeBlockColor: Color(0xFF3D2F33),
    linkColor: Color(0xFFFFD6E0),
    quoteBarColor: Color(0xFFFFB7C5),
  );

  /// Monochrome Pro - Premium black and white
  static const monochromePro = PremiumMarkdownTheme(
    name: 'Monochrome Pro',
    primaryColor: Color(0xFFFFFFFF),
    secondaryColor: Color(0xFFB8B8B8),
    backgroundColor: Color(0xFF000000),
    surfaceColor: Color(0xFF1A1A1A),
    textColor: Color(0xFFFFFFFF),
    accentGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFB8B8B8), Color(0xFF808080)],
    ),
    codeBlockColor: Color(0xFF0D0D0D),
    linkColor: Color(0xFFB8B8B8),
    quoteBarColor: Color(0xFFFFFFFF),
  );

  /// Rainbow Pride - Vibrant rainbow gradients
  static const rainbowPride = PremiumMarkdownTheme(
    name: 'Rainbow Pride',
    primaryColor: Color(0xFFFF006E),
    secondaryColor: Color(0xFF7B61FF),
    backgroundColor: Color(0xFF1A1A1A),
    surfaceColor: Color(0xFF2D2D2D),
    textColor: Color(0xFFFFFFFF),
    accentGradient: LinearGradient(
      colors: [
        Color(0xFFFF006E),
        Color(0xFFFF8500),
        Color(0xFFFFBE0B),
        Color(0xFF06FFA5),
        Color(0xFF00B4D8),
        Color(0xFF7B61FF),
      ],
    ),
    codeBlockColor: Color(0xFF1F1F1F),
    linkColor: Color(0xFF00FFF0),
    quoteBarColor: Color(0xFFFF006E),
  );

  /// All available themes
  static const List<PremiumMarkdownTheme> all = [
    midnightPurple,
    forestZen,
    sunsetGlow,
    arcticBlue,
    neonCyberpunk,
    roseGold,
    oceanDeep,
    cherryBlossom,
    monochromePro,
    rainbowPride,
  ];
}

/// Theme controller for managing theme selection and transitions
class PremiumThemeController extends ChangeNotifier {
  PremiumThemeController({
    PremiumMarkdownTheme? initialTheme,
    this.enableAutoTheme = false,
  }) : _currentTheme = initialTheme ?? PremiumThemes.midnightPurple;

  PremiumMarkdownTheme _currentTheme;
  final bool enableAutoTheme;

  PremiumMarkdownTheme get currentTheme => _currentTheme;

  /// Change theme with smooth transition
  void setTheme(PremiumMarkdownTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  /// Auto-select theme based on time of day
  void updateAutoTheme() {
    if (!enableAutoTheme) return;

    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 9) {
      // Morning: Soft colors
      setTheme(PremiumThemes.cherryBlossom);
    } else if (hour >= 9 && hour < 12) {
      // Late morning: Fresh colors
      setTheme(PremiumThemes.forestZen);
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: Bright colors
      setTheme(PremiumThemes.arcticBlue);
    } else if (hour >= 17 && hour < 20) {
      // Evening: Warm colors
      setTheme(PremiumThemes.sunsetGlow);
    } else if (hour >= 20 && hour < 22) {
      // Night: Deep colors
      setTheme(PremiumThemes.oceanDeep);
    } else {
      // Late night: Dark colors
      setTheme(PremiumThemes.midnightPurple);
    }
  }
}

/// Animated theme transition widget
class AnimatedThemeTransition extends StatefulWidget {
  const AnimatedThemeTransition({
    super.key,
    required this.theme,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
  });

  final PremiumMarkdownTheme theme;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedThemeTransition> createState() =>
      _AnimatedThemeTransitionState();
}

class _AnimatedThemeTransitionState extends State<AnimatedThemeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  PremiumMarkdownTheme? _previousTheme;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _previousTheme = widget.theme;
  }

  @override
  void didUpdateWidget(AnimatedThemeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme) {
      _previousTheme = oldWidget.theme;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t)!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        final previous = _previousTheme ?? widget.theme;
        final current = widget.theme;

        return Container(
          decoration: BoxDecoration(
            color: _lerpColor(
              previous.backgroundColor,
              current.backgroundColor,
              t,
            ),
          ),
          child: Theme(
            data: ThemeData(
              brightness: Brightness.dark,
              primaryColor: _lerpColor(
                previous.primaryColor,
                current.primaryColor,
                t,
              ),
              colorScheme: ColorScheme.dark(
                primary: _lerpColor(
                  previous.primaryColor,
                  current.primaryColor,
                  t,
                ),
                secondary: _lerpColor(
                  previous.secondaryColor,
                  current.secondaryColor,
                  t,
                ),
                surface: _lerpColor(
                  previous.surfaceColor,
                  current.surfaceColor,
                  t,
                ),
                background: _lerpColor(
                  previous.backgroundColor,
                  current.backgroundColor,
                  t,
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(
                  color: _lerpColor(previous.textColor, current.textColor, t),
                ),
                bodyMedium: TextStyle(
                  color: _lerpColor(previous.textColor, current.textColor, t),
                ),
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Theme selector widget with preview
class PremiumThemeSelector extends StatelessWidget {
  const PremiumThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
    this.compact = false,
  });

  final PremiumMarkdownTheme currentTheme;
  final ValueChanged<PremiumMarkdownTheme> onThemeSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return DropdownButton<PremiumMarkdownTheme>(
        value: currentTheme,
        items:
            PremiumThemes.all.map((theme) {
              return DropdownMenuItem(
                value: theme,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: theme.accentGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(theme.name),
                  ],
                ),
              );
            }).toList(),
        onChanged: (theme) {
          if (theme != null) onThemeSelected(theme);
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: PremiumThemes.all.length,
      itemBuilder: (context, index) {
        final theme = PremiumThemes.all[index];
        final isSelected = theme == currentTheme;

        return GestureDetector(
          onTap: () => onThemeSelected(theme),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: theme.accentGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                      : [],
            ),
            child: Center(
              child: Text(
                theme.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
