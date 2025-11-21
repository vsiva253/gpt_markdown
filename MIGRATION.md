# Migration Guide: flutter_markdown → gpt_markdown

This guide will help you migrate from `flutter_markdown` to `gpt_markdown` and take advantage of the enhanced features.

## Why Migrate?

- ✅ **Enhanced Features**: Syntax highlighting, GitHub alerts, collapsible sections
- ✅ **Better Performance**: Optimized parsing and rendering
- ✅ **Modern UI**: Beautiful, polished components out of the box
- ✅ **LaTeX Support**: Built-in mathematical expression rendering
- ✅ **AI-Optimized**: Perfect for ChatGPT, Gemini, and Claude responses
- ✅ **Active Development**: Regular updates and new features

---

## Quick Migration

### Step 1: Update Dependencies

**Before** (`pubspec.yaml`):
```yaml
dependencies:
  flutter_markdown: ^0.6.18
```

**After** (`pubspec.yaml`):
```yaml
dependencies:
  gpt_markdown: ^2.0.0
```

Run:
```bash
flutter pub get
```

### Step 2: Update Imports

**Before**:
```dart
import 'package:flutter_markdown/flutter_markdown.dart';
```

**After**:
```dart
import 'package:gpt_markdown/gpt_markdown.dart';
```

### Step 3: Update Widget Usage

**Before**:
```dart
Markdown(
  data: markdownText,
  selectable: true,
)
```

**After**:
```dart
GptMarkdown(
  markdownText,
  // selectable is now handled by wrapping with SelectionArea
)

// Or for selectable text:
SelectionArea(
  child: GptMarkdown(markdownText),
)
```

---

## Detailed Migration

### Basic Usage

#### flutter_markdown
```dart
Markdown(
  data: '''
  # Hello World
  This is **bold** text.
  ''',
  styleSheet: MarkdownStyleSheet(
    h1: TextStyle(fontSize: 24),
    p: TextStyle(fontSize: 16),
  ),
)
```

#### gpt_markdown
```dart
GptMarkdown(
  '''
  # Hello World
  This is **bold** text.
  ''',
  style: TextStyle(fontSize: 16),
  // Heading styles are automatically handled by theme
)
```

---

### Custom Styling

#### flutter_markdown
```dart
Markdown(
  data: markdownText,
  styleSheet: MarkdownStyleSheet(
    h1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    h2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    p: TextStyle(fontSize: 16),
    code: TextStyle(fontFamily: 'monospace'),
    codeblockDecoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

#### gpt_markdown
```dart
// Use theme extensions for global styling
MaterialApp(
  theme: ThemeData(
    extensions: [
      GptMarkdownThemeData(
        brightness: Brightness.light,
        h1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        h2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        codeTheme: SyntaxTheme.vsLight,
      ),
    ],
  ),
  home: Scaffold(
    body: GptMarkdown(
      markdownText,
      style: TextStyle(fontSize: 16),
    ),
  ),
)
```

---

### Code Blocks

#### flutter_markdown
```dart
Markdown(
  data: markdownText,
  styleSheet: MarkdownStyleSheet(
    code: TextStyle(fontFamily: 'monospace'),
  ),
)
```

#### gpt_markdown
```dart
GptMarkdown(
  markdownText,
  // Code blocks now include:
  // - Syntax highlighting (automatic)
  // - Copy button (automatic)
  // - Language badge (automatic)
  // - Line numbers (optional)
  
  // Custom code builder (optional)
  codeBuilder: (context, language, code, closed) {
    return CodeBlockEnhanced(
      code: code,
      language: language,
      showLineNumbers: true,
      showCopyButton: true,
      showLanguageBadge: true,
    );
  },
)
```

---

### Links

#### flutter_markdown
```dart
Markdown(
  data: markdownText,
  onTapLink: (text, href, title) {
    launchUrl(Uri.parse(href!));
  },
)
```

#### gpt_markdown
```dart
GptMarkdown(
  markdownText,
  onLinkTap: (url, title) {
    launchUrl(Uri.parse(url));
  },
  
  // Or custom link builder
  linkBuilder: (context, label, path, style) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(path)),
      child: Text.rich(
        label,
        style: style.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  },
)
```

---

### Images

#### flutter_markdown
```dart
Markdown(
  data: markdownText,
  imageBuilder: (uri, title, alt) {
    return Image.network(uri.toString());
  },
)
```

#### gpt_markdown
```dart
GptMarkdown(
  markdownText,
  imageBuilder: (context, url) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  },
)
```

---

### Tables

#### flutter_markdown
```dart
Markdown(
  data: markdownText,
  // Basic table support
)
```

#### gpt_markdown
```dart
GptMarkdown(
  markdownText,
  // Enhanced tables with:
  // - Hover effects (automatic)
  // - Zebra striping (automatic)
  // - Responsive design (automatic)
  
  // Custom table builder (optional)
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

### LaTeX Math

#### flutter_markdown
```dart
// Not natively supported
// Requires additional packages and custom builders
```

#### gpt_markdown
```dart
GptMarkdown(
  r'''
  Inline math: \( E = mc^2 \)
  
  Display math:
  \[
  \int_{0}^{1} x^2 \, dx = \frac{1}{3}
  \]
  ''',
  // LaTeX is automatically rendered!
  
  // Optional: Use dollar signs
  useDollarSignsForLatex: true,
  // Now you can use $...$ and $$...$$
)
```

---

## New Features in gpt_markdown

### 1. GitHub-Style Alerts

```dart
GptMarkdown(
  '''
  > [!NOTE]
  > Useful information that users should know.
  
  > [!TIP]
  > Helpful advice for doing things better.
  
  > [!IMPORTANT]
  > Key information users need to know.
  
  > [!WARNING]
  > Urgent info that needs immediate attention.
  
  > [!CAUTION]
  > Advises about risks or negative outcomes.
  ''',
)
```

### 2. Collapsible Sections

```dart
GptMarkdown(
  '''
  <details>
  <summary>Click to expand</summary>
  
  Hidden content goes here!
  
  - Can include lists
  - Code blocks
  - Images
  - Anything!
  
  </details>
  ''',
)
```

### 3. Enhanced Syntax Highlighting

```dart
GptMarkdown(
  '''
  ```python
  def hello_world():
      print("Hello, World!")
  ```
  ''',
  // Automatic syntax highlighting with 8 themes:
  // - VS Code Dark/Light
  // - Dracula
  // - Nord
  // - Monokai
  // - GitHub Dark/Light
  // - Solarized Dark/Light
)
```

### 4. Copy to Clipboard

All code blocks automatically include a copy button with success animation!

### 5. Line Numbers

```dart
GptMarkdown(
  markdownText,
  codeBuilder: (context, language, code, closed) {
    return CodeBlockEnhanced(
      code: code,
      language: language,
      showLineNumbers: true, // Enable line numbers
    );
  },
)
```

---

## Feature Comparison

| Feature | flutter_markdown | gpt_markdown |
|---------|------------------|--------------|
| Basic Markdown | ✅ | ✅ |
| LaTeX Math | ❌ | ✅ |
| Syntax Highlighting | ❌ | ✅ (8 themes) |
| Copy Button | ❌ | ✅ |
| Line Numbers | ❌ | ✅ |
| GitHub Alerts | ❌ | ✅ |
| Collapsible Sections | ❌ | ✅ |
| Enhanced Tables | ❌ | ✅ |
| Custom Themes | Limited | Extensive |
| Performance | Good | Excellent |
| AI Integration | Basic | Optimized |

---

## Common Issues & Solutions

### Issue 1: Selectable Text

**flutter_markdown**:
```dart
Markdown(data: text, selectable: true)
```

**gpt_markdown**:
```dart
SelectionArea(
  child: GptMarkdown(text),
)
```

### Issue 2: Custom Fonts

**flutter_markdown**:
```dart
styleSheet: MarkdownStyleSheet(
  code: TextStyle(fontFamily: 'Courier'),
)
```

**gpt_markdown**:
```dart
GptMarkdown(
  text,
  style: TextStyle(fontFamily: 'Courier'),
)
```

### Issue 3: Dark Mode

**flutter_markdown**:
```dart
// Manual color configuration needed
```

**gpt_markdown**:
```dart
// Automatic dark mode support!
// Just use MaterialApp's theme/darkTheme
MaterialApp(
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
)
```

---

## Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilding** the entire markdown widget unnecessarily
3. **Cache parsed content** for static markdown
4. **Use ListView.builder** for very long documents

Example:
```dart
class MyMarkdownView extends StatelessWidget {
  final String markdown;
  
  const MyMarkdownView({required this.markdown});
  
  @override
  Widget build(BuildContext context) {
    return GptMarkdown(markdown); // Efficient!
  }
}
```

---

## Getting Help

- 📖 **Documentation**: [GitHub Wiki](https://github.com/Infinitix-LLC/gpt_markdown/wiki)
- 🐛 **Issues**: [GitHub Issues](https://github.com/Infinitix-LLC/gpt_markdown/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Infinitix-LLC/gpt_markdown/discussions)
- 📧 **Email**: support@infinitix.com

---

## Conclusion

Migrating from flutter_markdown to gpt_markdown is straightforward and brings significant benefits:

- ✅ **Better UI** with modern, polished components
- ✅ **More Features** like LaTeX, alerts, and syntax highlighting
- ✅ **Improved Performance** for large documents
- ✅ **Active Development** with regular updates

Happy coding! 🚀
