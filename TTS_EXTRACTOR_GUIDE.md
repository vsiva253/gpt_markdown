# TTS Plain Text Extractor - Complete Guide 🎙️

## 🎯 The CORE Functionality

This is the **most important** feature - extracting clean, natural text from markdown for Google TTS (Text-to-Speech).

---

## ✅ What It Does

Converts markdown to speech-friendly plain text through **14 processing steps**:

1. ✅ **LaTeX Conversion** - Handles `$` and `$$` notation
2. ✅ **Code Block Removal** - Removes code (not useful for TTS)
3. ✅ **LaTeX to Speech** - "mathematical expression"
4. ✅ **Heading Labels** - "Heading: Title"
5. ✅ **Link Handling** - Keeps text, removes URLs
6. ✅ **Image Handling** - "Image: alt text"
7. ✅ **List Processing** - Natural bullet points
8. ✅ **Blockquote Cleanup** - Removes `>` markers
9. ✅ **Table Extraction** - Cell content only
10. ✅ **Format Removal** - Bold, italic, strikethrough
11. ✅ **Horizontal Rules** - Removed (visual only)
12. ✅ **Emoji Removal** - Optional, prevents TTS issues
13. ✅ **Spacing Cleanup** - Proper punctuation
14. ✅ **Final TTS Cleanup** - Natural pauses

---

## 📝 Usage

### Basic Usage

```dart
import 'package:gpt_markdown/tts_extractor.dart';

// Extract plain text for TTS
final markdown = '''
# Hello World

This is **bold** text with a [link](https://example.com).

```python
print("code")
```

- Item 1
- Item 2
''';

final ttsText = TTSPlainTextExtractor.extract(markdown);
// Result: "Heading: Hello World. This is bold text with a link. Item 1 Item 2"
```

### Advanced Options

```dart
final ttsText = TTSPlainTextExtractor.extract(
  markdown,
  removeEmojis: true,           // Remove emojis (default: true)
  addHeadingLabels: true,        // "Heading: Title" (default: true)
  addListMarkers: true,          // Keep "•" markers (default: true)
  speakLinkUrls: false,          // Don't speak URLs (default: false)
  useDollarSignsForLatex: false, // Handle $ notation (default: false)
);
```

### Debug Mode

```dart
// See before/after comparison
TTSPlainTextExtractor.debug(markdown);
// Prints:
// ====== MARKDOWN ======
// [original markdown]
// ====== EXTRACTED TTS TEXT ======
// [extracted text]
// ====== CHARACTER COUNT ======
// Original: 150
// Extracted: 80
```

---

## 🔍 Processing Examples

### 1. Headings

**Input**:
```markdown
# Main Title
## Subtitle
### Section
```

**Output** (with labels):
```
Heading: Main Title.
Subheading: Subtitle.
Section: Section.
```

**Output** (without labels):
```
Main Title.
Subtitle.
Section.
```

---

### 2. LaTeX Math

**Input**:
```markdown
The formula is \\(E = mc^2\\) and the equation:

\\[
\\sum_{i=1}^{n} x_i = \\frac{n(n+1)}{2}
\\]
```

**Output**:
```
The formula is math expression and the equation: mathematical expression.
```

---

### 3. Code Blocks

**Input**:
````markdown
Here's some code:

```python
def hello():
    print("Hello")
```

And inline `code` too.
````

**Output**:
```
Here's some code: And inline code too.
```

---

### 4. Links

**Input**:
```markdown
Visit [Google](https://google.com) for search.
```

**Output** (speakLinkUrls: false):
```
Visit Google for search.
```

**Output** (speakLinkUrls: true):
```
Visit Google, link to https://google.com for search.
```

---

### 5. Images

**Input**:
```markdown
![Beautiful sunset](image.jpg)
```

**Output**:
```
Image: Beautiful sunset.
```

---

### 6. Lists

**Input**:
```markdown
- First item
- Second item
- [ ] Unchecked task
- [x] Checked task

1. Ordered one
2. Ordered two
```

**Output** (with markers):
```
• First item
• Second item
Unchecked: Unchecked task
Checked: Checked task
1. Ordered one
2. Ordered two
```

---

### 7. Blockquotes

**Input**:
```markdown
> This is a quote
> with multiple lines
```

**Output**:
```
This is a quote with multiple lines
```

---

### 8. Tables

**Input**:
```markdown
| Name | Age |
|------|-----|
| John | 30  |
| Jane | 25  |
```

**Output**:
```
Name, Age
John, 30
Jane, 25
```

---

### 9. Formatting

**Input**:
```markdown
This is **bold**, *italic*, ~~strikethrough~~, and ==highlighted==.
```

**Output**:
```
This is bold, italic, strikethrough, and highlighted.
```

---

### 10. Emojis

**Input**:
```markdown
Great work! 🚀 :fire: :heart:
```

**Output** (removeEmojis: true):
```
Great work!
```

**Output** (removeEmojis: false):
```
Great work! 🚀 :fire: :heart:
```

---

## 🎯 Google TTS Optimization

### Why These Steps Matter

1. **Remove Code** - Code syntax confuses TTS
2. **Convert LaTeX** - Math symbols sound weird
3. **Add Heading Labels** - Provides context
4. **Clean Links** - URLs sound robotic
5. **Handle Lists** - Natural flow
6. **Remove Emojis** - Can cause TTS to stutter
7. **Fix Punctuation** - Proper pauses
8. **Normalize Spacing** - Consistent speech

### TTS-Friendly Output

✅ **Natural pauses** - Proper punctuation  
✅ **No code** - Removed entirely  
✅ **No URLs** - Just link text  
✅ **No emojis** - Clean text  
✅ **Proper spacing** - No double spaces  
✅ **Sentence endings** - Always punctuated  

---

## 📊 Before & After Examples

### Example 1: Technical Content

**Before**:
```markdown
# Tutorial

Learn Python with this code:

```python
def factorial(n):
    return 1 if n == 0 else n * factorial(n-1)
```

The formula is \\(n! = n \\times (n-1)!\\)

Visit [docs](https://python.org) for more! 🚀
```

**After**:
```
Heading: Tutorial. Learn Python with this code: The formula is math expression Visit docs for more!
```

---

### Example 2: Article

**Before**:
```markdown
## Introduction

This is **important** information about [AI](https://ai.com).

> AI is the future

Key points:
- Machine learning
- Deep learning
- Neural networks

![AI diagram](ai.png)
```

**After**:
```
Subheading: Introduction. This is important information about AI. AI is the future Key points: • Machine learning • Deep learning • Neural networks Image: AI diagram.
```

---

## 🧪 Testing

### Test Cases

```dart
void testTTSExtractor() {
  // Test 1: Headings
  assert(
    TTSPlainTextExtractor.extract('# Hello') == 'Heading: Hello.',
  );

  // Test 2: Code removal
  assert(
    TTSPlainTextExtractor.extract('```\ncode\n```\ntext') == 'text',
  );

  // Test 3: LaTeX
  assert(
    TTSPlainTextExtractor.extract(r'\(x^2\)').contains('math expression'),
  );

  // Test 4: Links
  assert(
    TTSPlainTextExtractor.extract('[text](url)') == 'text',
  );

  // Test 5: Lists
  assert(
    TTSPlainTextExtractor.extract('- item').contains('•'),
  );

  print('All tests passed! ✅');
}
```

---

## 🔧 Integration with Google TTS

### In Your App

```dart
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gpt_markdown/tts_extractor.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speakMarkdown(String markdown) async {
    // Extract clean text
    final text = TTSPlainTextExtractor.extract(
      markdown,
      removeEmojis: true,
      addHeadingLabels: true,
    );

    // Configure TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);

    // Speak
    await _tts.speak(text);
  }
}
```

---

## ✅ Quality Checklist

- [x] Removes code blocks
- [x] Converts LaTeX to readable text
- [x] Handles all heading levels
- [x] Extracts link text
- [x] Uses image alt text
- [x] Processes all list types
- [x] Cleans blockquotes
- [x] Extracts table data
- [x] Removes formatting
- [x] Handles emojis
- [x] Fixes punctuation
- [x] Normalizes spacing
- [x] Adds natural pauses
- [x] No errors or exceptions

---

## 🎯 Summary

The TTS extractor is **optimized for Google TTS** with:

✅ **14 processing steps**  
✅ **Natural speech output**  
✅ **No code or LaTeX**  
✅ **Clean punctuation**  
✅ **Proper spacing**  
✅ **Emoji handling**  
✅ **Debug mode**  
✅ **Customizable options**  

**This is the CORE functionality that makes markdown TTS-friendly!** 🎙️

---

Made with focus on **actual TTS quality** 🎯
