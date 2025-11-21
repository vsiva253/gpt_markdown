import 'package:flutter/material.dart';

/// Premium typography processor for markdown
/// Converts plain text to beautiful typography with smart quotes, em dashes, etc.
class PremiumTypography {
  /// Apply premium typography transformations
  static String enhance(String text) {
    String result = text;

    // Smart quotes
    result = _applySmartQuotes(result);

    // Em dashes and en dashes
    result = _applyDashes(result);

    // Ellipsis
    result = _applyEllipsis(result);

    // Fractions
    result = _applyFractions(result);

    // Arrows
    result = _applyArrows(result);

    // Multiplication and division
    result = _applyMathSymbols(result);

    return result;
  }

  /// Convert straight quotes to smart quotes
  static String _applySmartQuotes(String text) {
    // Double quotes
    text = text.replaceAllMapped(
      RegExp(r'"([^"]+)"'),
      (match) => '"${match[1]}"', // " and "
    );

    // Single quotes (apostrophes and quotes)
    text = text.replaceAllMapped(
      RegExp(r"'([^']+)'"),
      (match) => '\u2018${match[1]}\u2019', // ' and '
    );

    // Apostrophes in contractions
    text = text.replaceAll(RegExp(r"(\w)'(\w)"), r"$1'$2");

    return text;
  }

  /// Convert double/triple hyphens to em/en dashes
  static String _applyDashes(String text) {
    // Em dash (—) for ---
    text = text.replaceAll('---', '—');

    // En dash (–) for --
    text = text.replaceAll('--', '–');

    return text;
  }

  /// Convert ... to ellipsis
  static String _applyEllipsis(String text) {
    return text.replaceAll('...', '…');
  }

  /// Convert common fractions to Unicode
  static String _applyFractions(String text) {
    final fractions = {
      '1/2': '½',
      '1/3': '⅓',
      '2/3': '⅔',
      '1/4': '¼',
      '3/4': '¾',
      '1/5': '⅕',
      '2/5': '⅖',
      '3/5': '⅗',
      '4/5': '⅘',
      '1/6': '⅙',
      '5/6': '⅚',
      '1/8': '⅛',
      '3/8': '⅜',
      '5/8': '⅝',
      '7/8': '⅞',
    };

    fractions.forEach((key, value) {
      text = text.replaceAll(key, value);
    });

    return text;
  }

  /// Convert arrow sequences to Unicode arrows
  static String _applyArrows(String text) {
    final arrows = {
      '->': '→',
      '<-': '←',
      '<->': '↔',
      '=>': '⇒',
      '<=': '⇐',
      '<=>': '⇔',
      '^': '↑',
      'v': '↓',
    };

    arrows.forEach((key, value) {
      // Only replace if surrounded by spaces or at start/end
      text = text.replaceAllMapped(
        RegExp('(^|\\s)${RegExp.escape(key)}(\\s|\$)'),
        (match) => '${match[1]}$value${match[2]}',
      );
    });

    return text;
  }

  /// Convert x to × and / to ÷ in math contexts
  static String _applyMathSymbols(String text) {
    // Multiplication: 2 x 3 -> 2 × 3
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*x\s*(\d+)'),
      (match) => '${match[1]} × ${match[2]}',
    );

    // Division: 10 / 2 -> 10 ÷ 2
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*/\s*(\d+)'),
      (match) => '${match[1]} ÷ ${match[2]}',
    );

    return text;
  }
}

/// Premium text widget with enhanced typography
class PremiumText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool enableTypography;

  const PremiumText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.enableTypography = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayText =
        enableTypography ? PremiumTypography.enhance(text) : text;

    return Text(
      displayText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Premium selectable text with enhanced typography
class PremiumSelectableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool enableTypography;

  const PremiumSelectableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.enableTypography = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayText =
        enableTypography ? PremiumTypography.enhance(text) : text;

    return SelectableText(
      displayText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
