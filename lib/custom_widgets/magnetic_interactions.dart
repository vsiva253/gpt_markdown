import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Magnetic button that follows cursor/touch
class MagneticButton extends StatefulWidget {
  const MagneticButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.magneticStrength = 20.0,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.padding,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double magneticStrength;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _offset = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePosition(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final diff = localPosition - center;
    final distance = diff.distance;
    final maxDistance = size.width / 2;

    if (distance < maxDistance) {
      final strength = (1 - distance / maxDistance) * widget.magneticStrength;
      setState(() {
        _offset = Offset(
          diff.dx / maxDistance * strength,
          diff.dy / maxDistance * strength,
        );
      });
    }
  }

  void _resetPosition() {
    setState(() {
      _offset = Offset.zero;
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => _resetPosition(),
      onHover: (event) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        _updatePosition(event.localPosition, box.size);
      },
      child: GestureDetector(
        onTapDown: (_) => HapticFeedback.mediumImpact(),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          child: AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow:
                    _isHovered
                        ? [
                          BoxShadow(
                            color: (widget.backgroundColor ??
                                    Theme.of(context).colorScheme.primary)
                                .withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                        : [],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Elastic link with bounce animation
class ElasticLink extends StatefulWidget {
  const ElasticLink({
    super.key,
    required this.text,
    required this.onTap,
    this.style,
  });

  final String text;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  State<ElasticLink> createState() => _ElasticLinkState();
}

class _ElasticLinkState extends State<ElasticLink>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => HapticFeedback.lightImpact(),
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            widget.text,
            style:
                widget.style?.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: widget.style?.color,
                ) ??
                TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ),
    );
  }
}

/// Floating action toolbar that appears on text selection
class FloatingActionToolbar extends StatelessWidget {
  const FloatingActionToolbar({
    super.key,
    required this.actions,
    this.position = Offset.zero,
  });

  final List<FloatingAction> actions;
  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy - 60,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:
                actions.map((action) {
                  return IconButton(
                    icon: Icon(action.icon, size: 20),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      action.onPressed();
                    },
                    tooltip: action.tooltip,
                    color: Theme.of(context).colorScheme.onSurface,
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class FloatingAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const FloatingAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
}

/// Hover reveal widget - content revealed on hover
class HoverReveal extends StatefulWidget {
  const HoverReveal({
    super.key,
    required this.child,
    required this.revealChild,
    this.direction = AxisDirection.down,
  });

  final Widget child;
  final Widget revealChild;
  final AxisDirection direction;

  @override
  State<HoverReveal> createState() => _HoverRevealState();
}

class _HoverRevealState extends State<HoverReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          Positioned(
            top: widget.direction == AxisDirection.down ? null : -100,
            bottom: widget.direction == AxisDirection.up ? null : -100,
            left: widget.direction == AxisDirection.right ? null : 0,
            right: widget.direction == AxisDirection.left ? null : 0,
            child: FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: _getBeginOffset(),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                ),
                child: widget.revealChild,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case AxisDirection.down:
        return const Offset(0, -0.5);
      case AxisDirection.up:
        return const Offset(0, 0.5);
      case AxisDirection.left:
        return const Offset(0.5, 0);
      case AxisDirection.right:
        return const Offset(-0.5, 0);
    }
  }
}

/// Premium ripple effect
class GestureRipple extends StatefulWidget {
  const GestureRipple({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;

  @override
  State<GestureRipple> createState() => _GestureRippleState();
}

class _GestureRippleState extends State<GestureRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset? _ripplePosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _ripplePosition = null);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    setState(() {
      _ripplePosition = details.localPosition;
    });
    _controller.forward(from: 0);
    HapticFeedback.mediumImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: CustomPaint(
        painter:
            _ripplePosition != null
                ? _RipplePainter(
                  position: _ripplePosition!,
                  animation: _controller,
                  color:
                      widget.rippleColor ??
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                )
                : null,
        child: widget.child,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Offset position;
  final Animation<double> animation;
  final Color color;

  _RipplePainter({
    required this.position,
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final radius = maxRadius * animation.value;
    final opacity = 1.0 - animation.value;

    final paint =
        Paint()
          ..color = color.withOpacity(opacity * color.opacity)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => true;
}

/// Parallax card with 3D tilt effect
class ParallaxCard extends StatefulWidget {
  const ParallaxCard({
    super.key,
    required this.child,
    this.tiltIntensity = 0.01,
    this.shadowIntensity = 10.0,
  });

  final Widget child;
  final double tiltIntensity;
  final double shadowIntensity;

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard> {
  Offset _tilt = Offset.zero;
  bool _isHovered = false;

  void _updateTilt(Offset localPosition, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final tiltX = (localPosition.dx - centerX) / centerX;
    final tiltY = (localPosition.dy - centerY) / centerY;

    setState(() {
      _tilt = Offset(tiltX, tiltY);
    });
  }

  void _resetTilt() {
    setState(() {
      _tilt = Offset.zero;
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => _resetTilt(),
      onHover: (event) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        _updateTilt(event.localPosition, box.size);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tilt.dy * widget.tiltIntensity)
              ..rotateY(-_tilt.dx * widget.tiltIntensity),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                _isHovered
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: widget.shadowIntensity,
                        offset: Offset(
                          -_tilt.dx * widget.shadowIntensity,
                          -_tilt.dy * widget.shadowIntensity,
                        ),
                      ),
                    ]
                    : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
