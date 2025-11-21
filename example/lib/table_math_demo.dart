import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

void main() => runApp(const TableMathDemoApp());

class TableMathDemoApp extends StatelessWidget {
  const TableMathDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Math Demo',
      theme: ThemeData.dark(),
      home: const TableMathDemo(),
    );
  }
}

class TableMathDemo extends StatelessWidget {
  const TableMathDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Using raw string to avoid escaping issues
    final markdown = r'''
# Trigonometric Ratios

**Basic Ratios (SOH CAH TOA)**

| Function | Formula |
|----------|---------|
| Sine (\(\sin\theta\)) | \[ \sin\theta = \frac{\text{Opposite}}{\text{Hypotenuse}} \] |
| Cosine (\(\cos\theta\)) | \[ \cos\theta = \frac{\text{Adjacent}}{\text{Hypotenuse}} \] |
| Tangent (\(\tan\theta\)) | \[ \tan\theta = \frac{\text{Opposite}}{\text{Adjacent}} \] |

## With Dollar Signs

| Function | Formula |
|----------|---------|
| Sine | $\sin\theta = \frac{Opposite}{Hypotenuse}$ |
| Cosine | $\cos\theta = \frac{Adjacent}{Hypotenuse}$ |
| Tangent | $\tan\theta = \frac{Opposite}{Adjacent}$ |

## Complex Formulas

| Name | Equation |
|------|----------|
| Pythagorean | $a^2 + b^2 = c^2$ |
| Quadratic | $x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}$ |
| Euler's Identity | $e^{i\pi} + 1 = 0$ |
''';

    return Scaffold(
      appBar: AppBar(title: const Text('Table Math Rendering Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GptMarkdown(
          markdown,
          useDollarSignsForLatex: true,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
