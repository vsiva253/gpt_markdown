import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated badge with premium effects
class AnimatedBadge extends StatefulWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool pulse;
  final bool glow;

  const AnimatedBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.pulse = false,
    this.glow = false,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        widget.backgroundColor ?? theme.colorScheme.primaryContainer;
    final txtColor = widget.textColor ?? theme.colorScheme.onPrimaryContainer;

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            widget.glow
                ? [
                  BoxShadow(
                    color: bgColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 16, color: txtColor),
            const SizedBox(width: 6),
          ],
          Text(
            widget.text,
            style: TextStyle(
              color: txtColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    if (widget.pulse) {
      badge = ScaleTransition(scale: _scaleAnimation, child: badge);
    }

    if (widget.glow) {
      badge = AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(_glowAnimation.value),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: child,
          );
        },
        child: badge,
      );
    }

    return badge;
  }
}

/// Circular progress indicator with percentage
class CircularProgressWithPercentage extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool showPercentage;

  const CircularProgressWithPercentage({
    super.key,
    required this.progress,
    this.size = 60,
    this.color,
    this.strokeWidth = 6,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: progressColor.withOpacity(0.2),
            ),
          ),

          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              color: progressColor,
            ),
          ),

          // Percentage text
          if (showPercentage)
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// Linear progress bar with gradient
class GradientProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final bool showPercentage;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.gradientColors,
    this.borderRadius,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        gradientColors ??
        [theme.colorScheme.primary, theme.colorScheme.secondary];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(colors.first),
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

/// Animated counter with number rolling effect
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _animation = IntTween(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
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
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// Floating action menu (speed dial)
class FloatingActionMenu extends StatefulWidget {
  final List<FloatingActionMenuItem> items;
  final IconData mainIcon;
  final Color? backgroundColor;

  const FloatingActionMenu({
    super.key,
    required this.items,
    this.mainIcon = Icons.add,
    this.backgroundColor,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu items
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final delay = index * 50;

          return AnimatedSlide(
            duration: Duration(milliseconds: 300 + delay),
            curve: Curves.easeOut,
            offset: _isExpanded ? Offset.zero : const Offset(0, 1),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300 + delay),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(item.label, style: theme.textTheme.bodySmall),
                    ),
                    const SizedBox(width: 12),

                    // Button
                    FloatingActionButton.small(
                      onPressed: () {
                        item.onPressed();
                        _toggle();
                      },
                      backgroundColor: item.backgroundColor,
                      child: Icon(item.icon),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: widget.backgroundColor,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Icon(widget.mainIcon),
          ),
        ),
      ],
    );
  }
}

class FloatingActionMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const FloatingActionMenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });
}

/// Ripple effect animation
class RippleEffect extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;

  const RippleEffect({
    super.key,
    required this.child,
    required this.color,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 100 * _animation.value,
              height: 100 * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(1 - _animation.value),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}
