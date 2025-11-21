import 'package:flutter/material.dart';
import '../gpt_markdown.dart';
import 'markdown_config.dart';
import 'github_alerts.dart';
import 'task_list_enhanced.dart';
import 'footnote_enhanced.dart';
import 'mermaid_renderer.dart';

/// Extended markdown components for GitHub-flavored markdown and more
/// These components add support for:
/// - GitHub Alerts (> [!NOTE], > [!WARNING], etc.)
/// - HTML line breaks (<br>, <br/>)
/// - Enhanced task lists with status
/// - Footnotes ([^1])
/// - Mermaid diagrams (```mermaid)
/// - Enhanced horizontal rules

/// HTML Line Break Component - Handles <br> and <br/> tags
/// Converts them to line breaks in rendering
class HtmlLineBreakComponent extends InlineMd {
  @override
  RegExp get exp => RegExp(r'<br\s*/?>', caseSensitive: false);

  @override
  InlineSpan span(BuildContext context, String text, GptMarkdownConfig config) {
    return TextSpan(text: '\n', style: config.style);
  }
}

/// HTML Underline Component - Handles <u> tags
class HtmlUnderlineComponent extends InlineMd {
  @override
  RegExp get exp => RegExp(r'<u>(.*?)</u>', caseSensitive: false);

  @override
  InlineSpan span(BuildContext context, String text, GptMarkdownConfig config) {
    final match = exp.firstMatch(text);
    if (match == null) return TextSpan(text: text, style: config.style);

    final content = match.group(1) ?? '';
    return TextSpan(
      text: content,
      style: (config.style ?? const TextStyle()).copyWith(
        decoration: TextDecoration.underline,
      ),
    );
  }
}

/// HTML Mark/Highlight Component - Handles <mark> tags
class HtmlMarkComponent extends InlineMd {
  @override
  RegExp get exp => RegExp(r'<mark>(.*?)</mark>', caseSensitive: false);

  @override
  InlineSpan span(BuildContext context, String text, GptMarkdownConfig config) {
    final match = exp.firstMatch(text);
    if (match == null) return TextSpan(text: text, style: config.style);

    final content = match.group(1) ?? '';
    return TextSpan(
      text: content,
      style: (config.style ?? const TextStyle()).copyWith(
        backgroundColor: Colors.yellow.withValues(alpha: 0.3),
      ),
    );
  }
}

/// HTML Keyboard Component - Handles <kbd> tags
class HtmlKbdComponent extends InlineMd {
  @override
  RegExp get exp => RegExp(r'<kbd>(.*?)</kbd>', caseSensitive: false);

  @override
  InlineSpan span(BuildContext context, String text, GptMarkdownConfig config) {
    final match = exp.firstMatch(text);
    if (match == null) return TextSpan(text: text, style: config.style);

    final content = match.group(1) ?? '';
    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          content,
          style: (config.style ?? const TextStyle()).copyWith(
            fontFamily: 'monospace',
            fontSize: ((config.style?.fontSize) ?? 14) * 0.9,
          ),
        ),
      ),
    );
  }
}

/// GitHub Alert Component - Supports > [!NOTE], > [!WARNING], etc.
class GitHubAlertComponent extends BlockMd {
  @override
  String get expString => r">\s*\[!(\w+)\]\s*[^\n]*(?:\n\s*>[^\n]*)*";

  @override
  Widget build(BuildContext context, String text, GptMarkdownConfig config) {
    try {
      final match = exp.firstMatch(text);
      if (match == null) return const SizedBox.shrink();

      final alertType = match.group(1)?.toLowerCase() ?? 'note';

      // Extract all content lines (remove > prefix from each line)
      final allLines = text.split('\n');
      final contentLines = <String>[];
      bool foundAlert = false;

      for (final line in allLines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('>')) {
          foundAlert = true;
          var content = trimmed.substring(1).trim();

          // Remove [!TYPE] from first line if present
          if (content.startsWith('[!') && content.contains(']')) {
            final endBracket = content.indexOf(']');
            if (endBracket != -1) {
              content = content.substring(endBracket + 1).trim();
            }
          }

          if (content.isNotEmpty) {
            contentLines.add(content);
          }
        } else if (foundAlert && trimmed.isEmpty) {
          break;
        } else if (foundAlert) {
          break;
        }
      }

      final content = contentLines.join('\n').trim();

      GitHubAlertType type;
      switch (alertType) {
        case 'note':
          type = GitHubAlertType.note;
          break;
        case 'tip':
          type = GitHubAlertType.tip;
          break;
        case 'important':
          type = GitHubAlertType.important;
          break;
        case 'warning':
          type = GitHubAlertType.warning;
          break;
        case 'caution':
          type = GitHubAlertType.caution;
          break;
        default:
          type = GitHubAlertType.note;
      }

      return GitHubAlert(
        type: type,
        child: MdWidget(context, content, false, config: config),
      );
    } catch (e) {
      debugPrint('[GitHubAlertComponent] Error: $e');
      return const SizedBox.shrink();
    }
  }
}

/// Enhanced Task List Component
class TaskListComponent extends BlockMd {
  @override
  String get expString => r"\[((?:\x| ))\]\s+(.+?)$";

  @override
  Widget build(BuildContext context, String text, GptMarkdownConfig config) {
    try {
      final match = exp.firstMatch(text.trim());
      if (match == null) return const SizedBox.shrink();

      final isChecked = match.group(1) == 'x';
      final taskText = match.group(2) ?? '';

      return TaskListItem(
        text: taskText,
        isChecked: isChecked,
        status: isChecked ? TaskStatus.completed : TaskStatus.pending,
      );
    } catch (e) {
      debugPrint('[TaskListComponent] Error: $e');
      return const SizedBox.shrink();
    }
  }
}

/// Footnote Component - Supports [^1] syntax
class FootnoteComponent extends InlineMd {
  final FootnoteManager? manager;

  FootnoteComponent({this.manager});

  @override
  RegExp get exp => RegExp(r'\[\^(\d+)\]', multiLine: true);

  @override
  InlineSpan span(BuildContext context, String text, GptMarkdownConfig config) {
    try {
      final match = exp.firstMatch(text);
      if (match == null) {
        return TextSpan(text: text, style: config.style);
      }

      final footnoteId = match.group(1) ?? '';
      final footnoteManager = manager ?? FootnoteManager();

      return WidgetSpan(
        child: FootnoteReference(
          footnoteId: footnoteId,
          manager: footnoteManager,
          style: config.style,
        ),
      );
    } catch (e) {
      debugPrint('[FootnoteComponent] Error: $e');
      return TextSpan(text: text, style: config.style);
    }
  }
}

/// Mermaid Diagram Component - Supports ```mermaid code blocks
class MermaidComponent extends BlockMd {
  @override
  String get expString => r"```mermaid\s*\n((?:.*\n)*?)```";

  @override
  Widget build(BuildContext context, String text, GptMarkdownConfig config) {
    try {
      final match = exp.firstMatch(text);
      if (match == null) return const SizedBox.shrink();

      final mermaidCode = match.group(1)?.trim() ?? '';

      return MermaidRenderer(mermaidCode: mermaidCode);
    } catch (e) {
      debugPrint('[MermaidComponent] Error: $e');
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Mermaid diagram rendering error',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
  }
}

/// Enhanced Horizontal Rule Component - Clean gradient horizontal lines
class EnhancedHorizontalRuleComponent extends BlockMd {
  @override
  String get expString => r"⸻|((--)[-]+)$";

  @override
  Widget build(BuildContext context, String text, GptMarkdownConfig config) {
    try {
      final match = exp.firstMatch(text);
      if (match == null) return const SizedBox.shrink();

      final theme = Theme.of(context);
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              theme.colorScheme.outline.withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('[EnhancedHorizontalRuleComponent] Error: $e');
      return const SizedBox(height: 16);
    }
  }
}

/// Get all extended markdown components
/// These components add GitHub-flavored markdown and HTML tag support
List<MarkdownComponent> getExtendedComponents({
  FootnoteManager? footnoteManager,
}) {
  return [
    GitHubAlertComponent(),
    TaskListComponent(),
    FootnoteComponent(manager: footnoteManager),
    MermaidComponent(),
    EnhancedHorizontalRuleComponent(),
  ];
}

/// Get extended inline components (HTML tags)
List<MarkdownComponent> getExtendedInlineComponents() {
  return [
    HtmlLineBreakComponent(),
    HtmlUnderlineComponent(),
    HtmlMarkComponent(),
    HtmlKbdComponent(),
  ];
}
