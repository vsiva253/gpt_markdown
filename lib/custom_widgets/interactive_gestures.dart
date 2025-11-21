import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Premium pull-to-refresh with custom animations
class PremiumRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final double displacement;

  const PremiumRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.displacement = 40,
  });

  @override
  State<PremiumRefreshIndicator> createState() =>
      _PremiumRefreshIndicatorState();
}

class _PremiumRefreshIndicatorState extends State<PremiumRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();
    _controller.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: color,
      displacement: widget.displacement,
      child: widget.child,
    );
  }
}

/// Swipeable card with actions
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final List<SwipeAction> leftActions;
  final List<SwipeAction> rightActions;
  final double actionWidth;

  const SwipeableCard({
    super.key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.actionWidth = 80,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragExtent = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      _isDragging = true;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final threshold = widget.actionWidth;

    if (_dragExtent.abs() > threshold) {
      // Execute action
      final actions =
          _dragExtent > 0 ? widget.leftActions : widget.rightActions;
      if (actions.isNotEmpty) {
        HapticFeedback.mediumImpact();
        actions.first.onPressed();
      }
    }

    setState(() {
      _dragExtent = 0;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background actions
          if (_isDragging)
            Positioned.fill(
              child: Row(
                children: [
                  // Left actions
                  if (_dragExtent > 0 && widget.leftActions.isNotEmpty)
                    ...widget.leftActions.map((action) => _buildAction(action)),

                  const Spacer(),

                  // Right actions
                  if (_dragExtent < 0 && widget.rightActions.isNotEmpty)
                    ...widget.rightActions.map(
                      (action) => _buildAction(action),
                    ),
                ],
              ),
            ),

          // Main content
          Transform.translate(
            offset: Offset(_dragExtent.clamp(-200, 200), 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildAction(SwipeAction action) {
    return Container(
      width: widget.actionWidth,
      color: action.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(action.icon, color: action.foregroundColor),
          const SizedBox(height: 4),
          Text(
            action.label,
            style: TextStyle(color: action.foregroundColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SwipeAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const SwipeAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
  });
}

/// Draggable bottom sheet with snap points
class DraggableSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;

  const DraggableSheet({
    super.key,
    required this.child,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.95,
    this.snapSizes = const [0.25, 0.5, 0.95],
  });

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  late DraggableScrollableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: true,
      snapSizes: widget.snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Long press menu with haptic feedback
class LongPressMenu extends StatefulWidget {
  final Widget child;
  final List<MenuAction> actions;

  const LongPressMenu({super.key, required this.child, required this.actions});

  @override
  State<LongPressMenu> createState() => _LongPressMenuState();
}

class _LongPressMenuState extends State<LongPressMenu> {
  void _showMenu(BuildContext context, LongPressStartDetails details) {
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(details.globalPosition, details.globalPosition),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items:
          widget.actions.map((action) {
            return PopupMenuItem(
              child: Row(
                children: [
                  Icon(action.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(action.label),
                ],
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                action.onPressed();
              },
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _showMenu(context, details),
      child: widget.child,
    );
  }
}

class MenuAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const MenuAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

/// Pinch to zoom gesture detector
class PinchZoomDetector extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final ValueChanged<double>? onScaleChanged;

  const PinchZoomDetector({
    super.key,
    required this.child,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.onScaleChanged,
  });

  @override
  State<PinchZoomDetector> createState() => _PinchZoomDetectorState();
}

class _PinchZoomDetectorState extends State<PinchZoomDetector>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    HapticFeedback.mediumImpact();

    final newScale = _currentScale == 1.0 ? 2.0 : 1.0;

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity()..scale(newScale),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _currentScale = newScale;
      });
      widget.onScaleChanged?.call(newScale);
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final scale = details.scale.clamp(widget.minScale, widget.maxScale);

    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale;
      });
      widget.onScaleChanged?.call(scale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        onInteractionUpdate: (details) {
          if (details.scale != 1.0) {
            _handleScaleUpdate(
              ScaleUpdateDetails(
                scale: details.scale,
                focalPoint: details.focalPoint,
              ),
            );
          }
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            if (_animation != null) {
              _transformationController.value = _animation!.value;
            }
            return widget.child;
          },
        ),
      ),
    );
  }
}

/// Dismissible with custom animations
class DismissibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismissed;
  final DismissDirection direction;
  final Color? backgroundColor;

  const DismissibleCard({
    super.key,
    required this.child,
    this.onDismissed,
    this.direction = DismissDirection.horizontal,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: UniqueKey(),
      direction: direction,
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        onDismissed?.call();
      },
      background: Container(
        color: backgroundColor ?? theme.colorScheme.errorContainer,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      secondaryBackground: Container(
        color: backgroundColor ?? theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: child,
    );
  }
}
