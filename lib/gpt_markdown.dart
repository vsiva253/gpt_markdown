import 'package:flutter/material.dart';
import 'package:gpt_markdown/custom_widgets/markdown_config.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:gpt_markdown/custom_widgets/custom_divider.dart';
import 'package:gpt_markdown/custom_widgets/custom_error_image.dart';
import 'package:gpt_markdown/custom_widgets/custom_rb_cb.dart';
import 'package:gpt_markdown/custom_widgets/selectable_adapter.dart';
import 'package:gpt_markdown/custom_widgets/unordered_ordered_list.dart';
import 'dart:math';

import 'custom_widgets/code_block_enhanced.dart';
import 'custom_widgets/indent_widget.dart';
import 'custom_widgets/link_button.dart';

part 'theme.dart';
part 'markdown_component.dart';
part 'md_widget.dart';

/// This widget create a full markdown widget as a column view.
class GptMarkdown extends StatelessWidget {
  const GptMarkdown(
    this.data, {
    super.key,
    this.style,
    this.followLinkColor = false,
    this.textDirection = TextDirection.ltr,
    this.latexWorkaround,
    this.textAlign,
    this.imageBuilder,
    this.textScaler,
    this.onLinkTap,
    this.latexBuilder,
    this.codeBuilder,
    this.sourceTagBuilder,
    this.highlightBuilder,
    this.linkBuilder,
    this.maxLines,
    this.overflow,
    this.orderedListBuilder,
    this.unOrderedListBuilder,
    this.tableBuilder,
    this.components,
    this.inlineComponents,
    this.useDollarSignsForLatex = false,
    this.currentReadingBlockIndex,
    this.readingHighlightColor,
    this.currentWordIndex,
    this.blockWordRanges,
    this.currentWordHighlightColor,
  });

  /// The direction of the text.
  final TextDirection textDirection;

  /// The data to be displayed.
  final String data;

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
  final int? maxLines;

  /// The overflow.
  final TextOverflow? overflow;

  /// The LaTeX builder.
  final LatexBuilder? latexBuilder;

  /// Whether to follow the link color.
  final bool followLinkColor;

  /// The code builder.
  final CodeBlockBuilder? codeBuilder;

  /// The source tag builder.
  final SourceTagBuilder? sourceTagBuilder;

  /// The highlight builder.
  final HighlightBuilder? highlightBuilder;

  /// The link builder.
  final LinkBuilder? linkBuilder;

  /// The image builder.
  final ImageBuilder? imageBuilder;

  /// The ordered list builder.
  final OrderedListBuilder? orderedListBuilder;

  /// The unordered list builder.
  final UnOrderedListBuilder? unOrderedListBuilder;

  /// Whether to use dollar signs for LaTeX.
  final bool useDollarSignsForLatex;

  /// The table builder.
  final TableBuilder? tableBuilder;

  /// The list of components.
  ///  ```dart
  /// List<MarkdownComponent> components = [
  ///   CodeBlockMd(),
  ///   NewLines(),
  ///   BlockQuote(),
  ///   ImageMd(),
  ///   ATagMd(),
  ///   TableMd(),
  ///   HTag(),
  ///   UnOrderedList(),
  ///   OrderedList(),
  ///   RadioButtonMd(),
  ///   CheckBoxMd(),
  ///   HrLine(),
  ///   StrikeMd(),
  ///   BoldMd(),
  ///   ItalicMd(),
  ///   LatexMath(),
  ///   LatexMathMultiLine(),
  ///   HighlightedText(),
  ///   SourceTag(),
  ///   IndentMd(),
  /// ];
  /// ```
  final List<MarkdownComponent>? components;

  /// The list of inline components.
  ///  ```dart
  /// List<MarkdownComponent> inlineComponents = [
  ///   ImageMd(),
  ///   ATagMd(),
  ///   TableMd(),
  ///   StrikeMd(),
  ///   BoldMd(),
  ///   ItalicMd(),
  ///   LatexMath(),
  ///   LatexMathMultiLine(),
  ///   HighlightedText(),
  ///   SourceTag(),
  /// ];
  /// ```
  final List<MarkdownComponent>? inlineComponents;

  /// Index of the block that is currently being read by TTS.
  /// If null, no highlight.
  final int? currentReadingBlockIndex;

  /// Background color for the highlighted block.
  final Color? readingHighlightColor;

  /// Current word index for word-level highlighting within blocks.
  final int? currentWordIndex;

  /// Map of block index to word index range for word-level highlighting.
  final Map<int, List<int>>? blockWordRanges;

  /// Color for highlighting the current word (more prominent than block highlight).
  final Color? currentWordHighlightColor;

  /// A method to remove extra lines inside block LaTeX.
  // String _removeExtraLinesInsideBlockLatex(String text) {
  //   return text.replaceAllMapped(
  //     RegExp(r"\\\[(.*?)\\\]", multiLine: true, dotAll: true),
  //     (match) {
  //       String content = match[0] ?? "";
  //       return content.replaceAllMapped(RegExp(r"\n[\n\ ]+"), (match) => "\n");
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    String tex = data.trim();
    if (useDollarSignsForLatex) {
      tex = tex.replaceAllMapped(
        RegExp(r"(?<!\\)\$\$(.*?)(?<!\\)\$\$", dotAll: true),
        (match) => "\\[${match[1] ?? ""}\\]",
      );
      if (!tex.contains(r"\(")) {
        tex = tex.replaceAllMapped(
          RegExp(r"(?<!\\)\$(.*?)(?<!\\)\$"),
          (match) => "\\(${match[1] ?? ""}\\)",
        );
        tex = tex.splitMapJoin(
          RegExp(r"\[.*?\]|\(.*?\)"),
          onNonMatch: (p0) {
            return p0.replaceAll("\\\$", "\$");
          },
        );
      }
    }
    // tex = _removeExtraLinesInsideBlockLatex(tex);
    return ClipRRect(
      child: MdWidget(
        context,
        tex,
        true,
        config: GptMarkdownConfig(
          textDirection: textDirection,
          style: style,
          onLinkTap: onLinkTap,
          textAlign: textAlign,
          textScaler: textScaler,
          followLinkColor: followLinkColor,
          latexWorkaround: latexWorkaround,
          latexBuilder: latexBuilder,
          codeBuilder: codeBuilder,
          maxLines: maxLines,
          overflow: overflow,
          sourceTagBuilder: sourceTagBuilder,
          highlightBuilder: highlightBuilder,
          linkBuilder: linkBuilder,
          imageBuilder: imageBuilder,
          orderedListBuilder: orderedListBuilder,
          unOrderedListBuilder: unOrderedListBuilder,
          components: components,
          inlineComponents: inlineComponents,
          tableBuilder: tableBuilder,
          currentReadingBlockIndex: currentReadingBlockIndex,
          readingHighlightColor: readingHighlightColor,
          currentWordIndex: currentWordIndex,
          blockWordRanges: blockWordRanges,
          currentWordHighlightColor: currentWordHighlightColor,
        ),
      ),
    );
  }
}

/// Detects the primary language of the text content.
///
/// Returns language code based on script detection:
/// - 'te-IN' for Telugu
/// - 'hi-IN' for Hindi
/// - 'en-IN' for English (default)
///
/// [text] - The text to analyze
///
/// Returns a language code suitable for TTS
String detectLanguageFromText(String text) {
  if (text.isEmpty) return 'en-IN';

  // Telugu script range: U+0C00 to U+0C7F
  final teluguPattern = RegExp(r'[\u0C00-\u0C7F]');
  // Hindi script range: U+0900 to U+097F
  final hindiPattern = RegExp(r'[\u0900-\u097F]');

  int teluguCount = 0;
  int hindiCount = 0;
  int totalChars = 0;

  for (final char in text.runes) {
    final charStr = String.fromCharCode(char);
    if (teluguPattern.hasMatch(charStr)) {
      teluguCount++;
      totalChars++;
    } else if (hindiPattern.hasMatch(charStr)) {
      hindiCount++;
      totalChars++;
    } else if (RegExp(r'[a-zA-Z]').hasMatch(charStr)) {
      totalChars++;
    }
  }

  // If we have significant Telugu characters, use Telugu
  if (teluguCount > 10 || (teluguCount > 0 && teluguCount > totalChars * 0.1)) {
    return 'te-IN';
  }

  // If we have significant Hindi characters, use Hindi
  if (hindiCount > 10 || (hindiCount > 0 && hindiCount > totalChars * 0.1)) {
    return 'hi-IN';
  }

  // Default to English
  return 'en-IN';
}

/// Debug function to compare raw markdown with extracted plain text.
///
/// Use this to identify extraction issues:
/// ```dart
/// debugPlainText(markdown);
/// ```
///
/// This will print both the raw markdown and the extracted TTS text to the console.
void debugPlainText(String markdown, {bool useDollarSignsForLatex = false}) {
  if (kDebugMode) {
    debugPrint('====== RAW MARKDOWN ======');
    debugPrint(markdown);
    debugPrint('\n====== TTS PLAIN TEXT ======');
    final ttsText = gptMarkdownToPlainText(
      markdown,
      useDollarSignsForLatex: useDollarSignsForLatex,
    );
    debugPrint(ttsText);
    debugPrint('\n====== END DEBUG ======\n');
  }
}

/// Normalizes a single block of plain text for TTS.
///
/// This function applies safe, per-block normalization that:
/// - Strips emojis (prevents stuck sections like "🎭2.")
/// - Collapses internal whitespace
/// - Trims the block
///
/// This is designed to be applied to each block BEFORE joining blocks together,
/// ensuring that the final `ttsText` is the single source of truth for all timing calculations.
///
/// [blockText] - The plain text block to normalize
///
/// Returns the normalized block text, or empty string if block becomes empty after normalization
String normalizeBlockForTts(String blockText) {
  var text = blockText.trim();

  if (text.isEmpty) return '';

  // Strip emojis and symbols (prevents stuck sections and word splitting issues)
  // Covers most emoji ranges: Emoticons, Symbols, Pictographs, Transport, etc.
  text = text.replaceAll(
    RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FAFF}]',
      unicode: true,
    ),
    '',
  );

  // Collapse internal whitespace (spaces and tabs)
  text = text.replaceAll(RegExp(r'[ \t]+'), ' ');

  // Remove lines with only whitespace
  text = text.replaceAll(RegExp(r'^\s+$', multiLine: true), '');

  return text.trim();
}

/// Converts markdown text to plain text suitable for text-to-speech.
///
/// This function uses the same parsing logic as [GptMarkdown] to extract
/// clean text content from markdown, handling all markdown elements appropriately:
/// - Headings: extracts text content
/// - Links: extracts link text (not URL)
/// - Code blocks: skipped (omitted from TTS)
/// - LaTeX: replaced with "[mathematical expression]"
/// - Lists: extracts list item text
/// - Images: extracts alt text
/// - Tables: extracts cell content
/// - Bold/Italic/Strikethrough/Underline: extracts inner text
/// - Block quotes: extracts text
/// - Horizontal lines: adds separator
/// - Checkboxes/Radio buttons: extracts text
/// - Highlighted text: extracts text
/// - Source tags: skipped
///
/// Example:
/// ```dart
/// final markdown = "# Hello\nThis is **bold** text with a [link](https://example.com)";
/// final plainText = gptMarkdownToPlainText(markdown);
/// // Result: "Hello\nThis is bold text with a link"
/// ```
///
/// [markdown] - The markdown text to convert
/// [useDollarSignsForLatex] - Whether to handle dollar signs for LaTeX (default: false)
///
/// Returns a plain text string suitable for TTS with normalized spacing
String gptMarkdownToPlainText(
  String markdown, {
  bool useDollarSignsForLatex = false,
}) {
  String text = markdown.trim();

  // Handle dollar sign LaTeX conversion (same as GptMarkdown widget)
  if (useDollarSignsForLatex) {
    text = text.replaceAllMapped(
      RegExp(r"(?<!\\)\$\$(.*?)(?<!\\)\$\$", dotAll: true),
      (match) => "\\[${match[1] ?? ""}\\]",
    );
    if (!text.contains(r"\(")) {
      text = text.replaceAllMapped(
        RegExp(r"(?<!\\)\$(.*?)(?<!\\)\$"),
        (match) => "\\(${match[1] ?? ""}\\)",
      );
      text = text.splitMapJoin(
        RegExp(r"\[.*?\]|\(.*?\)"),
        onNonMatch: (p0) {
          return p0.replaceAll("\\\$", "\$");
        },
      );
    }
  }

  final raw = _extractPlainText(text, true);

  // Final cleanup for TTS - normalize spacing and newlines
  return raw
      .replaceAll(RegExp(r'[ \t]+'), ' ') // collapse spaces and tabs
      .replaceAll(RegExp(r'\n{3,}'), '\n\n') // max 2 newlines in a row
      .replaceAll(
        RegExp(r'\n\s*\n\s*\n'),
        '\n\n',
      ) // remove triple newlines with spaces
      .replaceAll(
        RegExp(r'^\s+$', multiLine: true),
        '',
      ) // remove lines with only whitespace
      .trim();
}

/// Represents a speech block for TTS reading
class SpeechBlock {
  /// The text content of this block
  final String text;

  /// The paragraph index this block belongs to (for reference)
  final int paragraphIndex;

  /// The sentence index within the paragraph (0-based)
  final int sentenceIndex;

  /// Creates a speech block with the given text
  SpeechBlock(this.text, [this.paragraphIndex = 0, this.sentenceIndex = 0]);
}

/// Splits text into sentences for smoother TTS reading.
///
/// Sentences are split on sentence-ending punctuation (. ! ?) followed by whitespace.
/// Handles common abbreviations to avoid false splits.
///
/// Example:
/// ```dart
/// final sentences = splitIntoSentences("Hello world. How are you? I'm fine!");
/// // Returns: ["Hello world.", "How are you?", "I'm fine!"]
/// ```
///
/// [text] - The text to split into sentences
///
/// Returns a list of sentences
List<String> splitIntoSentences(String text) {
  if (text.trim().isEmpty) return [];

  // Common abbreviations that shouldn't split sentences
  // Add more as needed: Dr., Mr., Mrs., Ms., Prof., etc., U.S.A., a.m., p.m., etc.
  final abbreviations = [
    r'Dr\.',
    r'Mr\.',
    r'Mrs\.',
    r'Ms\.',
    r'Prof\.',
    r'etc\.',
    r'U\.S\.A\.',
    r'U\.S\.',
    r'a\.m\.',
    r'p\.m\.',
    r'e\.g\.',
    r'i\.e\.',
    r'vs\.',
    r'Inc\.',
    r'Ltd\.',
    r'Jr\.',
    r'Sr\.',
    r'Ph\.D\.',
  ];

  // Temporarily replace abbreviations with placeholders
  final Map<String, String> replacements = {};
  String processedText = text;

  for (int i = 0; i < abbreviations.length; i++) {
    final abbrev = abbreviations[i];
    final placeholder = '__ABBREV_${i}__';
    final regex = RegExp(abbrev, caseSensitive: false);
    processedText = processedText.replaceAllMapped(regex, (match) {
      replacements[placeholder] = match.group(0)!;
      return placeholder;
    });
  }

  // Split on sentence-ending punctuation followed by whitespace
  // (?<=[.!?]) - positive lookbehind for sentence endings
  // \s+ - one or more whitespace characters
  final parts = processedText.split(RegExp(r'(?<=[.!?])\s+'));

  // Restore abbreviations and clean up
  return parts
      .map((p) {
        // Restore abbreviations
        String restored = p;
        replacements.forEach((placeholder, original) {
          restored = restored.replaceAll(placeholder, original);
        });
        return restored.trim();
      })
      .where((p) => p.isNotEmpty)
      .toList();
}

/// Splits markdown text into blocks (same logic as MdWidget for accurate highlighting).
///
/// This splits the raw markdown first, then extracts text from each block.
/// This ensures block indices match between rendering and TTS.
///
/// [markdown] - The markdown text to convert
/// [useDollarSignsForLatex] - Whether to handle dollar signs for LaTeX (default: false)
///
/// Returns a list of speech blocks ready for TTS, with indices matching rendered blocks
List<SpeechBlock> gptMarkdownToSpeechBlocks(
  String markdown, {
  bool useDollarSignsForLatex = false,
}) {
  String text = markdown.trim();

  // Handle dollar sign LaTeX conversion (same as GptMarkdown widget)
  if (useDollarSignsForLatex) {
    text = text.replaceAllMapped(
      RegExp(r"(?<!\\)\$\$(.*?)(?<!\\)\$\$", dotAll: true),
      (match) => "\\[${match[1] ?? ""}\\]",
    );
    if (!text.contains(r"\(")) {
      text = text.replaceAllMapped(
        RegExp(r"(?<!\\)\$(.*?)(?<!\\)\$"),
        (match) => "\\(${match[1] ?? ""}\\)",
      );
      text = text.splitMapJoin(
        RegExp(r"\[.*?\]|\(.*?\)"),
        onNonMatch: (p0) {
          return p0.replaceAll("\\\$", "\$");
        },
      );
    }
  }

  if (text.isEmpty) return [];

  // Split markdown into blocks FIRST (same as MdWidget._splitIntoBlocks)
  // This ensures block indices match between rendering and TTS
  final markdownBlocks =
      text
          .split(RegExp(r'\n\s*\n+'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();

  if (markdownBlocks.isEmpty) return [];

  // Extract plain text from each markdown block separately
  // Then split each paragraph into sentences for smoother TTS
  final speechBlocks = <SpeechBlock>[];
  int paragraphIndex = 0;

  for (final markdownBlock in markdownBlocks) {
    final plainText = gptMarkdownToPlainText(
      markdownBlock,
      useDollarSignsForLatex: false, // Already processed above
    );

    // Clean up the extracted text
    final cleaned =
        plainText
            .replaceAll(RegExp(r'[ \t]+'), ' ') // collapse spaces
            .replaceAll(RegExp(r'\n{3,}'), '\n\n') // max 2 newlines
            .trim();

    if (cleaned.isNotEmpty) {
      // Split paragraph into sentences for sentence-by-sentence reading
      final sentences = splitIntoSentences(cleaned);

      if (sentences.isNotEmpty) {
        // Create a speech block for each sentence, tracking sentence index within paragraph
        for (
          int sentenceIndex = 0;
          sentenceIndex < sentences.length;
          sentenceIndex++
        ) {
          speechBlocks.add(
            SpeechBlock(
              sentences[sentenceIndex],
              paragraphIndex,
              sentenceIndex,
            ),
          );
        }
      } else {
        // If no sentence endings found, treat the whole paragraph as one block
        speechBlocks.add(SpeechBlock(cleaned, paragraphIndex, 0));
      }
    }

    paragraphIndex++;
  }

  return speechBlocks;
}

/// Internal function to extract plain text from markdown using the same component logic
String _extractPlainText(String text, bool includeGlobalComponents) {
  final components =
      includeGlobalComponents
          ? MarkdownComponent.globalComponents
          : MarkdownComponent.inlineComponents;

  final buffer = StringBuffer();
  final regexes = components.map<String>((e) => e.exp.pattern);
  final combinedRegex = RegExp(
    regexes.join("|"),
    multiLine: true,
    dotAll: true,
  );

  text.splitMapJoin(
    combinedRegex,
    onMatch: (match) {
      final element = match[0] ?? "";

      // Try to match each component
      for (final component in components) {
        final exp = RegExp(
          '^${component.exp.pattern}\$',
          multiLine: component.exp.isMultiLine,
          dotAll: component.exp.isDotAll,
        );

        if (exp.hasMatch(element)) {
          final extracted = _extractTextFromComponent(
            component,
            element,
            includeGlobalComponents,
          );
          buffer.write(extracted);
          return "";
        }
      }
      return "";
    },
    onNonMatch: (nonMatch) {
      if (nonMatch.isEmpty) {
        return "";
      }
      if (includeGlobalComponents) {
        // Recursively process inline components
        buffer.write(_extractPlainText(nonMatch, false));
        return "";
      }
      // Plain text - add as is
      buffer.write(nonMatch);
      return "";
    },
  );

  return buffer.toString();
}

/// Extracts plain text from a specific markdown component
String _extractTextFromComponent(
  MarkdownComponent component,
  String text,
  bool includeGlobalComponents,
) {
  // Handle block components
  if (component is BlockMd) {
    return _extractTextFromBlockComponent(
      component,
      text,
      includeGlobalComponents,
    );
  }

  // Handle inline components
  if (component is InlineMd) {
    return _extractTextFromInlineComponent(
      component,
      text,
      includeGlobalComponents,
    );
  }

  return "";
}

/// Extracts text from block components
String _extractTextFromBlockComponent(
  MarkdownComponent component,
  String text,
  bool includeGlobalComponents,
) {
  // Headings
  if (component is HTag) {
    final match = RegExp(
      r"(?<hash>#{1,6})\ (?<data>[^\n]+?)$",
    ).firstMatch(text.trim());
    if (match != null) {
      final data = match.namedGroup('data') ?? "";
      return "${_extractPlainText(data, false)}\n";
    }
  }

  // Code blocks
  if (component is CodeBlockMd) {
    // Skip code blocks in TTS for cleaner speech
    // Code is typically not useful for text-to-speech
    return "";
  }

  // Unordered lists
  if (component is UnOrderedList) {
    final match = RegExp(r"(?:\-|\*)\ ([^\n]+)$").firstMatch(text);
    if (match != null) {
      final item = match[1]?.trim() ?? "";
      return "• ${_extractPlainText(item, false)}";
    }
  }

  // Ordered lists
  if (component is OrderedList) {
    final match = RegExp(r"([0-9]+)\.\ ([^\n]+)$").firstMatch(text);
    if (match != null) {
      final number = match[1] ?? "";
      final item = match[2]?.trim() ?? "";
      return "$number. ${_extractPlainText(item, false)}";
    }
  }

  // Checkboxes
  if (component is CheckBoxMd) {
    final match = RegExp(
      r"\[((?:\x|\ ))\]\ (\S[^\n]*?)$",
    ).firstMatch(text.trim());
    if (match != null) {
      final item = match[2]?.trim() ?? "";
      return "${_extractPlainText(item, false)}\n";
    }
  }

  // Radio buttons
  if (component is RadioButtonMd) {
    final match = RegExp(
      r"\(((?:\x|\ ))\)\ (\S[^\n]*)$",
    ).firstMatch(text.trim());
    if (match != null) {
      final item = match[2]?.trim() ?? "";
      return "${_extractPlainText(item, false)}\n";
    }
  }

  // Horizontal lines
  if (component is HrLine) {
    // Skip horizontal lines in TTS - they're visual separators, not meant to be read
    return "";
  }

  // Block quotes
  if (component is BlockQuote) {
    final match = RegExp(
      r"(?:(?:^)\ *>[^\n]+)(?:(?:\n)\ *>[^\n]+)*",
      dotAll: true,
      multiLine: true,
    ).firstMatch(text);
    if (match != null) {
      final dataBuilder = StringBuffer();
      final m = match[0] ?? '';
      for (final line in m.split('\n')) {
        if (line.startsWith(RegExp(r'\ *>'))) {
          var subString = line.trimLeft().substring(1);
          if (subString.startsWith(' ')) {
            subString = subString.substring(1);
          }
          dataBuilder.writeln(subString);
        } else {
          dataBuilder.writeln(line);
        }
      }
      final data = dataBuilder.toString().trim();
      return "${_extractPlainText(data, true)}\n";
    }
  }

  // Tables
  if (component is TableMd) {
    final lines = text.split('\n').where((e) => e.trim().isNotEmpty).toList();
    final buffer = StringBuffer();
    for (final line in lines) {
      final cells = line.trim().split('|').where((e) => e.isNotEmpty).toList();
      if (cells.isNotEmpty) {
        // Skip separator rows (containing only dashes and colons)
        final isSeparator = cells.every(
          (cell) => RegExp(r"^:?[-:]+:?$").hasMatch(cell.trim()),
        );
        if (!isSeparator) {
          final cellTexts = cells
              .map((cell) => _extractPlainText(cell.trim(), false))
              .join(" | ");
          buffer.writeln(cellTexts);
        }
      }
    }
    return buffer.toString();
  }

  // Indent
  if (component is IndentMd) {
    final match = RegExp(r"^(\ \ +)([^\n]+)$").firstMatch(text);
    if (match != null) {
      final content = match[2]?.trim() ?? "";
      return "${_extractPlainText(content, false)}\n";
    }
  }

  // LaTeX multiline
  if (component is LatexMathMultiLine) {
    // Replace LaTeX with placeholder so TTS acknowledges math content
    return " [mathematical expression] ";
  }

  // New lines
  if (component is NewLines) {
    return "\n\n";
  }

  return "";
}

/// Extracts text from inline components
String _extractTextFromInlineComponent(
  MarkdownComponent component,
  String text,
  bool includeGlobalComponents,
) {
  // Bold
  if (component is BoldMd) {
    final match = RegExp(
      r"(?<!\*)\*\*(?<!\s)(.+?)(?<!\s)\*\*(?!\*)",
    ).firstMatch(text.trim());
    if (match != null) {
      return _extractPlainText(match[1] ?? "", false);
    }
  }

  // Italic
  if (component is ItalicMd) {
    final match = RegExp(
      r"(?:(?<!\*)\*(?<!\s)(.+?)(?<!\s)\*(?!\*))",
      dotAll: true,
    ).firstMatch(text.trim());
    if (match != null) {
      final data = match[1] ?? match[2];
      return _extractPlainText(data ?? "", false);
    }
  }

  // Strikethrough
  if (component is StrikeMd) {
    final match = RegExp(
      r"(?<!\*)\~\~(?<!\s)(.+?)(?<!\s)\~\~(?!\*)",
    ).firstMatch(text.trim());
    if (match != null) {
      return _extractPlainText(match[1] ?? "", false);
    }
  }

  // Underline
  if (component is UnderLineMd) {
    final match = RegExp(
      r"<u>(.*?)(?:</u>|$)",
      multiLine: true,
      dotAll: true,
    ).firstMatch(text.trim());
    if (match != null) {
      return _extractPlainText(match[1] ?? "", false);
    }
  }

  // Highlighted text (code spans)
  if (component is HighlightedText) {
    final match = RegExp(r"`(?!`)(.+?)(?<!`)`(?!`)").firstMatch(text.trim());
    if (match != null) {
      return match[1] ?? "";
    }
  }

  // Links
  if (component is ATagMd) {
    // Extract link text, not URL
    var bracketCount = 0;
    var start = 1;
    var end = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '[') {
        bracketCount++;
      } else if (text[i] == ']') {
        bracketCount--;
        if (bracketCount == 0) {
          end = i;
          break;
        }
      }
    }
    if (end > 0 && text.length > end + 1 && text[end + 1] == '(') {
      final linkText = text.substring(start, end);
      return _extractPlainText(linkText, false);
    }
  }

  // Images
  if (component is ImageMd) {
    final match = RegExp(r'\!\[([^\[\]]*)\]\(').firstMatch(text.trim());
    if (match != null) {
      final altText = match[1] ?? "";
      // Extract size info if present
      final sizeMatch = RegExp(
        r"^([0-9]+)?x?([0-9]+)?",
      ).firstMatch(altText.trim());
      if (sizeMatch != null && (sizeMatch[1] != null || sizeMatch[2] != null)) {
        // Has size info, skip for TTS
        return "";
      }
      return altText.isNotEmpty ? "Image: $altText" : "Image";
    }
  }

  // Inline LaTeX
  if (component is LatexMath) {
    // Replace LaTeX with placeholder so TTS acknowledges math content
    return " [mathematical expression] ";
  }

  // Source tags
  if (component is SourceTag) {
    // Skip source tags for TTS
    return "";
  }

  return "";
}
