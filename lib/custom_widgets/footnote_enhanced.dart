import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium app-native footnote system with smooth scrolling and bottom sheets
/// Not like web footnotes - this is truly mobile-first!
class FootnoteManager extends ChangeNotifier {
  final Map<String, FootnoteData> _footnotes = {};
  final ScrollController? scrollController;

  FootnoteManager({this.scrollController});

  void registerFootnote(String id, FootnoteData data) {
    _footnotes[id] = data;
    notifyListeners();
  }

  FootnoteData? getFootnote(String id) => _footnotes[id];

  void clearFootnotes() {
    _footnotes.clear();
    notifyListeners();
  }

  List<FootnoteData> getAllFootnotes() => _footnotes.values.toList();
}

class FootnoteData {
  final String id;
  final String content;
  final GlobalKey key;

  FootnoteData({required this.id, required this.content}) : key = GlobalKey();
}

/// Inline footnote reference with tap to show (app-native)
class FootnoteReference extends StatelessWidget {
  final String footnoteId;
  final FootnoteManager manager;
  final TextStyle? style;

  const FootnoteReference({
    super.key,
    required this.footnoteId,
    required this.manager,
    this.style,
  });

  void _showFootnoteBottomSheet(BuildContext context) {
    // Haptic feedback (app-like!)
    HapticFeedback.lightImpact();

    final footnote = manager.getFootnote(footnoteId);
    if (footnote == null) return;

    // Native bottom sheet (not web tooltip!)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar (app-like)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Footnote header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        footnoteId,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Footnote content
                Text(
                  footnote.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Actions (app-like)
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: footnote.content),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Footnote copied!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text('Jump to'),
                      onPressed: () {
                        Navigator.pop(context);
                        _scrollToFootnote(context, footnote);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _scrollToFootnote(BuildContext context, FootnoteData footnote) {
    // Smooth scroll animation (app-like!)
    final renderBox =
        footnote.key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || manager.scrollController == null) return;

    final position = renderBox.localToGlobal(Offset.zero).dy;
    final scrollOffset = manager.scrollController!.offset + position - 100;

    manager.scrollController!.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Haptic feedback on arrival
    Future.delayed(const Duration(milliseconds: 500), () {
      HapticFeedback.mediumImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showFootnoteBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          footnoteId,
          style: (style ?? const TextStyle()).copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: (style?.fontSize ?? 14) * 0.85,
          ),
        ),
      ),
    );
  }
}

/// Footnote definition at the bottom of the document
class FootnoteDefinition extends StatelessWidget {
  final FootnoteData footnote;
  final VoidCallback? onTap;

  const FootnoteDefinition({super.key, required this.footnote, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: footnote.key,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Footnote ID badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              footnote.id,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Text(footnote.content, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Container for all footnotes at the bottom
class FootnotesSection extends StatelessWidget {
  final FootnoteManager manager;

  const FootnotesSection({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    final footnotes = manager.getAllFootnotes();
    if (footnotes.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Footnotes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...footnotes.map(
            (footnote) => FootnoteDefinition(footnote: footnote),
          ),
        ],
      ),
    );
  }
}

/// Parser for footnotes in markdown
/// Syntax: [^1] for reference, [^1]: Content for definition
class FootnoteParser {
  /// Parse footnote reference: [^1]
  static FootnoteReferenceMatch? tryParseReference(String text) {
    final pattern = RegExp(r'\[\^(\w+)\](?!:)');
    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final id = match.group(1);
    if (id == null) return null;

    return FootnoteReferenceMatch(
      id: id,
      fullMatch: match.group(0)!,
      start: match.start,
      end: match.end,
    );
  }

  /// Parse footnote definition: [^1]: Content
  static FootnoteDefinitionMatch? tryParseDefinition(String text) {
    final pattern = RegExp(r'^\[\^(\w+)\]:\s*(.+)$', multiLine: true);
    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final id = match.group(1);
    final content = match.group(2);
    if (id == null || content == null) return null;

    return FootnoteDefinitionMatch(
      id: id,
      content: content.trim(),
      fullMatch: match.group(0)!,
      start: match.start,
      end: match.end,
    );
  }

  /// Find all footnote definitions in text
  static Map<String, String> extractAllDefinitions(String text) {
    final definitions = <String, String>{};
    final pattern = RegExp(r'^\[\^(\w+)\]:\s*(.+)$', multiLine: true);

    for (final match in pattern.allMatches(text)) {
      final id = match.group(1);
      final content = match.group(2);
      if (id != null && content != null) {
        definitions[id] = content.trim();
      }
    }

    return definitions;
  }
}

class FootnoteReferenceMatch {
  final String id;
  final String fullMatch;
  final int start;
  final int end;

  const FootnoteReferenceMatch({
    required this.id,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}

class FootnoteDefinitionMatch {
  final String id;
  final String content;
  final String fullMatch;
  final int start;
  final int end;

  const FootnoteDefinitionMatch({
    required this.id,
    required this.content,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}
