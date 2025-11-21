import 'package:flutter/foundation.dart';

/// Voice-optimized TTS extractor with premium features
/// Converts markdown to natural, voice-friendly speech text
class VoiceOptimizedTTS {
  /// Extract voice-optimized text from markdown
  ///
  /// This goes beyond plain text extraction to create text that sounds
  /// natural when spoken by TTS engines like Google TTS.
  static String extract(
    String markdown, {
    bool addNaturalPauses = true,
    bool expandAbbreviations = true,
    bool speakNumbers = true,
    bool addContext = true,
  }) {
    if (markdown.trim().isEmpty) return '';

    String text = markdown;

    // Step 1: Remove code blocks (not useful for voice)
    text = _removeCodeBlocks(text);

    // Step 2: Convert LaTeX to spoken math
    text = _convertLatexToSpeech(text);

    // Step 3: Handle headings with natural speech
    if (addContext) {
      text = _convertHeadingsToSpeech(text);
    } else {
      text = _removeHeadingMarkers(text);
    }

    // Step 4: Handle links naturally
    text = _handleLinksForSpeech(text);

    // Step 5: Handle images
    text = _handleImagesForSpeech(text);

    // Step 6: Handle lists naturally
    text = _handleListsForSpeech(text);

    // Step 7: Handle blockquotes
    text = _handleBlockquotesForSpeech(text);

    // Step 8: Handle tables
    text = _handleTablesForSpeech(text);

    // Step 9: Remove formatting
    text = _removeFormatting(text);

    // Step 10: Expand abbreviations
    if (expandAbbreviations) {
      text = _expandAbbreviations(text);
    }

    // Step 11: Handle numbers naturally
    if (speakNumbers) {
      text = _handleNumbers(text);
    }

    // Step 12: Add natural pauses
    if (addNaturalPauses) {
      text = _addNaturalPauses(text);
    }

    // Step 13: Clean up
    text = _finalCleanup(text);

    return text.trim();
  }

  static String _removeCodeBlocks(String text) {
    // Remove fenced code blocks
    text = text.replaceAll(RegExp(r'```[\s\S]*?```', multiLine: true), '');
    // Remove inline code
    text = text.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m[1] ?? '');
    return text;
  }

  static String _convertLatexToSpeech(String text) {
    // Display math
    text = text.replaceAll(
      RegExp(r'\\\[(.*?)\\\]', dotAll: true),
      ' Here is a mathematical expression. ',
    );
    // Inline math
    text = text.replaceAll(
      RegExp(r'\\\((.*?)\\\)', dotAll: true),
      ' a math expression ',
    );
    return text;
  }

  static String _convertHeadingsToSpeech(String text) {
    // H1: # Title -> "Chapter: Title"
    text = text.replaceAllMapped(
      RegExp(r'^# (.+)$', multiLine: true),
      (m) => 'Chapter: ${m[1]}.',
    );
    // H2: ## Title -> "Section: Title"
    text = text.replaceAllMapped(
      RegExp(r'^## (.+)$', multiLine: true),
      (m) => 'Section: ${m[1]}.',
    );
    // H3+: ### Title -> "Subsection: Title"
    text = text.replaceAllMapped(
      RegExp(r'^#{3,6} (.+)$', multiLine: true),
      (m) => 'Subsection: ${m[1]}.',
    );
    return text;
  }

  static String _removeHeadingMarkers(String text) {
    return text.replaceAllMapped(
      RegExp(r'^#{1,6} (.+)$', multiLine: true),
      (m) => '${m[1]}.',
    );
  }

  static String _handleLinksForSpeech(String text) {
    // [text](url) -> just "text"
    return text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
      (m) => m[1] ?? '',
    );
  }

  static String _handleImagesForSpeech(String text) {
    // ![alt](url) -> "Image showing alt"
    return text.replaceAllMapped(RegExp(r'!\[([^\]]*)\]\([^\)]+\)'), (m) {
      final alt = m[1]?.trim() ?? '';
      return alt.isNotEmpty ? 'Image showing $alt.' : '';
    });
  }

  static String _handleListsForSpeech(String text) {
    // Unordered lists: - item -> "Item: item"
    text = text.replaceAllMapped(
      RegExp(r'^[\*\-\+] (.+)$', multiLine: true),
      (m) => 'Item: ${m[1]}',
    );
    // Ordered lists: 1. item -> "First, item"
    text = text.replaceAllMapped(RegExp(r'^(\d+)\. (.+)$', multiLine: true), (
      m,
    ) {
      final num = int.tryParse(m[1] ?? '1') ?? 1;
      final ordinal = _toOrdinal(num);
      return '$ordinal, ${m[2]}';
    });
    // Task lists
    text = text.replaceAllMapped(
      RegExp(r'^[\*\-\+] \[ \] (.+)$', multiLine: true),
      (m) => 'To do: ${m[1]}',
    );
    text = text.replaceAllMapped(
      RegExp(r'^[\*\-\+] \[[xX]\] (.+)$', multiLine: true),
      (m) => 'Completed: ${m[1]}',
    );
    return text;
  }

  static String _toOrdinal(int number) {
    if (number <= 0) return 'Item';
    if (number == 1) return 'First';
    if (number == 2) return 'Second';
    if (number == 3) return 'Third';
    if (number == 4) return 'Fourth';
    if (number == 5) return 'Fifth';
    if (number == 6) return 'Sixth';
    if (number == 7) return 'Seventh';
    if (number == 8) return 'Eighth';
    if (number == 9) return 'Ninth';
    if (number == 10) return 'Tenth';
    return 'Item $number';
  }

  static String _handleBlockquotesForSpeech(String text) {
    // > quote -> "Quote: quote"
    return text.replaceAllMapped(
      RegExp(r'^> (.+)$', multiLine: true),
      (m) => 'Quote: ${m[1]}',
    );
  }

  static String _handleTablesForSpeech(String text) {
    final lines = text.split('\n');
    final buffer = StringBuffer();
    bool inTable = false;
    bool isFirstRow = true;

    for (final line in lines) {
      if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
        // Skip separator rows
        if (RegExp(r'^\|[\s\-:]+\|$').hasMatch(line.trim())) {
          continue;
        }

        inTable = true;
        final cells =
            line
                .split('|')
                .map((c) => c.trim())
                .where((c) => c.isNotEmpty)
                .toList();

        if (cells.isNotEmpty) {
          if (isFirstRow) {
            buffer.writeln('Table with columns: ${cells.join(", ")}.');
            isFirstRow = false;
          } else {
            buffer.writeln('Row: ${cells.join(", ")}.');
          }
        }
      } else {
        if (inTable) {
          buffer.writeln('End of table.');
          inTable = false;
          isFirstRow = true;
        }
        buffer.writeln(line);
      }
    }

    return buffer.toString();
  }

  static String _removeFormatting(String text) {
    // Bold, italic, strikethrough
    text = text.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    text = text.replaceAll(RegExp(r'_([^_]+)_'), r'$1');
    text = text.replaceAll(RegExp(r'~~([^~]+)~~'), r'$1');
    text = text.replaceAll(RegExp(r'==([^=]+)=='), r'$1');
    return text;
  }

  static String _expandAbbreviations(String text) {
    final abbreviations = {
      r'\bDr\.': 'Doctor',
      r'\bMr\.': 'Mister',
      r'\bMrs\.': 'Missus',
      r'\bMs\.': 'Miss',
      r'\betc\.': 'et cetera',
      r'\be\.g\.': 'for example',
      r'\bi\.e\.': 'that is',
      r'\bvs\.': 'versus',
      r'\bInc\.': 'Incorporated',
      r'\bLtd\.': 'Limited',
      r'\bCo\.': 'Company',
      r'\bUSA\b': 'United States of America',
      r'\bUK\b': 'United Kingdom',
      r'\bAPI\b': 'A P I',
      r'\bURL\b': 'U R L',
      r'\bHTML\b': 'H T M L',
      r'\bCSS\b': 'C S S',
      r'\bJS\b': 'JavaScript',
      r'\bSQL\b': 'S Q L',
      r'\bAI\b': 'A I',
      r'\bML\b': 'M L',
    };

    abbreviations.forEach((pattern, replacement) {
      text = text.replaceAll(RegExp(pattern), replacement);
    });

    return text;
  }

  static String _handleNumbers(String text) {
    // Add commas to large numbers for better speech
    text = text.replaceAllMapped(RegExp(r'\b(\d{4,})\b'), (m) {
      final num = m[1]!;
      // Add commas: 1000 -> 1,000
      return num.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    });

    // Handle percentages
    text = text.replaceAllMapped(RegExp(r'(\d+)%'), (m) => '${m[1]} percent');

    // Handle degrees
    text = text.replaceAllMapped(RegExp(r'(\d+)°'), (m) => '${m[1]} degrees');

    return text;
  }

  static String _addNaturalPauses(String text) {
    // Add pause after sentences
    text = text.replaceAll(RegExp(r'([.!?])\s+'), r'$1 ');

    // Add pause after colons
    text = text.replaceAll(RegExp(r':\s+'), ': ');

    // Add pause after commas
    text = text.replaceAll(RegExp(r',\s+'), ', ');

    // Add pause between paragraphs
    text = text.replaceAll('\n\n', '. ');

    return text;
  }

  static String _finalCleanup(String text) {
    // Collapse spaces
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');

    // Remove empty lines
    text = text.replaceAll(RegExp(r'^\s+$', multiLine: true), '');

    // Normalize newlines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remove spaces before punctuation
    text = text.replaceAll(RegExp(r'\s+([.,!?;:])'), r'$1');

    // Ensure space after punctuation
    text = text.replaceAll(RegExp(r'([.,!?;:])([A-Za-z])'), r'$1 $2');

    // Remove multiple punctuation
    text = text.replaceAll(RegExp(r'\.{2,}'), '.');

    // Final trim
    return text.trim();
  }

  /// Debug comparison
  static void debug(String markdown) {
    if (kDebugMode) {
      debugPrint('====== MARKDOWN ======');
      debugPrint(markdown);
      debugPrint('\n====== VOICE-OPTIMIZED TTS ======');
      final tts = extract(markdown);
      debugPrint(tts);
      debugPrint('\n====== STATS ======');
      debugPrint('Original: ${markdown.length} chars');
      debugPrint('Optimized: ${tts.length} chars');
      debugPrint('Words: ${tts.split(RegExp(r'\s+')).length}');
      debugPrint('====== END ======\n');
    }
  }
}

/// SSML (Speech Synthesis Markup Language) generator for advanced TTS
class SSMLGenerator {
  /// Convert markdown to SSML for premium TTS control
  static String generate(
    String markdown, {
    String? voice,
    double rate = 1.0,
    double pitch = 1.0,
    double volume = 1.0,
  }) {
    final text = VoiceOptimizedTTS.extract(markdown);

    final buffer = StringBuffer();
    buffer.writeln('<speak>');

    // Voice settings
    if (voice != null) {
      buffer.writeln('  <voice name="$voice">');
    }

    // Prosody (rate, pitch, volume)
    buffer.writeln(
      '    <prosody rate="${rate}x" pitch="${pitch >= 1 ? '+' : ''}${((pitch - 1) * 100).toStringAsFixed(0)}%" volume="${(volume * 100).toStringAsFixed(0)}%">',
    );

    // Add pauses for better flow
    final sentences = text.split(RegExp(r'[.!?]\s+'));
    for (final sentence in sentences) {
      if (sentence.trim().isNotEmpty) {
        buffer.writeln('      $sentence.');
        buffer.writeln('      <break time="500ms"/>');
      }
    }

    buffer.writeln('    </prosody>');

    if (voice != null) {
      buffer.writeln('  </voice>');
    }

    buffer.writeln('</speak>');

    return buffer.toString();
  }

  /// Generate SSML with emphasis on headings
  static String generateWithEmphasis(String markdown) {
    String ssml = '<speak>';

    final lines = markdown.split('\n');
    for (final line in lines) {
      // Headings with emphasis
      final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (headingMatch != null) {
        final level = headingMatch[1]!.length;
        final text = headingMatch[2]!;
        final emphasis =
            level == 1 ? 'strong' : (level == 2 ? 'moderate' : 'none');

        ssml += '<emphasis level="$emphasis">$text</emphasis>';
        ssml += '<break time="800ms"/>';
        continue;
      }

      // Regular text
      if (line.trim().isNotEmpty) {
        ssml += line.trim();
        ssml += '<break time="400ms"/>';
      }
    }

    ssml += '</speak>';
    return ssml;
  }
}
