import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

/// Enhanced code block widget with ChatGPT/Gemini-like UI
/// Features a clean header with language label and copy button,
/// distinct background colors, and refined typography.
class CodeBlockEnhanced extends StatefulWidget {
  final String code;
  final String? language;
  final TextStyle? textStyle;
  final bool showLineNumbers;
  final bool showCopyButton;
  final bool showLanguageBadge;
  final Color? backgroundColor;
  final Color? headerColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onCopy;
  final int? maxLines;
  final bool expandable;

  const CodeBlockEnhanced({
    super.key,
    required this.code,
    this.language,
    this.textStyle,
    this.showLineNumbers = true,
    this.showCopyButton = true,
    this.showLanguageBadge = true,
    this.backgroundColor,
    this.headerColor,
    this.borderRadius,
    this.padding,
    this.onCopy,
    this.maxLines,
    this.expandable = false,
  });

  @override
  State<CodeBlockEnhanced> createState() => _CodeBlockEnhancedState();
}

class _CodeBlockEnhancedState extends State<CodeBlockEnhanced>
    with SingleTickerProviderStateMixin {
  bool _copied = false;
  bool _isExpanded = true;
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    if (widget.expandable && widget.maxLines != null) {
      final lineCount = widget.code.split('\n').length;
      _isExpanded = lineCount <= widget.maxLines!;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    widget.onCopy?.call();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  String _getLanguageDisplayName() {
    final lang = widget.language?.toLowerCase() ?? '';
    if (lang.isEmpty) return 'Code';

    // Map common extensions to nice names
    const displayNames = {
      'js': 'JavaScript',
      'ts': 'TypeScript',
      'py': 'Python',
      'dart': 'Dart',
      'java': 'Java',
      'cpp': 'C++',
      'c': 'C',
      'cs': 'C#',
      'go': 'Go',
      'rs': 'Rust',
      'rb': 'Ruby',
      'php': 'PHP',
      'swift': 'Swift',
      'kt': 'Kotlin',
      'sql': 'SQL',
      'html': 'HTML',
      'css': 'CSS',
      'json': 'JSON',
      'xml': 'XML',
      'yaml': 'YAML',
      'md': 'Markdown',
      'sh': 'Shell',
      'bash': 'Bash',
      'diff': 'Diff',
    };
    return displayNames[lang] ?? lang; // Keep original casing if not found
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ChatGPT/Gemini-like Color Palette
    // Dark mode: Darker header, black/very dark body
    // Light mode: Light gray header, white/off-white body
    final bgColor =
        widget.backgroundColor ??
        (isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFFFFFF));
    final headerColor =
        widget.headerColor ??
        (isDark ? const Color(0xFF2F2F2F) : const Color(0xFFF7F7F8));
    final borderColor =
        isDark
            ? Colors.white.withOpacity(_isHovering ? 0.2 : 0.1)
            : Colors.black.withOpacity(_isHovering ? 0.1 : 0.05);

    final lines = widget.code.split('\n');
    final shouldShowExpand =
        widget.expandable &&
        widget.maxLines != null &&
        lines.length > widget.maxLines!;

    final displayedCode =
        (!_isExpanded && shouldShowExpand)
            ? lines.take(widget.maxLines!).join('\n') + '\n...'
            : widget.code;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            border: Border.all(color: borderColor),
            color: bgColor,
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: headerColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Label (Left)
                      if (widget.showLanguageBadge)
                        Text(
                          _getLanguageDisplayName(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontFamily: 'Inter', // Or system font
                          ),
                        )
                      else
                        const SizedBox(),

                      // Copy Button (Right)
                      if (widget.showCopyButton) _buildCopyButton(isDark),
                    ],
                  ),
                ),

                // Code Content
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: widget.padding ?? const EdgeInsets.all(16),
                      child:
                          widget.showLineNumbers
                              ? _buildCodeWithLineNumbers(displayedCode, isDark)
                              : _buildCode(displayedCode, isDark),
                    ),
                    // Gradient overlay for collapsed state
                    if (!_isExpanded && shouldShowExpand)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [bgColor.withOpacity(0), bgColor],
                            ),
                          ),
                        ),
                      ),
                    // Expand/Collapse Button overlay
                    if (shouldShowExpand)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: InkWell(
                          onTap:
                              () => setState(() => _isExpanded = !_isExpanded),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: headerColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              _isExpanded ? 'Show Less' : 'Show More',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCopyButton(bool isDark) {
    return InkWell(
      onTap: _copyToClipboard,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child:
              _copied
                  ? Row(
                    key: const ValueKey('copied'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.green, // Or theme accent
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Copied!',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    key: const ValueKey('copy'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.content_copy_rounded,
                        size: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Copy code',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildCode(String code, bool isDark) {
    return SelectableText(
      code,
      style:
          widget.textStyle ??
          TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 13.5,
            height: 1.5,
            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF24292E),
            fontFeatures: [FontFeature.enable('calt')],
          ),
    );
  }

  Widget _buildCodeWithLineNumbers(String code, bool isDark) {
    final lines = code.split('\n');
    final lineCount = lines.length;
    final lineNumberWidth = (lineCount.toString().length * 8.0) + 16;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line Numbers
        Container(
          width: lineNumberWidth,
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              lineCount,
              (index) => Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13.5,
                  height: 1.5,
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
        // Code
        Expanded(
          child: SelectableText(
            code,
            style:
                widget.textStyle ??
                TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13.5,
                  height: 1.5,
                  color:
                      isDark
                          ? const Color(0xFFE0E0E0)
                          : const Color(0xFF24292E),
                  fontFeatures: [FontFeature.enable('calt')],
                ),
          ),
        ),
      ],
    );
  }
}
