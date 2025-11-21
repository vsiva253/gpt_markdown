import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Premium glassmorphism container with frosted glass effect
///
/// Usage:
/// ```dart
/// GlassmorphicContainer(
///   blur: 10,
///   opacity: 0.2,
///   borderRadius: 16,
///   child: YourContent(),
/// )
/// ```
class GlassmorphicContainer extends StatelessWidget {
  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius = 16.0,
    this.border,
    this.gradient,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Border? border;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity * 0.7),
                    ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  border ??
                  Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Neomorphic card with soft UI design
/// Creates depth through subtle shadows
class NeomorphicCard extends StatefulWidget {
  const NeomorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.depth = 8.0,
    this.intensity = 0.5,
    this.backgroundColor,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final double depth;
  final double intensity;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  State<NeomorphicCard> createState() => _NeomorphicCardState();
}

class _NeomorphicCardState extends State<NeomorphicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? Theme.of(context).colorScheme.surface;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown:
          widget.onTap != null
              ? (_) => setState(() => _isPressed = true)
              : null,
      onTapUp:
          widget.onTap != null
              ? (_) {
                setState(() => _isPressed = false);
                widget.onTap?.call();
              }
              : null,
      onTapCancel:
          widget.onTap != null
              ? () => setState(() => _isPressed = false)
              : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow:
              _isPressed
                  ? []
                  : [
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.black.withOpacity(0.4 * widget.intensity)
                              : Colors.black.withOpacity(
                                0.2 * widget.intensity,
                              ),
                      offset: Offset(widget.depth, widget.depth),
                      blurRadius: widget.depth * 2,
                    ),
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.white.withOpacity(
                                0.05 * widget.intensity,
                              )
                              : Colors.white.withOpacity(
                                0.9 * widget.intensity,
                              ),
                      offset: Offset(-widget.depth, -widget.depth),
                      blurRadius: widget.depth * 2,
                    ),
                  ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Gradient border box with animated rainbow effect
class GradientBorderBox extends StatefulWidget {
  const GradientBorderBox({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = 12.0,
    this.gradient,
    this.animated = true,
    this.animationDuration = const Duration(seconds: 3),
    this.padding,
  });

  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final Gradient? gradient;
  final bool animated;
  final Duration animationDuration;
  final EdgeInsetsGeometry? padding;

  @override
  State<GradientBorderBox> createState() => _GradientBorderBoxState();
}

class _GradientBorderBoxState extends State<GradientBorderBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            gradient:
                widget.gradient ??
                SweepGradient(
                  colors: const [
                    Colors.red,
                    Colors.pink,
                    Colors.purple,
                    Colors.blue,
                    Colors.cyan,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                  ],
                  transform: GradientRotation(_controller.value * 2 * math.pi),
                ),
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderWidth;
  final double borderRadius;

  _GradientBorderPainter({
    required this.gradient,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) => true;
}

/// Aurora background with moving northern lights effect
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF00FFF0),
      Color(0xFF7B61FF),
      Color(0xFFFF006E),
      Color(0xFFFFBE0B),
    ],
    this.speed = 1.0,
  });

  final Widget child;
  final List<Color> colors;
  final double speed;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (5000 / widget.speed).round()),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AuroraPainter(
            colors: widget.colors,
            animationValue: _controller.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;

  _AuroraPainter({required this.colors, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    for (int i = 0; i < colors.length; i++) {
      final offset = (animationValue + i * 0.25) % 1.0;
      final paint =
          Paint()
            ..shader = RadialGradient(
              center: Alignment(
                math.sin(offset * 2 * math.pi) * 0.8,
                math.cos(offset * 2 * math.pi) * 0.8,
              ),
              colors: [colors[i].withOpacity(0.3), colors[i].withOpacity(0.0)],
            ).createShader(rect)
            ..blendMode = BlendMode.screen;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) => true;
}

/// Holographic text with rainbow shimmer effect
class HolographicText extends StatefulWidget {
  const HolographicText(
    this.text, {
    super.key,
    this.style,
    this.speed = 1.0,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final double speed;
  final TextAlign? textAlign;

  @override
  State<HolographicText> createState() => _HolographicTextState();
}

class _HolographicTextState extends State<HolographicText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (2000 / widget.speed).round()),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFFF006E),
                Color(0xFF7B61FF),
                Color(0xFF00FFF0),
                Color(0xFFFFBE0B),
                Color(0xFFFF006E),
              ],
              stops: [
                0.0,
                0.25 + _controller.value * 0.5,
                0.5 + _controller.value * 0.5,
                0.75 + _controller.value * 0.5,
                1.0,
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style:
                widget.style?.copyWith(color: Colors.white) ??
                const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}

/// Metallic surface with sheen effect
class MetallicSurface extends StatefulWidget {
  const MetallicSurface({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFB8B8B8),
    this.animated = true,
    this.borderRadius = 8.0,
  });

  final Widget child;
  final Color baseColor;
  final bool animated;
  final double borderRadius;

  @override
  State<MetallicSurface> createState() => _MetallicSurfaceState();
}

class _MetallicSurfaceState extends State<MetallicSurface>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, -1.0),
              end: Alignment(1.0 + _controller.value * 2, 1.0),
              colors: [
                widget.baseColor.withOpacity(0.8),
                Colors.white.withOpacity(0.6),
                widget.baseColor.withOpacity(0.9),
                Colors.white.withOpacity(0.4),
                widget.baseColor,
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.baseColor.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
