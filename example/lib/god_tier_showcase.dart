import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:gpt_markdown/custom_widgets/glassmorphism_effects.dart';
import 'package:gpt_markdown/custom_widgets/premium_themes.dart';
import 'package:gpt_markdown/custom_widgets/magnetic_interactions.dart';
import 'package:gpt_markdown/custom_widgets/content_animations.dart';

void main() {
  runApp(const GodTierShowcaseApp());
}

class GodTierShowcaseApp extends StatefulWidget {
  const GodTierShowcaseApp({super.key});

  @override
  State<GodTierShowcaseApp> createState() => _GodTierShowcaseAppState();
}

class _GodTierShowcaseAppState extends State<GodTierShowcaseApp> {
  final PremiumThemeController _themeController = PremiumThemeController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        return AnimatedThemeTransition(
          theme: _themeController.currentTheme,
          child: MaterialApp(
            title: 'GPT Markdown - God Tier 2.0',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: ShowcaseHomePage(themeController: _themeController),
          ),
        );
      },
    );
  }
}

class ShowcaseHomePage extends StatefulWidget {
  final PremiumThemeController themeController;

  const ShowcaseHomePage({
    super.key,
    required this.themeController,
  });

  @override
  State<ShowcaseHomePage> createState() => _ShowcaseHomePageState();
}

class _ShowcaseHomePageState extends State<ShowcaseHomePage> {
  int _currentPage = 0;

  final List<ShowcasePage> _pages = [
    const ShowcasePage(
      title: 'Glassmorphism Effects',
      icon: Icons.blur_on,
    ),
    const ShowcasePage(
      title: 'Premium Themes',
      icon: Icons.palette,
    ),
    const ShowcasePage(
      title: 'Magnetic Interactions',
      icon: Icons.touch_app,
    ),
    const ShowcasePage(
      title: 'Content Animations',
      icon: Icons.animation,
    ),
    const ShowcasePage(
      title: 'Markdown Features',
      icon: Icons.text_fields,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        colors: [
          widget.themeController.currentTheme.primaryColor,
          widget.themeController.currentTheme.secondaryColor,
          widget.themeController.currentTheme.primaryColor.withOpacity(0.5),
        ],
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView(
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    _buildGlassmorphismPage(),
                    _buildThemesPage(),
                    _buildMagneticPage(),
                    _buildAnimationsPage(),
                    _buildMarkdownPage(),
                  ],
                ),
              ),
              _buildPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassmorphicContainer(
        blur: 15,
        opacity: 0.15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HolographicText(
                  'GPT Markdown',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'God Tier 2.0 Showcase',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            MagneticButton(
              onPressed: () => _showThemeSelector(),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.palette, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: _currentPage == index
                  ? widget.themeController.currentTheme.accentGradient
                  : null,
              color:
                  _currentPage == index ? null : Colors.white.withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGlassmorphismPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SlideReveal(
            child: GlassmorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HolographicText(
                    'Glassmorphism Effects',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Premium frosted glass effects with blur backdrop',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideReveal(
            delay: const Duration(milliseconds: 200),
            child: NeomorphicCard(
              padding: const EdgeInsets.all(24),
              onTap: () {},
              child: const Column(
                children: [
                  Icon(Icons.layers, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Neomorphic Card',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Soft UI design with depth shadows',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideReveal(
            delay: const Duration(milliseconds: 400),
            child: GradientBorderBox(
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  Icon(Icons.auto_awesome, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Animated Gradient Border',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rainbow effect that rotates smoothly',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideReveal(
            delay: const Duration(milliseconds: 600),
            child: MetallicSurface(
              borderRadius: 16,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: const Column(
                  children: [
                    Icon(Icons.diamond, size: 48, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Metallic Surface',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Premium sheen effect',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HolographicText(
              'Premium Themes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose from 10 stunning themes with smooth transitions',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 24),
            PremiumThemeSelector(
              currentTheme: widget.themeController.currentTheme,
              onThemeSelected: (theme) {
                widget.themeController.setTheme(theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagneticPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassmorphicContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HolographicText(
                  'Magnetic Interactions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Interactive elements that respond to your cursor',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 24),
                Center(
                  child: MagneticButton(
                    onPressed: () {},
                    backgroundColor:
                        widget.themeController.currentTheme.primaryColor,
                    child: const Text(
                      'Hover Over Me!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElasticLink(
                    text: 'Elastic Link with Bounce',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ParallaxCard(
            child: GlassmorphicContainer(
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  Icon(Icons.threed_rotation, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    '3D Parallax Card',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Move your mouse to see the effect',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassmorphicContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HolographicText(
                  'Content Animations',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const TypewriterEffect(
                  text: 'This text appears character by character...',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const WaveMotion(
                  text: 'Wave Motion',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StaggeredAnimationList(
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassmorphicContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: widget
                              .themeController.currentTheme.accentGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Staggered Item ${index + 1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPage() {
    const sampleMarkdown = '''
# 🚀 GPT Markdown

Welcome to the **most premium** markdown renderer for Flutter!

## Features

- ✨ Glassmorphism effects
- 🎨 10+ premium themes
- 🧲 Magnetic interactions
- 🎬 Stunning animations

### Code Example

```dart
GptMarkdown(
  "# Hello World",
  style: TextStyle(color: Colors.white),
)
```

> [!TIP]
> This is a premium tip with beautiful styling!

## Lists

1. First item
2. Second item
3. Third item

- [x] Completed task
- [ ] Pending task

---

**Made with ❤️ for premium apps**
''';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(24),
        child: const GptMarkdown(
          sampleMarkdown,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphicContainer(
          blur: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HolographicText(
                'Select Theme',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 400,
                child: PremiumThemeSelector(
                  currentTheme: widget.themeController.currentTheme,
                  onThemeSelected: (theme) {
                    widget.themeController.setTheme(theme);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShowcasePage {
  final String title;
  final IconData icon;

  const ShowcasePage({
    required this.title,
    required this.icon,
  });
}
