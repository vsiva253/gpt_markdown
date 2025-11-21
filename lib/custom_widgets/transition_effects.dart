import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Premium page transitions for markdown screens
class MarkdownPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;

  MarkdownPageRoute({
    required this.page,
    this.transitionType = TransitionType.slide,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(
             child,
             animation,
             secondaryAnimation,
             transitionType,
           );
         },
         transitionDuration: const Duration(milliseconds: 400),
       );

  static Widget _buildTransition(
    Widget child,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    TransitionType type,
  ) {
    switch (type) {
      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );

      case TransitionType.fade:
        return FadeTransition(opacity: animation, child: child);

      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );

      case TransitionType.zoom:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: child,
        );
    }
  }
}

enum TransitionType { slide, fade, scale, rotation, slideUp, zoom }

/// Reveal animation for content
class RevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final RevealDirection direction;

  const RevealAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
    this.direction = RevealDirection.vertical,
  });

  @override
  State<RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<RevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
        return ClipRect(
          child: Align(
            alignment:
                widget.direction == RevealDirection.vertical
                    ? Alignment.topCenter
                    : Alignment.centerLeft,
            heightFactor:
                widget.direction == RevealDirection.vertical
                    ? _animation.value
                    : 1.0,
            widthFactor:
                widget.direction == RevealDirection.horizontal
                    ? _animation.value
                    : 1.0,
            child: Opacity(opacity: _animation.value, child: widget.child),
          ),
        );
      },
    );
  }
}

enum RevealDirection { vertical, horizontal }

/// Staggered list animation
class StaggeredListView extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration itemDelay;

  const StaggeredListView({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.itemDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return RevealAnimation(
          delay: delay + (itemDelay * index),
          child: children[index],
        );
      },
    );
  }
}

/// Morphing shape animation
class MorphingShape extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const MorphingShape({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<MorphingShape> createState() => _MorphingShapeState();
}

class _MorphingShapeState extends State<MorphingShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
        return CustomPaint(
          painter: MorphingShapePainter(progress: _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

class MorphingShapePainter extends CustomPainter {
  final double progress;

  MorphingShapePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 2;

    // Create morphing blob shape
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final variation = math.sin(progress * 2 * math.pi + i) * 0.2;
      final r = radius * (1 + variation);
      final x = centerX + r * math.cos(angle);
      final y = centerY + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MorphingShapePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Parallax scroll effect
class ParallaxScroll extends StatefulWidget {
  final Widget background;
  final Widget foreground;
  final double parallaxFactor;

  const ParallaxScroll({
    super.key,
    required this.background,
    required this.foreground,
    this.parallaxFactor = 0.5,
  });

  @override
  State<ParallaxScroll> createState() => _ParallaxScrollState();
}

class _ParallaxScrollState extends State<ParallaxScroll> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with parallax
        Transform.translate(
          offset: Offset(0, _scrollOffset * widget.parallaxFactor),
          child: widget.background,
        ),

        // Foreground content
        SingleChildScrollView(
          controller: _scrollController,
          child: widget.foreground,
        ),
      ],
    );
  }
}

/// Flip card animation
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final transform =
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < math.pi / 2 ? widget.front : widget.back,
          );
        },
      ),
    );
  }
}

/// Bounce animation
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double bounceHeight;

  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.bounceHeight = 20,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: widget.bounceHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
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
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: widget.child,
        );
      },
    );
  }
}

/// Wave animation
class WaveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;

  const WaveAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.amplitude = 10,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
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
        return Transform.translate(
          offset: Offset(
            widget.amplitude * math.sin(_controller.value * 2 * math.pi),
            0,
          ),
          child: widget.child,
        );
      },
    );
  }
}
