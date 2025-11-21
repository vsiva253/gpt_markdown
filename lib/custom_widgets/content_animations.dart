import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// Typewriter effect - reveals text character by character
class TypewriterEffect extends StatefulWidget {
  const TypewriterEffect({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 50),
    this.onComplete,
    this.cursor = true,
  });

  final String text;
  final TextStyle? style;
  final Duration speed;
  final VoidCallback? onComplete;
  final bool cursor;

  @override
  State<TypewriterEffect> createState() => _TypewriterEffectState();
}

class _TypewriterEffectState extends State<TypewriterEffect>
    with SingleTickerProviderStateMixin {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_displayedText, style: widget.style),
        if (widget.cursor && _currentIndex < widget.text.length)
          FadeTransition(
            opacity: _cursorController,
            child: Text('|', style: widget.style),
          ),
      ],
    );
  }
}

/// Slide reveal animation
class SlideReveal extends StatefulWidget {
  const SlideReveal({
    super.key,
    required this.child,
    this.direction = AxisDirection.up,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
  });

  final Widget child;
  final AxisDirection direction;
  final Duration duration;
  final Duration delay;

  @override
  State<SlideReveal> createState() => _SlideRevealState();
}

class _SlideRevealState extends State<SlideReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    if (widget.delay != Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Blur reveal - content un-blurs into focus
class BlurReveal extends StatefulWidget {
  const BlurReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.maxBlur = 10.0,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final double maxBlur;
  final Duration delay;

  @override
  State<BlurReveal> createState() => _BlurRevealState();
}

class _BlurRevealState extends State<BlurReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _blurAnimation = Tween<double>(
      begin: widget.maxBlur,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.delay != Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
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
      animation: _blurAnimation,
      builder: (context, child) {
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: _blurAnimation.value,
            sigmaY: _blurAnimation.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Wave motion text effect
class WaveMotion extends StatefulWidget {
  const WaveMotion({
    super.key,
    required this.text,
    this.style,
    this.waveHeight = 10.0,
    this.speed = 1.0,
  });

  final String text;
  final TextStyle? style;
  final double waveHeight;
  final double speed;

  @override
  State<WaveMotion> createState() => _WaveMotionState();
}

class _WaveMotionState extends State<WaveMotion>
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.text.length, (index) {
            final offset =
                math.sin((_controller.value * 2 * math.pi) + (index * 0.5)) *
                widget.waveHeight;

            return Transform.translate(
              offset: Offset(0, offset),
              child: Text(widget.text[index], style: widget.style),
            );
          }),
        );
      },
    );
  }
}

/// Liquid morph transition effect
class LiquidMorph extends StatefulWidget {
  const LiquidMorph({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
  });

  final Widget child;
  final Duration duration;

  @override
  State<LiquidMorph> createState() => _LiquidMorphState();
}

class _LiquidMorphState extends State<LiquidMorph>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..forward();
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
        return ClipPath(
          clipper: _LiquidClipper(progress: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _LiquidClipper extends CustomClipper<Path> {
  final double progress;

  _LiquidClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = size.height * (1 - progress);

    path.moveTo(0, waveHeight);

    for (double i = 0; i < size.width; i++) {
      final y =
          waveHeight +
          math.sin((i / size.width * 4 * math.pi) + (progress * 2 * math.pi)) *
              (waveHeight * 0.1);
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_LiquidClipper oldClipper) =>
      progress != oldClipper.progress;
}

/// Staggered animation for list items
class StaggeredAnimationList extends StatelessWidget {
  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        return SlideReveal(
          duration: animationDuration,
          delay: staggerDelay * index,
          child: children[index],
        );
      }),
    );
  }
}

/// Particle explosion entrance
class ParticleEntrance extends StatefulWidget {
  const ParticleEntrance({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final int particleCount;
  final Duration duration;

  @override
  State<ParticleEntrance> createState() => _ParticleEntranceState();
}

class _ParticleEntranceState extends State<ParticleEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Offset> _particlePositions = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Generate random particle positions
    for (int i = 0; i < widget.particleCount; i++) {
      _particlePositions.add(
        Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
      );
    }

    _controller.forward();
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
        if (_controller.value >= 0.7) {
          // Show the actual child after particles collect
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: widget.child,
          );
        }

        // Show particles
        return CustomPaint(
          painter: _ParticlePainter(
            progress: _controller.value,
            particlePositions: _particlePositions,
            color: Theme.of(context).colorScheme.primary,
          ),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<Offset> particlePositions;
  final Color color;

  _ParticlePainter({
    required this.progress,
    required this.particlePositions,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withOpacity(1 - progress)
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final maxDistance = size.width / 2;

    for (final particlePos in particlePositions) {
      final currentPos = Offset(
        center.dx + particlePos.dx * maxDistance * (1 - progress),
        center.dy + particlePos.dy * maxDistance * (1 - progress),
      );

      canvas.drawCircle(currentPos, 3, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
