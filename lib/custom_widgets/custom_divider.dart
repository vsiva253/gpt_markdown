import 'package:flutter/material.dart';

/// A custom divider widget that extends LeafRenderObjectWidget.
///
/// The [CustomDivider] widget is used to create a horizontal divider line in the UI.
/// It takes an optional [color] parameter to specify the color of the divider,
/// and an optional [height] parameter to set the height of the divider.
///
class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key, this.height, this.color});

  /// The color of the divider.
  ///
  /// If not provided, the divider will use the color of the current theme.
  final Color? color;

  /// The height of the divider.
  ///
  /// If not provided, the divider will have a default height of 2.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.outline;
    return Container(
      height: height ?? 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withOpacity(0.0),
            themeColor.withOpacity(0.5),
            themeColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
