import 'package:flutter/material.dart';

/// GitHub-style alert types
enum GitHubAlertType { note, tip, important, warning, caution }

/// GitHub-style alert widget
class GitHubAlert extends StatelessWidget {
  final GitHubAlertType type;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;

  const GitHubAlert({
    super.key,
    required this.type,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  /// Creates an alert from markdown text
  factory GitHubAlert.fromMarkdown({
    required GitHubAlertType type,
    required String content,
    TextStyle? textStyle,
  }) {
    return GitHubAlert(type: type, child: Text(content, style: textStyle));
  }

  AlertConfig _getConfig(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case GitHubAlertType.note:
        return AlertConfig(
          icon: Icons.info_outline,
          title: 'Note',
          color: const Color(0xFF0969DA),
          backgroundColor:
              isDark
                  ? const Color(0xFF0969DA).withOpacity(0.15)
                  : const Color(0xFFDDF4FF),
          borderColor:
              isDark
                  ? const Color(0xFF0969DA).withOpacity(0.4)
                  : const Color(0xFF0969DA).withOpacity(0.3),
        );
      case GitHubAlertType.tip:
        return AlertConfig(
          icon: Icons.lightbulb_outline,
          title: 'Tip',
          color: const Color(0xFF1A7F37),
          backgroundColor:
              isDark
                  ? const Color(0xFF1A7F37).withOpacity(0.15)
                  : const Color(0xFFDCFFE4),
          borderColor:
              isDark
                  ? const Color(0xFF1A7F37).withOpacity(0.4)
                  : const Color(0xFF1A7F37).withOpacity(0.3),
        );
      case GitHubAlertType.important:
        return AlertConfig(
          icon: Icons.priority_high,
          title: 'Important',
          color: const Color(0xFF8250DF),
          backgroundColor:
              isDark
                  ? const Color(0xFF8250DF).withOpacity(0.15)
                  : const Color(0xFFF6F0FF),
          borderColor:
              isDark
                  ? const Color(0xFF8250DF).withOpacity(0.4)
                  : const Color(0xFF8250DF).withOpacity(0.3),
        );
      case GitHubAlertType.warning:
        return AlertConfig(
          icon: Icons.warning_amber_outlined,
          title: 'Warning',
          color: const Color(0xFF9A6700),
          backgroundColor:
              isDark
                  ? const Color(0xFF9A6700).withOpacity(0.15)
                  : const Color(0xFFFFF8C5),
          borderColor:
              isDark
                  ? const Color(0xFF9A6700).withOpacity(0.4)
                  : const Color(0xFF9A6700).withOpacity(0.3),
        );
      case GitHubAlertType.caution:
        return AlertConfig(
          icon: Icons.dangerous_outlined,
          title: 'Caution',
          color: const Color(0xFFCF222E),
          backgroundColor:
              isDark
                  ? const Color(0xFFCF222E).withOpacity(0.15)
                  : const Color(0xFFFFEBE9),
          borderColor:
              isDark
                  ? const Color(0xFFCF222E).withOpacity(0.4)
                  : const Color(0xFFCF222E).withOpacity(0.3),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: config.borderColor, width: 4),
          top: BorderSide(color: config.borderColor.withOpacity(0.3), width: 1),
          right: BorderSide(
            color: config.borderColor.withOpacity(0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color: config.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(config.icon, color: config.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: config.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                DefaultTextStyle(
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Configuration for alert appearance
class AlertConfig {
  final IconData icon;
  final String title;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const AlertConfig({
    required this.icon,
    required this.title,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });
}

/// Parser for GitHub-style alert syntax
class GitHubAlertParser {
  /// Parses markdown text for GitHub alerts
  /// Syntax: > [!NOTE], > [!TIP], > [!IMPORTANT], > [!WARNING], > [!CAUTION]
  static GitHubAlertMatch? tryParse(String text) {
    final pattern = RegExp(
      r'^>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*\n((?:>.*\n?)*)',
      multiLine: true,
      caseSensitive: false,
    );

    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final typeStr = match.group(1)?.toUpperCase();
    final content =
        match
            .group(2)
            ?.split('\n')
            .map((line) => line.replaceFirst(RegExp(r'^>\s?'), ''))
            .join('\n')
            .trim();

    if (typeStr == null || content == null) return null;

    GitHubAlertType? type;
    switch (typeStr) {
      case 'NOTE':
        type = GitHubAlertType.note;
        break;
      case 'TIP':
        type = GitHubAlertType.tip;
        break;
      case 'IMPORTANT':
        type = GitHubAlertType.important;
        break;
      case 'WARNING':
        type = GitHubAlertType.warning;
        break;
      case 'CAUTION':
        type = GitHubAlertType.caution;
        break;
    }

    if (type == null) return null;

    return GitHubAlertMatch(
      type: type,
      content: content,
      fullMatch: match.group(0)!,
      start: match.start,
      end: match.end,
    );
  }

  /// Finds all GitHub alerts in text
  static List<GitHubAlertMatch> findAll(String text) {
    final matches = <GitHubAlertMatch>[];
    var remaining = text;
    var offset = 0;

    while (true) {
      final match = tryParse(remaining);
      if (match == null) break;

      matches.add(
        GitHubAlertMatch(
          type: match.type,
          content: match.content,
          fullMatch: match.fullMatch,
          start: offset + match.start,
          end: offset + match.end,
        ),
      );

      offset += match.end;
      remaining = remaining.substring(match.end);
    }

    return matches;
  }
}

/// Match result for GitHub alert parsing
class GitHubAlertMatch {
  final GitHubAlertType type;
  final String content;
  final String fullMatch;
  final int start;
  final int end;

  const GitHubAlertMatch({
    required this.type,
    required this.content,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}
