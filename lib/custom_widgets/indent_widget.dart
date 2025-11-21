import 'package:flutter/material.dart';

/// A custom widget that adds an indent to the left or right of its child.
///
/// The [BlockQuoteWidget] widget is used to create a visual indent in the UI.
/// It takes a [child] parameter which is the content of the widget,
/// a [direction] parameter which specifies the direction of the indent,
/// and a [color] parameter to set the color of the indent.
class BlockQuoteWidget extends StatelessWidget {
  const BlockQuoteWidget({
    super.key,
    required this.child,
    required this.direction,
    required this.color,
    this.width = 4,
  });

  /// The child widget to be indented.
  final Widget child;

  /// The direction of the indent.
  final TextDirection direction;

  /// The color of the indent.
  final Color color;

  /// The width of the indent.
  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
          topLeft: Radius.circular(2),
          bottomLeft: Radius.circular(2),
        ),
        border: Border(left: BorderSide(color: color, width: width)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 6,
            child: Icon(
              Icons.format_quote_rounded,
              size: 16,
              color: color.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 16, 12),
            child: child,
          ),
        ],
      ),
    );
  }
}
