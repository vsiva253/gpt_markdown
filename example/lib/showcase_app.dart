import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:gpt_markdown/custom_widgets/syntax_highlighter.dart';

void main() {
  runApp(const GptMarkdownShowcase());
}

class GptMarkdownShowcase extends StatefulWidget {
  const GptMarkdownShowcase({super.key});

  @override
  State<GptMarkdownShowcase> createState() => _GptMarkdownShowcaseState();
}

class _GptMarkdownShowcaseState extends State<GptMarkdownShowcase> {
  ThemeMode _themeMode = ThemeMode.dark;
  SyntaxTheme _syntaxTheme = SyntaxTheme.vsDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPT Markdown Showcase',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        extensions: [
          GptMarkdownThemeData(
            brightness: Brightness.light,
          ),
        ],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        extensions: [
          GptMarkdownThemeData(
            brightness: Brightness.dark,
          ),
        ],
      ),
      home: ShowcaseHome(
        onThemeToggle: () {
          setState(() {
            _themeMode =
                _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          });
        },
        onThemeChange: (theme) {
          setState(() => _syntaxTheme = theme);
        },
        currentTheme: _syntaxTheme,
      ),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final Function(SyntaxTheme) onThemeChange;
  final SyntaxTheme currentTheme;

  const ShowcaseHome({
    super.key,
    required this.onThemeToggle,
    required this.onThemeChange,
    required this.currentTheme,
  });

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _selectedIndex = 0;

  final List<ShowcaseSection> _sections = [
    ShowcaseSection(
      title: 'Overview',
      icon: Icons.home,
      content: _overviewMarkdown,
    ),
    ShowcaseSection(
      title: 'Code Blocks',
      icon: Icons.code,
      content: _codeBlocksMarkdown,
    ),
    ShowcaseSection(
      title: 'Alerts',
      icon: Icons.info,
      content: _alertsMarkdown,
    ),
    ShowcaseSection(
      title: 'Tables',
      icon: Icons.table_chart,
      content: _tablesMarkdown,
    ),
    ShowcaseSection(
      title: 'Math',
      icon: Icons.functions,
      content: _mathMarkdown,
    ),
    ShowcaseSection(
      title: 'Advanced',
      icon: Icons.star,
      content: _advancedMarkdown,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPT Markdown Showcase'),
        actions: [
          // Theme selector
          PopupMenuButton<SyntaxTheme>(
            icon: const Icon(Icons.palette),
            tooltip: 'Syntax Theme',
            onSelected: widget.onThemeChange,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SyntaxTheme.vsDark,
                child: Text('VS Code Dark'),
              ),
              const PopupMenuItem(
                value: SyntaxTheme.dracula,
                child: Text('Dracula'),
              ),
              const PopupMenuItem(
                value: SyntaxTheme.nord,
                child: Text('Nord'),
              ),
              const PopupMenuItem(
                value: SyntaxTheme.monokai,
                child: Text('Monokai'),
              ),
              const PopupMenuItem(
                value: SyntaxTheme.github,
                child: Text('GitHub'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle Theme',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: _sections
                .map((section) => NavigationRailDestination(
                      icon: Icon(section.icon),
                      label: Text(section.title),
                    ))
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Content
          Expanded(
            child: SelectionArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    _sections[_selectedIndex].title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  GptMarkdown(
                    _sections[_selectedIndex].content,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowcaseSection {
  final String title;
  final IconData icon;
  final String content;

  const ShowcaseSection({
    required this.title,
    required this.icon,
    required this.content,
  });
}

// Markdown content for each section
const _overviewMarkdown = '''
# Welcome to GPT Markdown! 🚀

This showcase demonstrates all the amazing features of the **gpt_markdown** package.

## What's New in v2.0

- 🎨 **Beautiful Syntax Highlighting** with 8 themes
- 📋 **Copy to Clipboard** for all code blocks
- 🔢 **Line Numbers** (optional)
- 🎯 **GitHub-Style Alerts** (Note, Tip, Important, Warning, Caution)
- 📁 **Collapsible Sections** with smooth animations
- 🎭 **Enhanced Tables** with hover effects
- ⚡ **Performance Optimizations**

## Quick Example

Here's a simple example:

```dart
import 'package:gpt_markdown/gpt_markdown.dart';

GptMarkdown(
  """
  # Hello World!
  This is **bold** and this is *italic*.
  """,
)
```

Navigate through the sections using the sidebar to explore all features!
''';

const _codeBlocksMarkdown = '''
# Code Blocks

Code blocks now come with **syntax highlighting**, **copy buttons**, and **language badges**!

## Python Example

```python
def fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Generate first 10 Fibonacci numbers
for i in range(10):
    print(f"F({i}) = {fibonacci(i)}")
```

## JavaScript Example

```javascript
// Async/await example
async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/\${userId}`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error;
  }
}
```

## Dart Example

```dart
class User {
  final String name;
  final int age;
  
  User({required this.name, required this.age});
  
  @override
  String toString() => 'User(name: \$name, age: \$age)';
}

void main() {
  final user = User(name: 'Alice', age: 30);
  print(user);
}
```

## Features

- ✅ Automatic language detection
- ✅ One-click copy to clipboard
- ✅ Beautiful syntax highlighting
- ✅ Optional line numbers
- ✅ Expand/collapse for long code
''';

const _alertsMarkdown = '''
# GitHub-Style Alerts

Alerts help you highlight important information in your documentation.

> [!NOTE]
> This is a note alert. Use it to provide helpful information that users should be aware of.

> [!TIP]
> This is a tip alert. Use it to share helpful advice or best practices.

> [!IMPORTANT]
> This is an important alert. Use it to highlight critical information that users must know.

> [!WARNING]
> This is a warning alert. Use it to warn users about potential issues or risks.

> [!CAUTION]
> This is a caution alert. Use it to warn about dangerous actions that could cause data loss.

## Usage

Simply use the following syntax:

```markdown
> [!NOTE]
> Your note content here

> [!TIP]
> Your tip content here

> [!IMPORTANT]
> Your important message here

> [!WARNING]
> Your warning message here

> [!CAUTION]
> Your caution message here
```
''';

const _tablesMarkdown = '''
# Enhanced Tables

Tables now feature **hover effects**, **zebra striping**, and **responsive design**!

## Basic Table

| Feature | Status | Description |
|---------|--------|-------------|
| Syntax Highlighting | ✅ | 8 beautiful themes |
| Copy Button | ✅ | One-click copying |
| Line Numbers | ✅ | Optional display |
| GitHub Alerts | ✅ | 5 alert types |
| LaTeX Math | ✅ | Full support |

## Alignment Example

| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:--------------:|--------------:|
| Left | Center | Right |
| Text | Text | Text |
| 123 | 456 | 789 |

## Complex Table

| Language | Paradigm | Typing | Use Case |
|----------|----------|--------|----------|
| Python | Multi-paradigm | Dynamic | Data Science, Web |
| JavaScript | Multi-paradigm | Dynamic | Web Development |
| Dart | Object-oriented | Static | Flutter Apps |
| Rust | Multi-paradigm | Static | Systems Programming |
| Go | Procedural | Static | Backend Services |

Try hovering over the rows to see the effect!
''';

const _mathMarkdown = r'''
# LaTeX Math Support

Full LaTeX math rendering with inline and display modes!

## Inline Math

The quadratic formula is \( x = \frac{-b \pm \sqrt{b^2-4ac}}{2a} \).

Einstein's famous equation: \( E = mc^2 \)

## Display Math

The integral of a Gaussian function:

\[
\int_{-\infty}^{\infty} e^{-x^2} \, dx = \sqrt{\pi}
\]

Maxwell's equations:

\[
\begin{aligned}
\nabla \cdot \mathbf{E} &= \frac{\rho}{\epsilon_0} \\
\nabla \cdot \mathbf{B} &= 0 \\
\nabla \times \mathbf{E} &= -\frac{\partial \mathbf{B}}{\partial t} \\
\nabla \times \mathbf{B} &= \mu_0\mathbf{J} + \mu_0\epsilon_0\frac{\partial \mathbf{E}}{\partial t}
\end{aligned}
\]

## Matrix Example

\[
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}
\]

## Summation

\[
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
\]
''';

const _advancedMarkdown = '''
# Advanced Features

## Collapsible Sections

<details>
<summary>Click to expand: What is Flutter?</summary>

Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.

**Key Features:**
- Fast development with hot reload
- Expressive and flexible UI
- Native performance
- Cross-platform

</details>

<details>
<summary>Click to expand: Code Example</summary>

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('Hello')),
        body: Center(child: Text('World')),
      ),
    );
  }
}
```

</details>

## Task Lists

- [x] Implement syntax highlighting
- [x] Add copy button to code blocks
- [x] Create GitHub-style alerts
- [x] Enhance table styling
- [ ] Add mermaid diagram support
- [ ] Create web playground

## Mixed Content

> [!TIP]
> You can combine different markdown elements!

Here's a table with code:

| Language | Hello World |
|----------|-------------|
| Python | `print("Hello, World!")` |
| JavaScript | `console.log("Hello, World!")` |
| Dart | `print('Hello, World!');` |

And some math: \( f(x) = x^2 + 2x + 1 \)

## Links and Images

- [GPT Markdown on pub.dev](https://pub.dev/packages/gpt_markdown)
- [GitHub Repository](https://github.com/Infinitix-LLC/gpt_markdown)

---

**Made with ❤️ using GPT Markdown**
''';
