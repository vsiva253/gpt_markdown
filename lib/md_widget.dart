part of 'gpt_markdown.dart';

/// It creates a markdown widget closed to each other.
class MdWidget extends StatefulWidget {
  const MdWidget(
    this.context,
    this.exp,
    this.includeGlobalComponents, {
    super.key,
    required this.config,
  });

  /// The expression to be displayed.
  final String exp;
  final BuildContext context;

  /// Whether to include global components.
  final bool includeGlobalComponents;

  /// The configuration of the markdown widget.
  final GptMarkdownConfig config;

  @override
  State<MdWidget> createState() => _MdWidgetState();
}

class _MdWidgetState extends State<MdWidget> {
  List<InlineSpan> list = [];
  List<String> blocks = [];
  
  @override
  void initState() {
    super.initState();
    _updateContent();
  }

  void _updateContent() {
    // Split markdown into blocks (paragraphs separated by double newlines)
    blocks = _splitIntoBlocks(widget.exp);
    
    // Generate spans for the full text (for backward compatibility)
    list = MarkdownComponent.generate(
      widget.context,
      widget.exp,
      widget.config,
      widget.includeGlobalComponents,
    );
  }

  @override
  void didUpdateWidget(covariant MdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exp != widget.exp ||
        !oldWidget.config.isSame(widget.config)) {
      _updateContent();
    }
  }

  /// Splits markdown text into blocks (paragraphs separated by double newlines)
  /// Preserves code blocks as single units (doesn't split them)
  List<String> _splitIntoBlocks(String text) {
    if (text.trim().isEmpty) return [];
    
    // First, extract code blocks and replace them with placeholders
    final codeBlockPattern = RegExp(r'```[\s\S]*?```', multiLine: true);
    final codeBlocks = <String>[];
    final placeholders = <String>[];
    
    String processedText = text.replaceAllMapped(codeBlockPattern, (match) {
      final codeBlock = match.group(0) ?? '';
      codeBlocks.add(codeBlock);
      final placeholder = '___CODE_BLOCK_${codeBlocks.length - 1}___';
      placeholders.add(placeholder);
      return placeholder;
    });
    
    // Now split on double newlines (code blocks are protected)
    final parts = processedText.split(RegExp(r'\n\s*\n+'));
    
    // Restore code blocks in each part
    final blocks = parts
        .map((p) {
          // Restore code blocks
          String restored = p;
          for (int i = 0; i < placeholders.length; i++) {
            restored = restored.replaceAll(placeholders[i], codeBlocks[i]);
          }
          return restored.trim();
        })
        .where((p) => p.isNotEmpty)
        .toList();
    
    return blocks;
  }

  /// Wraps a widget with reading highlight if it matches the current block index
  /// Uses AnimatedContainer for smooth transitions
  Widget _wrapWithReadingHighlight(Widget child, int blockIndex) {
    final highlightIndex = widget.config.currentReadingBlockIndex;
    if (highlightIndex == null || highlightIndex != blockIndex) {
      return child;
    }

    // Use AnimatedContainer for smooth transitions (200ms fade)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: widget.config.readingHighlightColor ??
            Colors.yellow.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: child,
    );
  }
  

  @override
  Widget build(BuildContext context) {
    // If we have block highlighting enabled, render blocks separately
    if (widget.config.currentReadingBlockIndex != null && blocks.isNotEmpty) {
      final children = <Widget>[];
      int blockIndex = 0;

      for (final block in blocks) {
        // Generate spans for this block
        final blockSpans = MarkdownComponent.generate(
          context,
          block,
          widget.config,
          widget.includeGlobalComponents,
        );

        final blockWidget = widget.config.getRich(
          TextSpan(
            children: blockSpans,
            style: widget.config.style?.copyWith(),
          ),
        );

        final wrapped = _wrapWithReadingHighlight(blockWidget, blockIndex);
        children.add(wrapped);
        
        blockIndex++;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    // Default behavior: render as single rich text (backward compatible)
    return widget.config.getRich(
      TextSpan(children: list, style: widget.config.style?.copyWith()),
    );
  }
}

/// A custom table column width.
class CustomTableColumnWidth extends TableColumnWidth {
  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double width = 50;
    for (var each in cells) {
      each.layout(const BoxConstraints(), parentUsesSize: true);
      width = max(width, each.size.width);
    }
    return min(containerWidth, width);
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 50;
  }
}
