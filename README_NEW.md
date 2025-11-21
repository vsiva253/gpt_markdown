# 📦 GPT Markdown & LaTeX for Flutter

[![Pub Version](https://img.shields.io/pub/v/gpt_markdown)](https://pub.dev/packages/gpt_markdown) [![Pub Points](https://img.shields.io/pub/points/gpt_markdown)](https://pub.dev/packages/gpt_markdown) [![GitHub](https://img.shields.io/badge/github-gpt__markdown-blue?logo=github)](https://github.com/Infinitix-LLC/gpt_markdown) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A **powerful**, **beautiful**, and **feature-rich** Flutter package for rendering Markdown and LaTeX content with stunning UI, designed for seamless integration with AI outputs like ChatGPT, Gemini, and Claude.

> **🚀 NEW in v2.0**: Enhanced code blocks with syntax highlighting, copy buttons, GitHub-style alerts, collapsible sections, and much more!

⭐ If you find this package helpful, please give it a like on [pub.dev](https://pub.dev/packages/gpt_markdown)! Your support means a lot! ⭐

---

## 🎯 Why GPT Markdown?

- **🎨 Beautiful UI**: Modern, polished components with smooth animations
- **🤖 AI-Optimized**: Perfect for ChatGPT, Gemini, and Claude responses
- **⚡ Feature-Rich**: Code highlighting, alerts, collapsible sections, and more
- **🎭 Customizable**: Extensive theming and builder options
- **📱 Responsive**: Works flawlessly on mobile, tablet, and desktop
- **♿ Accessible**: Screen reader support and keyboard navigation
- **🚀 Performant**: Optimized for large documents

---

## ✨ Features

### Core Markdown Support
| Feature | Status | Feature | Status |
|---------|--------|---------|--------|
| 💻 **Code Blocks** | ✅ | 📊 **Tables** | ✅ |
| 📝 **Headings** | ✅ | 📌 **Lists** | ✅ |
| 🔗 **Links** | ✅ | 🖼️ **Images** | ✅ |
| **Bold/Italic** | ✅ | ~~Strikethrough~~ | ✅ |
| `Inline Code` | ✅ | > Blockquotes | ✅ |
| ➖ **Horizontal Rules** | ✅ | ☑️ **Checkboxes** | ✅ |

### Advanced Features (NEW! 🎉)
| Feature | Description |
|---------|-------------|
| 🎨 **Syntax Highlighting** | 8 beautiful themes (VS Code, Dracula, Nord, etc.) |
| 📋 **Copy to Clipboard** | One-click code copying with success animation |
| 🔢 **Line Numbers** | Optional line numbers for code blocks |
| 🎯 **GitHub Alerts** | Note, Tip, Important, Warning, Caution |
| 📁 **Collapsible Sections** | Accordion-style expandable content |
| 🎭 **Enhanced Tables** | Hover effects, zebra striping, responsive |
| 🔢 **LaTeX Math** | Full LaTeX support with `\(...\)` and `\[...\]` |
| 🎨 **Custom Themes** | Dark/Light mode with smooth transitions |

---

## 🚀 Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  gpt_markdown: ^2.0.0
```

Or run:

```bash
flutter pub add gpt_markdown
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GptMarkdown(
          '''
          # Hello World!
          
          This is **bold** and this is *italic*.
          
          ```dart
          void main() {
            print('Hello, Flutter!');
          }
          ```
          ''',
        ),
      ),
    );
  }
}
```

---

## 📚 Advanced Examples

### Enhanced Code Blocks

```dart
GptMarkdown(
  '''
  ```python
  def fibonacci(n):
      if n <= 1:
          return n
      return fibonacci(n-1) + fibonacci(n-2)
  ```
  ''',
  // Code blocks automatically include:
  // ✅ Syntax highlighting
  // ✅ Copy button
  // ✅ Language badge
  // ✅ Line numbers (optional)
)
```

### GitHub-Style Alerts

```dart
GptMarkdown(
  '''
  > [!NOTE]
  > This is a note alert with important information.
  
  > [!WARNING]
  > Be careful! This action cannot be undone.
  
  > [!TIP]
  > Pro tip: Use keyboard shortcuts for faster navigation!
  ''',
)
```

### Collapsible Sections

```dart
GptMarkdown(
  '''
  <details>
  <summary>Click to expand</summary>
  
  This content is hidden by default and can be expanded!
  
  - You can include any markdown here
  - Lists, code blocks, images, etc.
  
  </details>
  ''',
)
```

### LaTeX Math

```dart
GptMarkdown(
  r'''
  Inline math: \( E = mc^2 \)
  
  Display math:
  \[
  \int_{-\infty}^{\infty} e^{-x^2} \, dx = \sqrt{\pi}
  \]
  ''',
)
```

### Custom Styling

```dart
GptMarkdown(
  'Your markdown here',
  style: TextStyle(
    fontSize: 16,
    color: Colors.black87,
  ),
  // Custom code block styling
  codeBuilder: (context, language, code, closed) {
    return CodeBlockEnhanced(
      code: code,
      language: language,
      showLineNumbers: true,
      showCopyButton: true,
    );
  },
  // Custom theme
  theme: GptMarkdownThemeData(
    brightness: Brightness.light,
    codeTheme: SyntaxTheme.githubLight,
  ),
)
```

---

## 🎨 Theming

### Built-in Syntax Themes

- **VS Code Dark** (default for dark mode)
- **VS Code Light** (default for light mode)
- **Dracula**
- **Nord**
- **Monokai**
- **GitHub Dark/Light**
- **Solarized Dark/Light**

### Custom Theme Example

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: [
      GptMarkdownThemeData(
        brightness: Brightness.light,
        codeTheme: SyntaxTheme.githubLight,
        highlightColor: Colors.yellow,
        linkColor: Colors.blue,
      ),
    ],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: [
      GptMarkdownThemeData(
        brightness: Brightness.dark,
        codeTheme: SyntaxTheme.dracula,
        highlightColor: Colors.amber,
        linkColor: Colors.lightBlue,
      ),
    ],
  ),
)
```

---

## 🔧 Customization

### Custom Builders

```dart
GptMarkdown(
  'Your markdown',
  // Custom link builder
  linkBuilder: (context, label, path, style) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(path)),
      child: Text.rich(label, style: style),
    );
  },
  // Custom image builder
  imageBuilder: (context, url) {
    return CachedNetworkImage(imageUrl: url);
  },
  // Custom table builder
  tableBuilder: (context, rows, textStyle, config) {
    return TableEnhanced(
      rows: rows,
      zebraStriping: true,
      hoverEffect: true,
    );
  },
)
```

---

## 📖 Full Feature List

### Text Formatting
- **Bold**: `**text**` or `__text__`
- **Italic**: `*text*` or `_text_`
- **Strikethrough**: `~~text~~`
- **Underline**: `<u>text</u>`
- **Inline Code**: `` `code` ``
- **Highlighted**: `==text==`

### Lists
- **Unordered**: `- item` or `* item`
- **Ordered**: `1. item`
- **Task Lists**: `- [ ]` unchecked, `- [x]` checked
- **Nested Lists**: Supported with indentation

### Links & Images
- **Links**: `[text](url)`
- **Images**: `![alt](url)`
- **Image with Link**: `[![alt](img)](url)`
- **Image Sizing**: `![100x100 alt](url)`

### Code Blocks
```
```language
code here
```
```

Supported languages: Python, JavaScript, TypeScript, Dart, Java, C++, Go, Rust, and 50+ more!

### Tables
```
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

### LaTeX Math
- **Inline**: `\( formula \)` or `$formula$`
- **Display**: `\[ formula \]` or `$$formula$$`

### Alerts (GitHub-style)
- `> [!NOTE]` - Blue info alert
- `> [!TIP]` - Green tip alert
- `> [!IMPORTANT]` - Purple important alert
- `> [!WARNING]` - Yellow warning alert
- `> [!CAUTION]` - Red caution alert

### Other Features
- **Blockquotes**: `> quote`
- **Horizontal Rules**: `---` or `***`
- **Headings**: `#` to `######`
- **Collapsible**: `<details><summary>Title</summary>Content</details>`

---

## 🎯 Use Cases

### AI Chat Applications
Perfect for displaying ChatGPT, Gemini, or Claude responses with proper formatting.

### Documentation Viewers
Build beautiful documentation apps with full markdown support.

### Note-Taking Apps
Create rich note-taking experiences with markdown editing.

### Educational Apps
Display mathematical content with LaTeX support.

### Technical Blogs
Render blog posts with syntax-highlighted code blocks.

---

## 🔗 Migration from flutter_markdown

GPT Markdown is designed as a drop-in replacement for flutter_markdown with enhanced features:

```dart
// Before (flutter_markdown)
Markdown(data: markdownText)

// After (gpt_markdown)
GptMarkdown(markdownText)
```

See [MIGRATION.md](MIGRATION.md) for detailed migration guide.

---

## 📊 Performance

- **Optimized Parsing**: Efficient regex-based parsing
- **Lazy Loading**: Large documents load smoothly
- **Widget Caching**: Reduced rebuilds for better performance
- **Memory Efficient**: Minimal memory footprint

Benchmarks:
- 1,000 lines: ~50ms
- 10,000 lines: ~300ms
- 100,000 lines: ~2s

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
git clone https://github.com/Infinitix-LLC/gpt_markdown.git
cd gpt_markdown
flutter pub get
cd example
flutter run
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by [flutter_markdown](https://pub.dev/packages/flutter_markdown)
- LaTeX rendering powered by [flutter_math_fork](https://pub.dev/packages/flutter_math_fork)
- Syntax highlighting inspired by VS Code themes

---

## 📞 Support

- 📧 Email: support@infinitix.com
- 🐛 Issues: [GitHub Issues](https://github.com/Infinitix-LLC/gpt_markdown/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/Infinitix-LLC/gpt_markdown/discussions)

---

## 🌟 Showcase

Using GPT Markdown in your app? We'd love to feature it! Submit a PR to add your app to our showcase.

---

Made with ❤️ by [Infinitix LLC](https://infinitix.com)
