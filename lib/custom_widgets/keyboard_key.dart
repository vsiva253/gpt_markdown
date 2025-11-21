import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium app-native keyboard key renderer
/// Looks like actual keyboard keys with depth and shadows!
class KeyboardKey extends StatefulWidget {
  final String keyText;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showShadow;

  const KeyboardKey({
    super.key,
    required this.keyText,
    this.size = 16,
    this.backgroundColor,
    this.textColor,
    this.showShadow = true,
  });

  @override
  State<KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<KeyboardKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact(); // Haptic feedback!
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        widget.backgroundColor ??
        (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5));
    final txtColor =
        widget.textColor ?? (isDark ? Colors.white : Colors.black87);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: EdgeInsets.symmetric(
              horizontal: widget.size * 0.5,
              vertical: widget.size * 0.25,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                width: 1,
              ),
              boxShadow:
                  widget.showShadow
                      ? [
                        // Top highlight (3D effect)
                        BoxShadow(
                          color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
                          offset: Offset(0, -1 - _pressAnimation.value),
                          blurRadius: 0,
                        ),
                        // Bottom shadow (3D effect)
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.5 : 0.3),
                          offset: Offset(0, 2 - _pressAnimation.value),
                          blurRadius: 2 - _pressAnimation.value,
                        ),
                        // Side shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                          offset: Offset(1 - _pressAnimation.value / 2, 0),
                          blurRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Text(
              widget.keyText,
              style: TextStyle(
                fontSize: widget.size,
                fontWeight: FontWeight.w600,
                color: txtColor,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Keyboard shortcut renderer (multiple keys)
class KeyboardShortcut extends StatelessWidget {
  final List<String> keys;
  final double size;
  final String separator;

  const KeyboardShortcut({
    super.key,
    required this.keys,
    this.size = 16,
    this.separator = '+',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          KeyboardKey(keyText: keys[i], size: size),
          if (i < keys.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                separator,
                style: TextStyle(
                  fontSize: size * 0.8,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Parser for keyboard keys in markdown
/// Supports: <kbd>Ctrl</kbd> or <kbd>Ctrl+C</kbd>
class KeyboardParser {
  /// Parse single key: <kbd>Enter</kbd>
  static KeyboardMatch? tryParse(String text) {
    final pattern = RegExp(r'<kbd>(.*?)<\/kbd>', caseSensitive: false);
    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final content = match.group(1);
    if (content == null) return null;

    // Split by + or - for shortcuts
    final keys = content.split(RegExp(r'[+\-]')).map((k) => k.trim()).toList();
    final separator = content.contains('+') ? '+' : '-';

    return KeyboardMatch(
      keys: keys,
      separator: separator,
      fullMatch: match.group(0)!,
      start: match.start,
      end: match.end,
    );
  }

  /// Find all keyboard keys in text
  static List<KeyboardMatch> findAll(String text) {
    final matches = <KeyboardMatch>[];
    final pattern = RegExp(r'<kbd>(.*?)<\/kbd>', caseSensitive: false);

    for (final match in pattern.allMatches(text)) {
      final content = match.group(1);
      if (content != null) {
        final keys =
            content.split(RegExp(r'[+\-]')).map((k) => k.trim()).toList();
        final separator = content.contains('+') ? '+' : '-';

        matches.add(
          KeyboardMatch(
            keys: keys,
            separator: separator,
            fullMatch: match.group(0)!,
            start: match.start,
            end: match.end,
          ),
        );
      }
    }

    return matches;
  }

  /// Common key mappings for better display
  static String normalizeKey(String key) {
    final normalized = {
      'ctrl': 'Ctrl',
      'control': 'Ctrl',
      'cmd': '⌘',
      'command': '⌘',
      'opt': '⌥',
      'option': '⌥',
      'alt': 'Alt',
      'shift': '⇧',
      'enter': '↵',
      'return': '↵',
      'tab': '⇥',
      'esc': 'Esc',
      'escape': 'Esc',
      'space': 'Space',
      'spacebar': 'Space',
      'backspace': '⌫',
      'delete': '⌦',
      'up': '↑',
      'down': '↓',
      'left': '←',
      'right': '→',
      'home': 'Home',
      'end': 'End',
      'pageup': 'PgUp',
      'pagedown': 'PgDn',
      'caps': 'Caps',
      'capslock': 'Caps',
    };

    return normalized[key.toLowerCase()] ?? key;
  }
}

class KeyboardMatch {
  final List<String> keys;
  final String separator;
  final String fullMatch;
  final int start;
  final int end;

  const KeyboardMatch({
    required this.keys,
    required this.separator,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}
