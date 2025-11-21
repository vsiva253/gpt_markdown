import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

void main() {
  runApp(const TableMathTestApp());
}

class TableMathTestApp extends StatelessWidget {
  const TableMathTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Math Test',
      theme: ThemeData.dark(),
      home: const TableMathTestScreen(),
    );
  }
}

class TableMathTestScreen extends StatelessWidget {
  const TableMathTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const testMarkdown = r'''
# Table Math Test

## Test 1: Simple inline math in table

| Formula | Value |
|---------|-------|
| $E = mc^2$ | Energy equation |
| $F = ma$ | Force equation |
| $a^2 + b^2 = c^2$ | Pythagorean theorem |

## Test 2: Complex expressions

| Name | Formula | Description |
|------|---------|-------------|
| Quadratic | $\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$ | Quadratic formula |
| Circle | $x^2 + y^2 = r^2$ | Circle equation |
| Integral | $\int_a^b f(x) dx$ | Definite integral |

## Test 3: Mixed content

| Item | Math | Text |
|------|------|------|
| First | $\alpha + \beta$ | Greek letters |
| Second | **Bold** and *italic* | Formatting |
| Third | $\sum_{i=1}^n i$ | Summation |

## Test 4: Inline and block math

Regular inline math: $E = mc^2$

Block math:

$$
\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

More text here.
''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Math Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GptMarkdown(
          testMarkdown,
          useDollarSignsForLatex: true,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
