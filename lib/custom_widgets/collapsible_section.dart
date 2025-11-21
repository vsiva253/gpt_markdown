import 'package:flutter/material.dart';

/// Collapsible section widget with smooth animations
class CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final IconData? expandIcon;
  final IconData? collapseIcon;
  final Color? headerColor;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final Curve animationCurve;
  final VoidCallback? onExpansionChanged;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.expandIcon,
    this.collapseIcon,
    this.headerColor,
    this.backgroundColor,
    this.titleStyle,
    this.padding,
    this.contentPadding,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.onExpansionChanged,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headerBgColor =
        widget.headerColor ??
        (isDark ? const Color(0xFF2D2D30) : const Color(0xFFF6F8FA));
    final contentBgColor =
        widget.backgroundColor ??
        (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Container(
      margin: widget.padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Material(
            color: headerBgColor,
            borderRadius: BorderRadius.only(
              topLeft: widget.borderRadius?.topLeft ?? const Radius.circular(8),
              topRight:
                  widget.borderRadius?.topRight ?? const Radius.circular(8),
              bottomLeft:
                  _isExpanded
                      ? Radius.zero
                      : (widget.borderRadius?.bottomLeft ??
                          const Radius.circular(8)),
              bottomRight:
                  _isExpanded
                      ? Radius.zero
                      : (widget.borderRadius?.bottomRight ??
                          const Radius.circular(8)),
            ),
            child: InkWell(
              onTap: _toggleExpansion,
              borderRadius: BorderRadius.only(
                topLeft:
                    widget.borderRadius?.topLeft ?? const Radius.circular(8),
                topRight:
                    widget.borderRadius?.topRight ?? const Radius.circular(8),
                bottomLeft:
                    _isExpanded
                        ? Radius.zero
                        : (widget.borderRadius?.bottomLeft ??
                            const Radius.circular(8)),
                bottomRight:
                    _isExpanded
                        ? Radius.zero
                        : (widget.borderRadius?.bottomRight ??
                            const Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style:
                            widget.titleStyle ??
                            TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                      ),
                    ),
                    RotationTransition(
                      turns: _iconRotation,
                      child: Icon(
                        _isExpanded
                            ? (widget.collapseIcon ?? Icons.expand_less)
                            : (widget.expandIcon ?? Icons.expand_more),
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.7)
                                : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              color: contentBgColor,
              padding: widget.contentPadding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nested collapsible sections support
class CollapsibleGroup extends StatelessWidget {
  final List<CollapsibleSection> sections;
  final bool allowMultipleExpanded;
  final EdgeInsets? spacing;

  const CollapsibleGroup({
    super.key,
    required this.sections,
    this.allowMultipleExpanded = true,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          sections
              .map(
                (section) => Padding(
                  padding: spacing ?? const EdgeInsets.only(bottom: 8),
                  child: section,
                ),
              )
              .toList(),
    );
  }
}

/// Parser for collapsible sections in markdown
/// Syntax: <details><summary>Title</summary>Content</details>
class CollapsibleSectionParser {
  static CollapsibleSectionMatch? tryParse(String text) {
    final pattern = RegExp(
      r'<details>\s*<summary>(.*?)</summary>\s*(.*?)</details>',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );

    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final title = match.group(1)?.trim();
    final content = match.group(2)?.trim();

    if (title == null || content == null) return null;

    return CollapsibleSectionMatch(
      title: title,
      content: content,
      fullMatch: match.group(0)!,
      start: match.start,
      end: match.end,
    );
  }

  static List<CollapsibleSectionMatch> findAll(String text) {
    final matches = <CollapsibleSectionMatch>[];
    final pattern = RegExp(
      r'<details>\s*<summary>(.*?)</summary>\s*(.*?)</details>',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );

    for (final match in pattern.allMatches(text)) {
      final title = match.group(1)?.trim();
      final content = match.group(2)?.trim();

      if (title != null && content != null) {
        matches.add(
          CollapsibleSectionMatch(
            title: title,
            content: content,
            fullMatch: match.group(0)!,
            start: match.start,
            end: match.end,
          ),
        );
      }
    }

    return matches;
  }
}

class CollapsibleSectionMatch {
  final String title;
  final String content;
  final String fullMatch;
  final int start;
  final int end;

  const CollapsibleSectionMatch({
    required this.title,
    required this.content,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}
