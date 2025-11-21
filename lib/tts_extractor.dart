import 'package:flutter/foundation.dart';

/// Comprehensive plain text extractor optimized for Google TTS
///
/// This improves upon the existing gptMarkdownToPlainText function with:
/// - Better handling of special characters
/// - Improved punctuation for natural speech
/// - Smart handling of lists, headings, and formatting
/// - Removal of visual-only elements
/// - Proper spacing for TTS pauses
class TTSPlainTextExtractor {
  /// Extract plain text from markdown optimized for Google TTS
  ///
  /// Features:
  /// - Converts headings to natural speech ("Heading: Title")
  /// - Adds proper pauses with punctuation
  /// - Handles lists with natural flow
  /// - Removes code blocks (not useful for TTS)
  /// - Converts LaTeX to "[math expression]"
  /// - Preserves important punctuation
  /// - Removes URLs but keeps link text
  /// - Smart emoji handling (optional)
  static String extract(
    String markdown, {
    bool removeEmojis = true,
    bool addHeadingLabels = true,
    bool addListMarkers = true,
    bool speakLinkUrls = false,
    bool useDollarSignsForLatex = false,
  }) {
    if (markdown.trim().isEmpty) return '';

    String text = markdown.trim();

    // Step 1: Handle LaTeX dollar signs if needed
    if (useDollarSignsForLatex) {
      text = _convertDollarSignLatex(text);
    }

    // Step 2: Remove code blocks (not useful for TTS)
    text = _removeCodeBlocks(text);

    // Step 3: Convert LaTeX to readable text
    text = _convertLatexToSpeech(text);

    // Step 4: Handle headings with labels
    if (addHeadingLabels) {
      text = _convertHeadings(text);
    } else {
      text = _removeHeadingHashes(text);
    }

    // Step 5: Handle links (keep text, optionally speak URL)
    text = _handleLinks(text, speakLinkUrls);

    // Step 6: Handle images (use alt text)
    text = _handleImages(text);

    // Step 7: Handle lists with natural flow
    text = _handleLists(text, addListMarkers);

    // Step 8: Handle blockquotes
    text = _handleBlockquotes(text);

    // Step 9: Handle tables
    text = _handleTables(text);

    // Step 10: Remove formatting (bold, italic, strikethrough)
    text = _removeFormatting(text);

    // Step 11: Handle horizontal rules
    text = _removeHorizontalRules(text);

    // Step 12: Remove emojis if requested
    if (removeEmojis) {
      text = _removeEmojis(text);
    }

    // Step 13: Clean up spacing and punctuation
    text = _cleanupSpacing(text);

    // Step 14: Final TTS-friendly cleanup
    text = _finalCleanup(text);

    return text.trim();
  }

  /// Convert dollar sign LaTeX to bracket notation
  static String _convertDollarSignLatex(String text) {
    // Display math: $$...$$ -> \[...\]
    text = text.replaceAllMapped(
      RegExp(r'(?<!\\)\$\$(.*?)(?<!\\)\$\$', dotAll: true),
      (match) => '\\[${match[1] ?? ''}\\]',
    );

    // Inline math: $...$ -> \(...\)
    if (!text.contains(r'\(')) {
      text = text.replaceAllMapped(
        RegExp(r'(?<!\\)\$(.*?)(?<!\\)\$'),
        (match) => '\\(${match[1] ?? ''}\\)',
      );
      text = text.splitMapJoin(
        RegExp(r'\[.*?\]|\(.*?\)'),
        onNonMatch: (p0) => p0.replaceAll(r'\$', r'$'),
      );
    }

    return text;
  }

  /// Remove code blocks (they're not useful for TTS)
  static String _removeCodeBlocks(String text) {
    // Remove fenced code blocks
    text = text.replaceAll(RegExp(r'```[\s\S]*?```', multiLine: true), '');

    // Remove indented code blocks (4 spaces or tab)
    text = text.replaceAll(RegExp(r'^(?: {4}|\t).*$', multiLine: true), '');

    // Remove inline code (keep the text inside)
    text = text.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => match[1] ?? '',
    );

    return text;
  }

  /// Convert LaTeX to speech-friendly text
  static String _convertLatexToSpeech(String text) {
    // Display math: \[...\]
    text = text.replaceAll(
      RegExp(r'\\\[(.*?)\\\]', dotAll: true),
      ' mathematical expression. ',
    );

    // Inline math: \(...\)
    text = text.replaceAll(
      RegExp(r'\\\((.*?)\\\)', dotAll: true),
      ' math expression ',
    );

    // Environment blocks: \begin{...}...\end{...}
    text = text.replaceAll(
      RegExp(r'\\begin\{.*?\}.*?\\end\{.*?\}', dotAll: true),
      ' mathematical expression. ',
    );

    return text;
  }

  /// Convert headings to natural speech
  static String _convertHeadings(String text) {
    // H1: # Title -> "Heading: Title."
    text = text.replaceAllMapped(
      RegExp(r'^# (.+)$', multiLine: true),
      (match) => 'Heading: ${match[1]}.',
    );

    // H2: ## Title -> "Subheading: Title."
    text = text.replaceAllMapped(
      RegExp(r'^## (.+)$', multiLine: true),
      (match) => 'Subheading: ${match[1]}.',
    );

    // H3-H6: ### Title -> "Section: Title."
    text = text.replaceAllMapped(
      RegExp(r'^#{3,6} (.+)$', multiLine: true),
      (match) => 'Section: ${match[1]}.',
    );

    return text;
  }

  /// Remove heading hashes without labels
  static String _removeHeadingHashes(String text) {
    return text.replaceAllMapped(
      RegExp(r'^#{1,6} (.+)$', multiLine: true),
      (match) => '${match[1]}.',
    );
  }

  /// Handle links (keep text, optionally speak URL)
  static String _handleLinks(String text, bool speakUrls) {
    if (speakUrls) {
      // [text](url) -> "text, link to url"
      text = text.replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\(([^\)]+)\)'),
        (match) => '${match[1]}, link to ${match[2]}',
      );
    } else {
      // [text](url) -> "text"
      text = text.replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
        (match) => match[1] ?? '',
      );
    }

    // Remove reference-style links: [text][ref]
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\[[^\]]*\]'),
      (match) => match[1] ?? '',
    );

    // Remove link definitions: [ref]: url
    text = text.replaceAll(RegExp(r'^\[.+?\]:\s*.+$', multiLine: true), '');

    return text;
  }

  /// Handle images (use alt text)
  static String _handleImages(String text) {
    // ![alt](url) -> "Image: alt"
    text = text.replaceAllMapped(RegExp(r'!\[([^\]]*)\]\([^\)]+\)'), (match) {
      final alt = match[1]?.trim() ?? '';
      return alt.isNotEmpty ? 'Image: $alt.' : '';
    });

    return text;
  }

  /// Handle lists with natural flow
  static String _handleLists(String text, bool addMarkers) {
    if (addMarkers) {
      // Unordered lists: - item -> "• item"
      text = text.replaceAllMapped(
        RegExp(r'^[\*\-\+] (.+)$', multiLine: true),
        (match) => '• ${match[1]}',
      );

      // Ordered lists: 1. item -> "1. item"
      text = text.replaceAllMapped(
        RegExp(r'^(\d+)\. (.+)$', multiLine: true),
        (match) => '${match[1]}. ${match[2]}',
      );
    } else {
      // Remove list markers
      text = text.replaceAll(RegExp(r'^[\*\-\+] ', multiLine: true), '');
      text = text.replaceAll(RegExp(r'^\d+\. ', multiLine: true), '');
    }

    // Task lists: - [ ] item -> "Unchecked: item"
    text = text.replaceAllMapped(
      RegExp(r'^[\*\-\+] \[ \] (.+)$', multiLine: true),
      (match) => 'Unchecked: ${match[1]}',
    );

    // Checked tasks: - [x] item -> "Checked: item"
    text = text.replaceAllMapped(
      RegExp(r'^[\*\-\+] \[[xX]\] (.+)$', multiLine: true),
      (match) => 'Checked: ${match[1]}',
    );

    return text;
  }

  /// Handle blockquotes
  static String _handleBlockquotes(String text) {
    // Remove > markers but keep content
    text = text.replaceAllMapped(
      RegExp(r'^> (.+)$', multiLine: true),
      (match) => match[1] ?? '',
    );

    return text;
  }

  /// Handle tables (extract cell content)
  static String _handleTables(String text) {
    final lines = text.split('\n');
    final buffer = StringBuffer();
    bool inTable = false;

    for (final line in lines) {
      // Check if it's a table row
      if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
        // Skip separator rows (|---|---|)
        if (RegExp(r'^\|[\s\-:]+\|$').hasMatch(line.trim())) {
          continue;
        }

        inTable = true;
        // Extract cells
        final cells = line
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .join(', ');

        if (cells.isNotEmpty) {
          buffer.writeln(cells);
        }
      } else {
        if (inTable) {
          buffer.writeln(); // Add spacing after table
          inTable = false;
        }
        buffer.writeln(line);
      }
    }

    return buffer.toString();
  }

  /// Remove formatting (bold, italic, strikethrough)
  static String _removeFormatting(String text) {
    // Bold: **text** or __text__
    text = text.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'__([^_]+)__'), r'$1');

    // Italic: *text* or _text_
    text = text.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    text = text.replaceAll(RegExp(r'_([^_]+)_'), r'$1');

    // Strikethrough: ~~text~~
    text = text.replaceAll(RegExp(r'~~([^~]+)~~'), r'$1');

    // Highlight: ==text==
    text = text.replaceAll(RegExp(r'==([^=]+)=='), r'$1');

    return text;
  }

  /// Remove horizontal rules
  static String _removeHorizontalRules(String text) {
    // Remove ---, ***, ___
    text = text.replaceAll(RegExp(r'^[\-\*_]{3,}$', multiLine: true), '');
    return text;
  }

  /// Remove emojis
  static String _removeEmojis(String text) {
    // Remove emoji shortcodes: :smile:
    text = text.replaceAll(RegExp(r':[a-z_]+:'), '');

    // Remove Unicode emojis
    text = text.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}'
        r'\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}'
        r'\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FAFF}]',
        unicode: true,
      ),
      '',
    );

    return text;
  }

  /// Clean up spacing
  static String _cleanupSpacing(String text) {
    // Collapse multiple spaces
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');

    // Collapse multiple newlines (max 2)
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remove lines with only whitespace
    text = text.replaceAll(RegExp(r'^\s+$', multiLine: true), '');

    // Remove spaces before punctuation
    text = text.replaceAll(RegExp(r'\s+([.,!?;:])'), r'$1');

    // Add space after punctuation if missing
    text = text.replaceAll(RegExp(r'([.,!?;:])([A-Za-z])'), r'$1 $2');

    return text;
  }

  /// Final cleanup for TTS
  static String _finalCleanup(String text) {
    // Remove multiple consecutive punctuation
    text = text.replaceAll(RegExp(r'\.{2,}'), '.');
    text = text.replaceAll(RegExp(r',{2,}'), ',');

    // Ensure sentences end with punctuation
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9])\n'),
      (match) => '${match[1]}.\n',
    );

    // Remove empty lines at start/end
    text = text.trim();

    // Normalize newlines for TTS pauses
    text = text.replaceAll('\n\n', '. '); // Paragraph breaks
    text = text.replaceAll('\n', ' '); // Line breaks

    // Final space cleanup
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text;
  }

  /// Debug function to compare extraction
  static void debug(String markdown) {
    if (kDebugMode) {
      debugPrint('====== MARKDOWN ======');
      debugPrint(markdown);
      debugPrint('\n====== EXTRACTED TTS TEXT ======');
      final extracted = extract(markdown);
      debugPrint(extracted);
      debugPrint('\n====== CHARACTER COUNT ======');
      debugPrint('Original: ${markdown.length}');
      debugPrint('Extracted: ${extracted.length}');
      debugPrint('====== END ======\n');
    }
  }
}
