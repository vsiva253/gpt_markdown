import 'package:flutter/material.dart';

/// Enhanced blockquote with better styling and visual hierarchy
class EnhancedBlockquote extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final IconData? icon;
  final double borderWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const EnhancedBlockquote({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.icon,
    this.borderWidth = 4,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor =
        borderColor ?? theme.colorScheme.primary.withOpacity(0.25); // Reduced from 0.5 to 0.25
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.15); // Reduced from 0.3 to 0.15

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: effectiveBorderColor, width: borderWidth),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: effectiveBorderColor),
            const SizedBox(width: 12),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Enhanced ordered list with better numbering styles
class EnhancedOrderedList extends StatelessWidget {
  final List<Widget> items;
  final OrderedListStyle style;
  final Color? numberColor;
  final double indent;

  const EnhancedOrderedList({
    super.key,
    required this.items,
    this.style = OrderedListStyle.decimal,
    this.numberColor,
    this.indent = 24,
  });

  String _getNumberPrefix(int index) {
    switch (style) {
      case OrderedListStyle.decimal:
        return '${index + 1}.';
      case OrderedListStyle.lowerAlpha:
        return '${String.fromCharCode(97 + (index % 26))}.';
      case OrderedListStyle.upperAlpha:
        return '${String.fromCharCode(65 + (index % 26))}.';
      case OrderedListStyle.lowerRoman:
        return '${_toRoman(index + 1).toLowerCase()}.';
      case OrderedListStyle.upperRoman:
        return '${_toRoman(index + 1)}.';
    }
  }

  String _toRoman(int number) {
    if (number <= 0) return '';
    final values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    final numerals = [
      'M',
      'CM',
      'D',
      'CD',
      'C',
      'XC',
      'L',
      'XL',
      'X',
      'IX',
      'V',
      'IV',
      'I',
    ];

    String result = '';
    for (int i = 0; i < values.length; i++) {
      while (number >= values[i]) {
        number -= values[i];
        result += numerals[i];
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveNumberColor = numberColor ?? theme.colorScheme.primary.withOpacity(0.6); // Reduced visibility

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: indent,
                    child: Text(
                      _getNumberPrefix(index),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: effectiveNumberColor,
                      ),
                    ),
                  ),
                  Expanded(child: item),
                ],
              ),
            );
          }).toList(),
    );
  }
}

enum OrderedListStyle {
  decimal, // 1, 2, 3
  lowerAlpha, // a, b, c
  upperAlpha, // A, B, C
  lowerRoman, // i, ii, iii
  upperRoman, // I, II, III
}

/// Enhanced unordered list with custom bullet styles
class EnhancedUnorderedList extends StatelessWidget {
  final List<Widget> items;
  final UnorderedListStyle style;
  final Color? bulletColor;
  final double indent;
  final int level;

  const EnhancedUnorderedList({
    super.key,
    required this.items,
    this.style = UnorderedListStyle.disc,
    this.bulletColor,
    this.indent = 24,
    this.level = 0,
  });

  Widget _getBullet(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBulletColor = bulletColor ?? theme.colorScheme.primary.withOpacity(0.6); // Reduced visibility

    // Auto-change bullet style based on nesting level
    final effectiveStyle =
        style == UnorderedListStyle.auto ? _getStyleForLevel(level) : style;

    switch (effectiveStyle) {
      case UnorderedListStyle.disc:
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: effectiveBulletColor,
            shape: BoxShape.circle,
          ),
        );
      case UnorderedListStyle.circle:
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            border: Border.all(color: effectiveBulletColor, width: 1.5),
            shape: BoxShape.circle,
          ),
        );
      case UnorderedListStyle.square:
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: effectiveBulletColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      case UnorderedListStyle.dash:
        return Container(
          width: 8,
          height: 2,
          decoration: BoxDecoration(
            color: effectiveBulletColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      case UnorderedListStyle.arrow:
        return Icon(Icons.arrow_right, size: 16, color: effectiveBulletColor);
      case UnorderedListStyle.check:
        return Icon(Icons.check, size: 14, color: effectiveBulletColor);
      case UnorderedListStyle.auto:
        return _getBullet(context); // Recursive with resolved style
    }
  }

  UnorderedListStyle _getStyleForLevel(int level) {
    switch (level % 3) {
      case 0:
        return UnorderedListStyle.disc;
      case 1:
        return UnorderedListStyle.circle;
      case 2:
        return UnorderedListStyle.square;
      default:
        return UnorderedListStyle.disc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: indent,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _getBullet(context),
                    ),
                  ),
                  Expanded(child: item),
                ],
              ),
            );
          }).toList(),
    );
  }
}

enum UnorderedListStyle {
  disc, // Filled circle (•)
  circle, // Hollow circle (○)
  square, // Filled square (■)
  dash, // Dash (–)
  arrow, // Arrow (→)
  check, // Checkmark (✓)
  auto, // Auto-select based on nesting level
}

/// Enhanced horizontal rule with various styles
class EnhancedHorizontalRule extends StatelessWidget {
  final HorizontalRuleStyle style;
  final Color? color;
  final double thickness;
  final EdgeInsets? margin;

  const EnhancedHorizontalRule({
    super.key,
    this.style = HorizontalRuleStyle.solid,
    this.color,
    this.thickness = 1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.outline.withOpacity(0.3);

    Widget divider;

    switch (style) {
      case HorizontalRuleStyle.solid:
        divider = Container(height: thickness, color: effectiveColor);
        break;

      case HorizontalRuleStyle.dashed:
        divider = CustomPaint(
          size: Size(double.infinity, thickness),
          painter: DashedLinePainter(
            color: effectiveColor,
            thickness: thickness,
          ),
        );
        break;

      case HorizontalRuleStyle.dotted:
        divider = CustomPaint(
          size: Size(double.infinity, thickness),
          painter: DottedLinePainter(
            color: effectiveColor,
            thickness: thickness,
          ),
        );
        break;

      case HorizontalRuleStyle.gradient:
        divider = Container(
          height: thickness,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, effectiveColor, Colors.transparent],
            ),
          ),
        );
        break;

      case HorizontalRuleStyle.wave:
        divider = CustomPaint(
          size: Size(double.infinity, thickness * 3),
          painter: WaveLinePainter(color: effectiveColor, thickness: thickness),
        );
        break;
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 16),
      child: divider,
    );
  }
}

enum HorizontalRuleStyle { solid, dashed, dotted, gradient, wave }

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  DashedLinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  DottedLinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill;

    const dotSpace = 5.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawCircle(Offset(startX, size.height / 2), thickness, paint);
      startX += dotSpace;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) => false;
}

class WaveLinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  WaveLinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    const waveLength = 20.0;
    const amplitude = 5.0;
    double x = 0;

    while (x < size.width) {
      path.quadraticBezierTo(
        x + waveLength / 4,
        size.height / 2 - amplitude,
        x + waveLength / 2,
        size.height / 2,
      );
      path.quadraticBezierTo(
        x + 3 * waveLength / 4,
        size.height / 2 + amplitude,
        x + waveLength,
        size.height / 2,
      );
      x += waveLength;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveLinePainter oldDelegate) => false;
}
