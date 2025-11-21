import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

/// A builder function for the ordered list.
typedef OrderedListBuilder =
    Widget Function(
      BuildContext context,
      String no,
      Widget child,
      GptMarkdownConfig config,
    );

/// A builder function for the unordered list.
typedef UnOrderedListBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      GptMarkdownConfig config,
    );

/// A builder function for the source tag.
typedef SourceTagBuilder =
    Widget Function(BuildContext context, String content, TextStyle textStyle);

/// A builder function for the code block.
typedef CodeBlockBuilder =
    Widget Function(
      BuildContext context,
      String name,
      String code,
      bool closed,
    );

/// A builder function for the LaTeX.
typedef LatexBuilder =
    Widget Function(
      BuildContext context,
      String tex,
      TextStyle textStyle,
      bool inline,
    );

/// A builder function for the link.
typedef LinkBuilder =
    Widget Function(
      BuildContext context,
      InlineSpan text,
      String url,
      TextStyle style,
    );

/// A builder function for the table.
typedef TableBuilder =
    Widget Function(
      BuildContext context,
      List<CustomTableRow> tableRows,
      TextStyle textStyle,
      GptMarkdownConfig config,
    );

/// A builder function for the highlight.
typedef HighlightBuilder =
    Widget Function(BuildContext context, String text, TextStyle style);

/// A builder function for the image.
typedef ImageBuilder = Widget Function(BuildContext context, String imageUrl);

/// A configuration class for the GPT Markdown component.
///
/// The [GptMarkdownConfig] class is used to configure the GPT Markdown component.
/// It takes a [style] parameter to set the style of the text,
/// a [textDirection] parameter to set the direction of the text,
/// and an optional [onLinkTap] parameter to handle link clicks.
class GptMarkdownConfig {
  const GptMarkdownConfig({
    this.style,
    this.textDirection = TextDirection.ltr,
    this.onLinkTap,
    this.textAlign,
    this.textScaler,
    this.latexWorkaround,
    this.latexBuilder,
    this.followLinkColor = false,
    this.codeBuilder,
    this.sourceTagBuilder,
    this.highlightBuilder,
    this.orderedListBuilder,
    this.unOrderedListBuilder,
    this.linkBuilder,
    this.imageBuilder,
    this.maxLines,
    this.overflow,
    this.components,
    this.inlineComponents,
    this.tableBuilder,
    this.currentReadingBlockIndex,
    this.readingHighlightColor,
    this.sentenceHighlightMap,
    this.currentWordIndex,
    this.blockWordRanges,
    this.currentWordHighlightColor,
  });

  /// The direction of the text.
  final TextDirection textDirection;

  /// The style of the text.
  final TextStyle? style;

  /// The alignment of the text.
  final TextAlign? textAlign;

  /// The text scaler.
  final TextScaler? textScaler;

  /// The callback function to handle link clicks.
  final void Function(String url, String title)? onLinkTap;

  /// The LaTeX workaround.
  final String Function(String tex)? latexWorkaround;

  /// The LaTeX builder.
  final LatexBuilder? latexBuilder;

  /// The source tag builder.
  final SourceTagBuilder? sourceTagBuilder;

  /// Whether to follow the link color.
  final bool followLinkColor;

  /// The code builder.
  final CodeBlockBuilder? codeBuilder;

  /// The Ordered List builder.
  final OrderedListBuilder? orderedListBuilder;

  /// The Unordered List builder.
  final UnOrderedListBuilder? unOrderedListBuilder;

  /// The maximum number of lines.
  final int? maxLines;

  /// The overflow.
  final TextOverflow? overflow;

  /// The highlight builder.
  final HighlightBuilder? highlightBuilder;

  /// The link builder.
  final LinkBuilder? linkBuilder;

  /// The image builder.
  final ImageBuilder? imageBuilder;

  /// The list of components.
  final List<MarkdownComponent>? components;

  /// The list of inline components.
  final List<MarkdownComponent>? inlineComponents;

  /// The table builder.
  final TableBuilder? tableBuilder;

  /// Index of the block that is currently being read by TTS.
  /// If null, no highlight.
  /// For sentence-level highlighting, this is the global sentence index.
  final int? currentReadingBlockIndex;

  /// Background color for the highlighted block.
  final Color? readingHighlightColor;
  
  /// Map of paragraph index to sentence index within that paragraph for sentence-level highlighting.
  /// If null, paragraph-level highlighting is used.
  /// Key: paragraph index, Value: sentence index within that paragraph (0-based)
  final Map<int, int>? sentenceHighlightMap;
  
  /// Current word index for word-level highlighting within blocks.
  /// If null, only block-level highlighting is used.
  final int? currentWordIndex;
  
  /// Map of block index to word index range for word-level highlighting.
  /// Key: block index, Value: [startWordIndex, endWordIndex] (inclusive)
  /// Used to determine which words belong to which block.
  final Map<int, List<int>>? blockWordRanges;
  
  /// Color for highlighting the current word (more prominent than block highlight).
  final Color? currentWordHighlightColor;

  /// A copy of the configuration with the specified parameters.
  GptMarkdownConfig copyWith({
    TextStyle? style,
    TextDirection? textDirection,
    final void Function(String url, String title)? onLinkTap,
    final TextAlign? textAlign,
    final TextScaler? textScaler,
    final String Function(String tex)? latexWorkaround,
    final LatexBuilder? latexBuilder,
    final SourceTagBuilder? sourceTagBuilder,
    final bool? followLinkColor,
    final CodeBlockBuilder? codeBuilder,
    final int? maxLines,
    final TextOverflow? overflow,
    final HighlightBuilder? highlightBuilder,
    final LinkBuilder? linkBuilder,
    final ImageBuilder? imageBuilder,
    final OrderedListBuilder? orderedListBuilder,
    final UnOrderedListBuilder? unOrderedListBuilder,
    final List<MarkdownComponent>? components,
    final List<MarkdownComponent>? inlineComponents,
    final TableBuilder? tableBuilder,
    final int? currentReadingBlockIndex,
    final Color? readingHighlightColor,
    final Map<int, int>? sentenceHighlightMap,
    final int? currentWordIndex,
    final Map<int, List<int>>? blockWordRanges,
    final Color? currentWordHighlightColor,
  }) {
    return GptMarkdownConfig(
      style: style ?? this.style,
      textDirection: textDirection ?? this.textDirection,
      onLinkTap: onLinkTap ?? this.onLinkTap,
      textAlign: textAlign ?? this.textAlign,
      textScaler: textScaler ?? this.textScaler,
      latexWorkaround: latexWorkaround ?? this.latexWorkaround,
      latexBuilder: latexBuilder ?? this.latexBuilder,
      followLinkColor: followLinkColor ?? this.followLinkColor,
      codeBuilder: codeBuilder ?? this.codeBuilder,
      sourceTagBuilder: sourceTagBuilder ?? this.sourceTagBuilder,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      highlightBuilder: highlightBuilder ?? this.highlightBuilder,
      linkBuilder: linkBuilder ?? this.linkBuilder,
      imageBuilder: imageBuilder ?? this.imageBuilder,
      orderedListBuilder: orderedListBuilder ?? this.orderedListBuilder,
      unOrderedListBuilder: unOrderedListBuilder ?? this.unOrderedListBuilder,
      components: components ?? this.components,
      inlineComponents: inlineComponents ?? this.inlineComponents,
      tableBuilder: tableBuilder ?? this.tableBuilder,
      currentReadingBlockIndex: currentReadingBlockIndex ?? this.currentReadingBlockIndex,
      readingHighlightColor: readingHighlightColor ?? this.readingHighlightColor,
      sentenceHighlightMap: sentenceHighlightMap ?? this.sentenceHighlightMap,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      blockWordRanges: blockWordRanges ?? this.blockWordRanges,
      currentWordHighlightColor: currentWordHighlightColor ?? this.currentWordHighlightColor,
    );
  }

  /// A method to get a rich text widget from an inline span.
  Text getRich(InlineSpan span) {
    return Text.rich(
      span,
      textDirection: textDirection,
      textScaler: textScaler,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// A method to check if the configuration is the same.
  bool isSame(GptMarkdownConfig other) {
    return style == other.style &&
        textAlign == other.textAlign &&
        textScaler == other.textScaler &&
        maxLines == other.maxLines &&
        overflow == other.overflow &&
        followLinkColor == other.followLinkColor &&
        currentReadingBlockIndex == other.currentReadingBlockIndex &&
        readingHighlightColor == other.readingHighlightColor &&
        _mapEquals(sentenceHighlightMap, other.sentenceHighlightMap) &&
        currentWordIndex == other.currentWordIndex &&
        _mapListEquals(blockWordRanges, other.blockWordRanges) &&
        currentWordHighlightColor == other.currentWordHighlightColor &&
        // latexWorkaround == other.latexWorkaround &&
        // components == other.components &&
        // inlineComponents == other.inlineComponents &&
        // latexBuilder == other.latexBuilder &&
        // sourceTagBuilder == other.sourceTagBuilder &&
        // codeBuilder == other.codeBuilder &&
        // orderedListBuilder == other.orderedListBuilder &&
        // unOrderedListBuilder == other.unOrderedListBuilder &&
        // linkBuilder == other.linkBuilder &&
        // imageBuilder == other.imageBuilder &&
        // highlightBuilder == other.highlightBuilder &&
        // onLinkTap == other.onLinkTap &&
        textDirection == other.textDirection;
  }
  
  /// Helper method to compare maps for equality
  bool _mapEquals(Map<int, int>? a, Map<int, int>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
  
  bool _mapListEquals(Map<int, List<int>>? a, Map<int, List<int>>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      final listA = a[key];
      final listB = b[key];
      if (listA == null && listB == null) continue;
      if (listA == null || listB == null) return false;
      if (listA.length != listB.length) return false;
      for (int i = 0; i < listA.length; i++) {
        if (listA[i] != listB[i]) return false;
      }
    }
    return true;
  }
}
