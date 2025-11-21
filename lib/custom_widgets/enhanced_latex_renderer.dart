import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Enhanced LaTeX renderer with horizontal scroll for long equations
/// Fixes the issue where long equations overflow the screen
class EnhancedLatexRenderer extends StatelessWidget {
  final String tex;
  final TextStyle textStyle;
  final bool isInline;
  final bool enableScroll;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Function(String)? latexWorkaround;

  const EnhancedLatexRenderer({
    super.key,
    required this.tex,
    required this.textStyle,
    this.isInline = false,
    this.enableScroll = true,
    this.backgroundColor,
    this.padding,
    this.latexWorkaround,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workaround = latexWorkaround ?? (String t) => t;
    final processedTex = workaround(tex);

    // Build the math widget
    Widget mathWidget = Math.tex(
      processedTex,
      textStyle: textStyle,
      mathStyle: isInline ? MathStyle.text : MathStyle.display,
      textScaleFactor: 1,
      settings: const TexParserSettings(strict: Strict.ignore),
      options: MathOptions(
        sizeUnderTextStyle: MathSize.large, // Use large for both inline and display to match default behavior
        color: textStyle.color ?? theme.colorScheme.onSurface,
        fontSize: textStyle.fontSize ?? theme.textTheme.bodyMedium?.fontSize,
        mathFontOptions: FontOptions(
          fontFamily: "Main",
          fontWeight: textStyle.fontWeight ?? FontWeight.normal,
          fontShape: FontStyle.normal,
        ),
        textFontOptions: FontOptions(
          fontFamily: "Main",
          fontWeight: textStyle.fontWeight ?? FontWeight.normal,
          fontShape: FontStyle.normal,
        ),
        style: isInline ? MathStyle.text : MathStyle.display,
      ),
      onErrorFallback: (err) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'LaTeX Error: ${err.messageWithType}',
                  style: textStyle.copyWith(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // For inline math, return as-is (no scroll needed)
    if (isInline) {
      return mathWidget;
    }

    // For display math, wrap in container with horizontal scroll
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Equation label
          Row(
            children: [
              Icon(Icons.functions, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Equation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scrollable equation
          if (enableScroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: mathWidget,
            )
          else
            mathWidget,

          // Scroll hint (if equation might be long)
          if (enableScroll && tex.length > 50)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.swipe,
                    size: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe to see full equation',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Builder function type for custom LaTeX rendering
typedef EnhancedLatexBuilder =
    Widget Function(
      BuildContext context,
      String tex,
      TextStyle textStyle,
      bool isInline,
    );

/// Default enhanced LaTeX builder with horizontal scroll
Widget defaultEnhancedLatexBuilder(
  BuildContext context,
  String tex,
  TextStyle textStyle,
  bool isInline,
) {
  return EnhancedLatexRenderer(
    tex: tex,
    textStyle: textStyle,
    isInline: isInline,
  );
}
