import 'package:flutter/material.dart';

/// Syntax highlighting themes
enum SyntaxTheme {
  vsDark,
  vsLight,
  dracula,
  nord,
  monokai,
  github,
  solarizedDark,
  solarizedLight,
}

/// Syntax highlighter for code blocks
class SyntaxHighlighter {
  final SyntaxTheme theme;
  final Brightness brightness;

  const SyntaxHighlighter({
    this.theme = SyntaxTheme.vsDark,
    this.brightness = Brightness.dark,
  });

  /// Get theme colors
  SyntaxThemeColors getThemeColors() {
    switch (theme) {
      case SyntaxTheme.vsDark:
        return _vsCodeDarkTheme;
      case SyntaxTheme.vsLight:
        return _vsCodeLightTheme;
      case SyntaxTheme.dracula:
        return _draculaTheme;
      case SyntaxTheme.nord:
        return _nordTheme;
      case SyntaxTheme.monokai:
        return _monokaiTheme;
      case SyntaxTheme.github:
        return brightness == Brightness.dark
            ? _githubDarkTheme
            : _githubLightTheme;
      case SyntaxTheme.solarizedDark:
        return _solarizedDarkTheme;
      case SyntaxTheme.solarizedLight:
        return _solarizedLightTheme;
    }
  }

  /// Highlight code based on language
  TextSpan highlight(String code, String? language) {
    final colors = getThemeColors();

    // For now, return basic highlighting
    // In a full implementation, you'd use a proper syntax parser
    return TextSpan(
      text: code,
      style: TextStyle(
        color: colors.text,
        fontFamily: 'JetBrainsMono',
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  /// Apply basic regex-based highlighting for common patterns
  List<TextSpan> highlightWithPatterns(String code, String? language) {
    final colors = getThemeColors();
    final spans = <TextSpan>[];

    // Keywords pattern (common across languages)
    final keywordPattern = RegExp(
      r'\b(if|else|for|while|return|function|class|const|let|var|def|import|from|as|try|catch|finally|throw|new|this|super|extends|implements|interface|enum|public|private|protected|static|async|await|yield|break|continue|switch|case|default|do|in|of|with|package|void|int|double|String|bool|List|Map|Set)\b',
    );

    // String pattern
    final stringPattern = RegExp(r'''(['"`])(?:(?!\1).)*\1''');

    // Comment pattern
    final commentPattern = RegExp(
      r'//.*$|/\*[\s\S]*?\*/|#.*$',
      multiLine: true,
    );

    // Number pattern
    final numberPattern = RegExp(r'\b\d+\.?\d*\b');

    // Function call pattern
    final functionPattern = RegExp(r'\b\w+(?=\()');

    var lastEnd = 0;
    final matches = <_Match>[];

    // Collect all matches
    for (final match in commentPattern.allMatches(code)) {
      matches.add(_Match(match.start, match.end, colors.comment, 'comment'));
    }
    for (final match in stringPattern.allMatches(code)) {
      matches.add(_Match(match.start, match.end, colors.string, 'string'));
    }
    for (final match in keywordPattern.allMatches(code)) {
      matches.add(_Match(match.start, match.end, colors.keyword, 'keyword'));
    }
    for (final match in numberPattern.allMatches(code)) {
      matches.add(_Match(match.start, match.end, colors.number, 'number'));
    }
    for (final match in functionPattern.allMatches(code)) {
      matches.add(_Match(match.start, match.end, colors.function, 'function'));
    }

    // Sort by position and priority
    matches.sort((a, b) {
      if (a.start != b.start) return a.start.compareTo(b.start);
      // Comments and strings have higher priority
      if (a.type == 'comment' || a.type == 'string') return -1;
      if (b.type == 'comment' || b.type == 'string') return 1;
      return 0;
    });

    // Build spans, avoiding overlaps
    for (final match in matches) {
      if (match.start < lastEnd) continue; // Skip overlapping matches

      // Add plain text before this match
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: code.substring(lastEnd, match.start),
            style: TextStyle(color: colors.text),
          ),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: code.substring(match.start, match.end),
          style: TextStyle(color: match.color),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining plain text
    if (lastEnd < code.length) {
      spans.add(
        TextSpan(
          text: code.substring(lastEnd),
          style: TextStyle(color: colors.text),
        ),
      );
    }

    return spans.isEmpty
        ? [TextSpan(text: code, style: TextStyle(color: colors.text))]
        : spans;
  }
}

class _Match {
  final int start;
  final int end;
  final Color color;
  final String type;

  _Match(this.start, this.end, this.color, this.type);
}

/// Theme colors for syntax highlighting
class SyntaxThemeColors {
  final Color background;
  final Color text;
  final Color keyword;
  final Color string;
  final Color comment;
  final Color number;
  final Color function;
  final Color className;
  final Color operator;
  final Color variable;

  const SyntaxThemeColors({
    required this.background,
    required this.text,
    required this.keyword,
    required this.string,
    required this.comment,
    required this.number,
    required this.function,
    required this.className,
    required this.operator,
    required this.variable,
  });
}

// VS Code Dark Theme
const _vsCodeDarkTheme = SyntaxThemeColors(
  background: Color(0xFF1E1E1E),
  text: Color(0xFFD4D4D4),
  keyword: Color(0xFF569CD6),
  string: Color(0xFFCE9178),
  comment: Color(0xFF6A9955),
  number: Color(0xFFB5CEA8),
  function: Color(0xFFDCDCAA),
  className: Color(0xFF4EC9B0),
  operator: Color(0xFFD4D4D4),
  variable: Color(0xFF9CDCFE),
);

// VS Code Light Theme
const _vsCodeLightTheme = SyntaxThemeColors(
  background: Color(0xFFFFFFFF),
  text: Color(0xFF000000),
  keyword: Color(0xFF0000FF),
  string: Color(0xFFA31515),
  comment: Color(0xFF008000),
  number: Color(0xFF098658),
  function: Color(0xFF795E26),
  className: Color(0xFF267F99),
  operator: Color(0xFF000000),
  variable: Color(0xFF001080),
);

// Dracula Theme
const _draculaTheme = SyntaxThemeColors(
  background: Color(0xFF282A36),
  text: Color(0xFFF8F8F2),
  keyword: Color(0xFFFF79C6),
  string: Color(0xFFF1FA8C),
  comment: Color(0xFF6272A4),
  number: Color(0xFFBD93F9),
  function: Color(0xFF50FA7B),
  className: Color(0xFF8BE9FD),
  operator: Color(0xFFFF79C6),
  variable: Color(0xFFF8F8F2),
);

// Nord Theme
const _nordTheme = SyntaxThemeColors(
  background: Color(0xFF2E3440),
  text: Color(0xFFD8DEE9),
  keyword: Color(0xFF81A1C1),
  string: Color(0xFFA3BE8C),
  comment: Color(0xFF616E88),
  number: Color(0xFFB48EAD),
  function: Color(0xFF88C0D0),
  className: Color(0xFF8FBCBB),
  operator: Color(0xFF81A1C1),
  variable: Color(0xFFD8DEE9),
);

// Monokai Theme
const _monokaiTheme = SyntaxThemeColors(
  background: Color(0xFF272822),
  text: Color(0xFFF8F8F2),
  keyword: Color(0xFFF92672),
  string: Color(0xFFE6DB74),
  comment: Color(0xFF75715E),
  number: Color(0xFFAE81FF),
  function: Color(0xFFA6E22E),
  className: Color(0xFF66D9EF),
  operator: Color(0xFFF92672),
  variable: Color(0xFFF8F8F2),
);

// GitHub Dark Theme
const _githubDarkTheme = SyntaxThemeColors(
  background: Color(0xFF0D1117),
  text: Color(0xFFC9D1D9),
  keyword: Color(0xFFFF7B72),
  string: Color(0xFFA5D6FF),
  comment: Color(0xFF8B949E),
  number: Color(0xFF79C0FF),
  function: Color(0xFFD2A8FF),
  className: Color(0xFFFFA657),
  operator: Color(0xFFFF7B72),
  variable: Color(0xFFC9D1D9),
);

// GitHub Light Theme
const _githubLightTheme = SyntaxThemeColors(
  background: Color(0xFFFFFFFF),
  text: Color(0xFF24292F),
  keyword: Color(0xFFCF222E),
  string: Color(0xFF0A3069),
  comment: Color(0xFF6E7781),
  number: Color(0xFF0550AE),
  function: Color(0xFF8250DF),
  className: Color(0xFF953800),
  operator: Color(0xFFCF222E),
  variable: Color(0xFF24292F),
);

// Solarized Dark Theme
const _solarizedDarkTheme = SyntaxThemeColors(
  background: Color(0xFF002B36),
  text: Color(0xFF839496),
  keyword: Color(0xFF859900),
  string: Color(0xFF2AA198),
  comment: Color(0xFF586E75),
  number: Color(0xFFD33682),
  function: Color(0xFF268BD2),
  className: Color(0xFFB58900),
  operator: Color(0xFF859900),
  variable: Color(0xFF839496),
);

// Solarized Light Theme
const _solarizedLightTheme = SyntaxThemeColors(
  background: Color(0xFFFDF6E3),
  text: Color(0xFF657B83),
  keyword: Color(0xFF859900),
  string: Color(0xFF2AA198),
  comment: Color(0xFF93A1A1),
  number: Color(0xFFD33682),
  function: Color(0xFF268BD2),
  className: Color(0xFFB58900),
  operator: Color(0xFF859900),
  variable: Color(0xFF657B83),
);
