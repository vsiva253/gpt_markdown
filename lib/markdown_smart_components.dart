part of 'gpt_markdown.dart';

WidgetSpan _inlineLatexBuilder(
  BuildContext context,
  String latex,
  TextStyle textStyle,
  GptMarkdownConfig config,
) {
  String mathText = latex;
  var workaround = config.latexWorkaround ?? (String tex) => tex;
  var builder =
      config.latexBuilder ??
      (
        BuildContext context,
        String tex,
        TextStyle textStyle,
        bool inline,
      ) => SelectableAdapter(
        selectedText: tex,
        child: Math.tex(
          tex,
          textStyle: textStyle,
          mathStyle: MathStyle.display,
          textScaleFactor: 1,
          settings: const TexParserSettings(strict: Strict.ignore),
          options: MathOptions(
            sizeUnderTextStyle: MathSize.large,
            color:
                config.style?.color ?? Theme.of(context).colorScheme.onSurface,
            fontSize:
                config.style?.fontSize ??
                Theme.of(context).textTheme.bodyMedium?.fontSize,
            mathFontOptions: FontOptions(
              fontFamily: "Main",
              fontWeight: config.style?.fontWeight ?? FontWeight.normal,
              fontShape: FontStyle.normal,
            ),
            textFontOptions: FontOptions(
              fontFamily: "Main",
              fontWeight: config.style?.fontWeight ?? FontWeight.normal,
              fontShape: FontStyle.normal,
            ),
            style: MathStyle.display,
          ),
          onErrorFallback: (err) {
            return Text(
              workaround(mathText),
              textDirection: config.textDirection,
              style: textStyle.copyWith(
                color:
                    (!kDebugMode) ? null : Theme.of(context).colorScheme.error,
              ),
            );
          },
        ),
      );
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: builder(
      context,
      workaround(mathText),
      config.style ?? const TextStyle(),
      true,
    ),
  );
}

InlineSpan _highlightBuilder(
  BuildContext context,
  String text,
  TextStyle textStyle,
  GptMarkdownConfig config,
) {
  var highlightedText = text;

  if (config.highlightBuilder != null) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: config.highlightBuilder!(
        context,
        highlightedText,
        config.style ?? const TextStyle(),
      ),
    );
  }

  var style =
      config.style?.copyWith(
        fontWeight: FontWeight.bold,
        background:
            Paint()
              ..color = GptMarkdownTheme.of(context).highlightColor
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round,
      ) ??
      TextStyle(
        fontWeight: FontWeight.bold,
        background:
            Paint()
              ..color = GptMarkdownTheme.of(context).highlightColor
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round,
      );

  return TextSpan(text: highlightedText, style: style);
}

WidgetSpan _blockLatexBuilder(
  BuildContext context,
  String latex,
  TextStyle textStyle,
  GptMarkdownConfig config,
) {
  String mathText = latex;
  var workaround = config.latexWorkaround ?? (String tex) => tex;

  var builder =
      config.latexBuilder ??
      (
        BuildContext context,
        String tex,
        TextStyle textStyle,
        bool inline,
      ) => SelectableAdapter(
        selectedText: tex,
        child: Math.tex(
          tex,
          textStyle: textStyle,
          mathStyle: MathStyle.display,
          textScaleFactor: 1,
          settings: const TexParserSettings(strict: Strict.ignore),
          options: MathOptions(
            sizeUnderTextStyle: MathSize.large,
            color:
                config.style?.color ?? Theme.of(context).colorScheme.onSurface,
            fontSize:
                config.style?.fontSize ??
                Theme.of(context).textTheme.bodyMedium?.fontSize,
            mathFontOptions: FontOptions(
              fontFamily: "Main",
              fontWeight: config.style?.fontWeight ?? FontWeight.normal,
              fontShape: FontStyle.normal,
            ),
            textFontOptions: FontOptions(
              fontFamily: "Main",
              fontWeight: config.style?.fontWeight ?? FontWeight.normal,
              fontShape: FontStyle.normal,
            ),
            style: MathStyle.display,
          ),
          onErrorFallback: (err) {
            return Text(
              workaround(mathText),
              textDirection: config.textDirection,
              style: textStyle.copyWith(
                color:
                    (!kDebugMode) ? null : Theme.of(context).colorScheme.error,
              ),
            );
          },
        ),
      );
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: builder(
      context,
      workaround(mathText),
      config.style ?? const TextStyle(),
      false,
    ),
  );
}

List<InlineSpan> generateLight(
  BuildContext context,
  String text,
  final GptMarkdownConfig config,
  bool includeGlobalComponents,
) {
  List<InlineSpan> spans = [];

  if (text.isEmpty) return spans;

  // Fast native parser - no regex, pure string operations
  int i = 0;
  while (i < text.length) {
    // Check for bold **text**
    if (i + 1 < text.length && text[i] == '*' && text[i + 1] == '*') {
      final boldEnd = _findClosing(text, i + 2, '**');
      if (boldEnd != -1) {
        final content = text.substring(i + 2, boldEnd);
        spans.add(
          TextSpan(
            text: content,
            style: (config.style ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        i = boldEnd + 2;
        continue;
      }
    }

    // Check for italic *text*
    if (text[i] == '*' && (i == 0 || text[i - 1] != '*')) {
      final italicEnd = _findClosing(text, i + 1, '*');
      if (italicEnd != -1 && italicEnd > i + 1) {
        final content = text.substring(i + 1, italicEnd);
        spans.add(
          TextSpan(
            text: content,
            style: (config.style ?? const TextStyle()).copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        i = italicEnd + 1;
        continue;
      }
    }

    // Check for code `text`
    if (text[i] == '`') {
      final codeEnd = _findClosing(text, i + 1, '`');
      if (codeEnd != -1) {
        final content = text.substring(i + 1, codeEnd);
        spans.add(
          _highlightBuilder(
            context,
            content,
            config.style ?? const TextStyle(),
            config,
          ),
        );
        i = codeEnd + 1;
        continue;
      }
    }

    // Check for links [text](url)
    if (text[i] == '[') {
      final linkEnd = _findClosing(text, i + 1, ']');
      if (linkEnd != -1 &&
          linkEnd + 1 < text.length &&
          text[linkEnd + 1] == '(') {
        final linkText = text.substring(i + 1, linkEnd);
        final urlStart = linkEnd + 2;
        final urlEnd = _findClosing(text, urlStart, ')');
        if (urlEnd != -1) {
          final url = text.substring(urlStart, urlEnd);
          spans.add(
            WidgetSpan(
              child: GestureDetector(
                onTap: () => config.onLinkTap?.call(url, linkText),
                child: Text(
                  linkText,
                  style: (config.style ?? const TextStyle()).copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
          i = urlEnd + 1;
          continue;
        }
      }
    }

    // Check for images ![alt](url)
    if (i + 1 < text.length && text[i] == '!' && text[i + 1] == '[') {
      final altEnd = _findClosing(text, i + 2, ']');
      if (altEnd != -1 && altEnd + 1 < text.length && text[altEnd + 1] == '(') {
        final altText = text.substring(i + 2, altEnd);
        final urlStart = altEnd + 2;
        final urlEnd = _findClosing(text, urlStart, ')');
        if (urlEnd != -1) {
          final url = text.substring(urlStart, urlEnd);
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Image.network(
                url,
                errorBuilder:
                    (context, error, stackTrace) => Text(
                      altText.isNotEmpty ? altText : 'Image',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
              ),
            ),
          );
          i = urlEnd + 1;
          continue;
        }
      }
    }

    // Check for strikethrough ~~text~~
    if (i + 1 < text.length && text[i] == '~' && text[i + 1] == '~') {
      final strikeEnd = _findClosing(text, i + 2, '~~');
      if (strikeEnd != -1) {
        final content = text.substring(i + 2, strikeEnd);
        spans.add(
          TextSpan(
            text: content,
            style: (config.style ?? const TextStyle()).copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
        );
        i = strikeEnd + 2;
        continue;
      }
    }

    // Check for headers # ## ### etc
    if (text[i] == '#') {
      int headerLevel = 0;
      int j = i;
      while (j < text.length && text[j] == '#') {
        headerLevel++;
        j++;
      }
      if (headerLevel <= 6 && j < text.length && text[j] == ' ') {
        final contentStart = j + 1;
        final contentEnd = _findLineEnd(text, contentStart);
        final content = text.substring(contentStart, contentEnd);

        final theme = GptMarkdownTheme.of(context);
        final headerStyle =
            [
              theme.h1,
              theme.h2,
              theme.h3,
              theme.h4,
              theme.h5,
              theme.h6,
            ][headerLevel - 1];

        spans.add(TextSpan(text: content, style: headerStyle));
        i = contentEnd;
        continue;
      }
    }

    // Check for unordered lists - item
    if (text[i] == '-' || text[i] == '*') {
      if (i + 1 < text.length && text[i + 1] == ' ') {
        final contentStart = i + 2;
        final contentEnd = _findLineEnd(text, contentStart);
        final content = text.substring(contentStart, contentEnd);

        spans.add(
          WidgetSpan(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: config.style),
                Expanded(child: Text(content, style: config.style)),
              ],
            ),
          ),
        );
        i = contentEnd;
        continue;
      }
    }

    // Check for ordered lists 1. item
    if (_isDigit(text[i])) {
      int j = i;
      while (j < text.length && _isDigit(text[j])) {
        j++;
      }
      if (j < text.length &&
          text[j] == '.' &&
          j + 1 < text.length &&
          text[j + 1] == ' ') {
        final number = text.substring(i, j);
        final contentStart = j + 2;
        final contentEnd = _findLineEnd(text, contentStart);
        final content = text.substring(contentStart, contentEnd);

        spans.add(
          WidgetSpan(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number. ', style: config.style),
                Expanded(child: Text(content, style: config.style)),
              ],
            ),
          ),
        );
        i = contentEnd;
        continue;
      }
    }

    // Check for code blocks ```code```
    if (i + 2 < text.length &&
        text[i] == '`' &&
        text[i + 1] == '`' &&
        text[i + 2] == '`') {
      final codeStart = i + 3;
      final codeEnd = _findClosing(text, codeStart, '```');
      if (codeEnd != -1) {
        final code = text.substring(codeStart, codeEnd);
        spans.add(
          WidgetSpan(
            child:
                config.codeBuilder?.call(context, "", code, true) ??
                CodeField(name: "", codes: code),
          ),
        );
        i = codeEnd + 3;
        continue;
      }
    }

    // Check for inline LaTeX \(latex\)
    if (i + 1 < text.length && text[i] == '\\' && text[i + 1] == '(') {
      final latexEnd = _findClosing(text, i + 2, '\\)');
      if (latexEnd != -1) {
        final latex = text.substring(i + 2, latexEnd);
        spans.add(
          _inlineLatexBuilder(
            context,
            latex,
            config.style ?? const TextStyle(),
            config,
          ),
        );
        i = latexEnd + 2;
        continue;
      }
    }

    // Check for block LaTeX \[latex\]
    if (i + 1 < text.length && text[i] == '\\' && text[i + 1] == '[') {
      final latexEnd = _findClosing(text, i + 2, '\\]');
      if (latexEnd != -1) {
        final latex = text.substring(i + 2, latexEnd);
        spans.add(
          _blockLatexBuilder(
            context,
            latex,
            config.style ?? const TextStyle(),
            config,
          ),
        );
        i = latexEnd + 2;
        continue;
      }
    }

    // Regular text
    spans.add(TextSpan(text: text[i], style: config.style));
    i++;
  }

  return spans;
}

// Helper function to find closing pattern
int _findClosing(String text, int start, String pattern) {
  for (int i = start; i < text.length - pattern.length + 1; i++) {
    if (text.substring(i, i + pattern.length) == pattern) {
      return i;
    }
  }
  return -1;
}

// Helper function to find end of line
int _findLineEnd(String text, int start) {
  for (int i = start; i < text.length; i++) {
    if (text[i] == '\n') {
      return i;
    }
  }
  return text.length;
}

// Helper function to check if character is digit
bool _isDigit(String char) {
  return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
}
