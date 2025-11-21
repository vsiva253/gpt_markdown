import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:gpt_markdown/custom_widgets/glassmorphism_effects.dart';
import 'package:gpt_markdown/custom_widgets/premium_themes.dart';

void main() {
  runApp(const PremiumMarkdownExampleApp());
}

class PremiumMarkdownExampleApp extends StatefulWidget {
  const PremiumMarkdownExampleApp({super.key});

  @override
  State<PremiumMarkdownExampleApp> createState() =>
      _PremiumMarkdownExampleAppState();
}

class _PremiumMarkdownExampleAppState extends State<PremiumMarkdownExampleApp> {
  final PremiumThemeController _themeController = PremiumThemeController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        return AnimatedThemeTransition(
          theme: _themeController.currentTheme,
          child: MaterialApp(
            title: 'Premium Markdown Example',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: PremiumMarkdownScreen(themeController: _themeController),
          ),
        );
      },
    );
  }
}

class PremiumMarkdownScreen extends StatelessWidget {
  final PremiumThemeController themeController;

  const PremiumMarkdownScreen({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    const sampleMarkdown = '''
# 🚀 Premium Markdown Package

Welcome to the **most premium** markdown renderer for Flutter!

## GitHub Alerts

> [!NOTE]
> This is a premium note with beautiful styling!

> [!TIP]
> Try using different alert types for better documentation.

> [!IMPORTANT]
> Critical information stands out with special colors.

> [!WARNING]
> Be careful with this feature - it's powerful!

> [!CAUTION]
> Destructive actions should be highlighted this way.

## Task Lists

- [x] Completed task
- [ ] Pending task
- [x] Another completed task
- [ ] Future improvement

## Code Blocks

```dart
// Premium code blocks with syntax highlighting
void main() {
  print("Hello, Premium World!");
  
  PremiumGptMarkdown(
    "# Easy to use!",
    showReadingTime: true,
  );
}
```

```python
# Multiple language support
def greet(name):
    return f"Hello, {name}!"

print(greet("Premium User"))
```

## HTML Tags

This text has a <br>line break.

Press <kbd>Ctrl</kbd> + <kbd>C</kbd> to copy.

<mark>Highlighted text</mark> stands out!

<u>Underlined text</u> for emphasis.

## Mermaid Diagrams

```mermaid
graph LR
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E
```

## Math Equations

Inline math: \$E = mc^2\$

Block math:

\$\$
\\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
\$\$

## Tables

| Feature | Basic | **Premium** |
|---------|-------|------------|
| GitHub Alerts | ❌ | ✅ |
| Mermaid | ❌ | ✅ |
| HTML Tags | ❌ | ✅ |
| Animations | ❌ | ✅ |
| Themes | ❌ | ✅ (10+) |

## Lists

1. First item
2. Second item
   - Nested item
   - Another nested item
3. Third item

---

**Made with ❤️ for premium apps**

Footnote reference: [^1]

[^1]: This is a footnote with detailed information.
''';

    return Scaffold(
      body: AuroraBackground(
        colors: [
          themeController.currentTheme.primaryColor,
          themeController.currentTheme.secondaryColor,
          themeController.currentTheme.primaryColor.withOpacity(0.5),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassmorphicContainer(
                  blur: 15,
                  opacity: 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const HolographicText(
                        'Premium Markdown',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.palette, color: Colors.white),
                        onPressed: () => _showThemeSelector(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: GlassmorphicContainer(
                    blur: 10,
                    opacity: 0.1,
                    padding: const EdgeInsets.all(24),
                    child: GptMarkdown(
                      sampleMarkdown,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.85,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
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
                  currentTheme: themeController.currentTheme,
                  onThemeSelected: (theme) {
                    themeController.setTheme(theme);
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
