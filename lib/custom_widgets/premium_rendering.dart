import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Smart link preview with favicon and metadata
class SmartLinkPreview extends StatefulWidget {
  final String url;
  final String? title;
  final VoidCallback? onTap;
  final bool showFavicon;
  final bool showMetadata;

  const SmartLinkPreview({
    super.key,
    required this.url,
    this.title,
    this.onTap,
    this.showFavicon = true,
    this.showMetadata = true,
  });

  @override
  State<SmartLinkPreview> createState() => _SmartLinkPreviewState();
}

class _SmartLinkPreviewState extends State<SmartLinkPreview> {
  bool _isHovered = false;

  String get _domain {
    try {
      final uri = Uri.parse(widget.url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return widget.url;
    }
  }

  String get _faviconUrl {
    try {
      final uri = Uri.parse(widget.url);
      return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=32';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  _isHovered
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favicon
              if (widget.showFavicon)
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      _faviconUrl,
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.link,
                          size: 16,
                          color: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ),

              // Title or URL
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title ?? _domain,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration:
                            _isHovered
                                ? TextDecoration.underline
                                : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.showMetadata && widget.title != null)
                      Text(
                        _domain,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // External link icon
              const SizedBox(width: 8),
              Icon(
                Icons.open_in_new,
                size: 16,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fade in animation as content scrolls into view
class ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offset;

  const ScrollFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
    this.offset = 50,
  });

  @override
  State<ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_hasAnimated) {
        _controller.forward();
        _hasAnimated = true;
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Staggered fade in for lists
class StaggeredFadeInList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Axis scrollDirection;

  const StaggeredFadeInList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 600),
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: scrollDirection,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return _DelayedFadeIn(
          delay: staggerDelay * index,
          duration: itemDuration,
          child: children[index],
        );
      },
    );
  }
}

class _DelayedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const _DelayedFadeIn({
    required this.child,
    required this.delay,
    required this.duration,
  });

  @override
  State<_DelayedFadeIn> createState() => _DelayedFadeInState();
}

class _DelayedFadeInState extends State<_DelayedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

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
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// Premium code block with syntax-aware selection
class PremiumCodeBlock extends StatefulWidget {
  final String code;
  final String? language;
  final bool showLineNumbers;
  final bool enableCopy;
  final TextStyle? textStyle;

  const PremiumCodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showLineNumbers = true,
    this.enableCopy = true,
    this.textStyle,
  });

  @override
  State<PremiumCodeBlock> createState() => _PremiumCodeBlockState();
}

class _PremiumCodeBlockState extends State<PremiumCodeBlock> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = widget.code.split('\n');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _isHovered
                    ? theme.colorScheme.primary.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  if (widget.language != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.language!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                  if (widget.enableCopy)
                    AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: _CopyCodeButton(code: widget.code),
                    ),
                ],
              ),
            ),

            // Code content
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers
                  if (widget.showLineNumbers)
                    Container(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          lines.length,
                          (index) => Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Code
                  Expanded(
                    child: SelectableText(
                      widget.code,
                      style:
                          widget.textStyle ??
                          TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyCodeButton extends StatefulWidget {
  final String code;

  const _CopyCodeButton({required this.code});

  @override
  State<_CopyCodeButton> createState() => _CopyCodeButtonState();
}

class _CopyCodeButtonState extends State<_CopyCodeButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.lightImpact();

    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: _handleCopy,
      icon: Icon(
        _copied ? Icons.check : Icons.content_copy,
        size: 16,
        color: _copied ? Colors.green : theme.colorScheme.primary,
      ),
      label: Text(
        _copied ? 'Copied!' : 'Copy',
        style: TextStyle(
          fontSize: 12,
          color: _copied ? Colors.green : theme.colorScheme.primary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Premium heading with copy link button
class PremiumHeading extends StatefulWidget {
  final String text;
  final int level; // 1-6
  final String? id;

  const PremiumHeading({
    super.key,
    required this.text,
    required this.level,
    this.id,
  });

  @override
  State<PremiumHeading> createState() => _PremiumHeadingState();
}

class _PremiumHeadingState extends State<PremiumHeading> {
  bool _isHovered = false;

  double get _fontSize {
    switch (widget.level) {
      case 1:
        return 32;
      case 2:
        return 28;
      case 3:
        return 24;
      case 4:
        return 20;
      case 5:
        return 18;
      case 6:
        return 16;
      default:
        return 16;
    }
  }

  FontWeight get _fontWeight {
    return widget.level <= 2 ? FontWeight.bold : FontWeight.w600;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: _fontWeight,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (_isHovered && widget.id != null)
              IconButton(
                icon: const Icon(Icons.link, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: '#${widget.id}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: 'Copy link',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
