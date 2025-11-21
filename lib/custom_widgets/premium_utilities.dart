import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium copy button with smooth animations
class PremiumCopyButton extends StatefulWidget {
  final String textToCopy;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double size;

  const PremiumCopyButton({
    super.key,
    required this.textToCopy,
    this.icon = Icons.content_copy,
    this.tooltip,
    this.color,
    this.size = 20,
  });

  @override
  State<PremiumCopyButton> createState() => _PremiumCopyButtonState();
}

class _PremiumCopyButtonState extends State<PremiumCopyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));
    HapticFeedback.lightImpact();

    setState(() {
      _copied = true;
    });

    _controller.forward();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _copied = false;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return AnimatedScale(
      scale: _copied ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _copied ? Icons.check : widget.icon,
            key: ValueKey(_copied),
            color: _copied ? Colors.green : color,
            size: widget.size,
          ),
        ),
        onPressed: _handleCopy,
        tooltip: _copied ? 'Copied!' : (widget.tooltip ?? 'Copy'),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

/// Reading time estimator
class ReadingTimeEstimator {
  /// Calculate reading time in minutes
  /// Average reading speed: 200-250 words per minute
  static int estimate(String text, {int wordsPerMinute = 225}) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final minutes = (words / wordsPerMinute).ceil();
    return minutes.clamp(1, 999);
  }

  /// Get formatted reading time string
  static String format(String text, {int wordsPerMinute = 225}) {
    final minutes = estimate(text, wordsPerMinute: wordsPerMinute);
    if (minutes == 1) {
      return '1 min read';
    }
    return '$minutes min read';
  }
}

/// Premium reading time badge
class ReadingTimeBadge extends StatelessWidget {
  final String text;
  final int wordsPerMinute;
  final Color? backgroundColor;
  final Color? textColor;

  const ReadingTimeBadge({
    super.key,
    required this.text,
    this.wordsPerMinute = 225,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingTime = ReadingTimeEstimator.format(
      text,
      wordsPerMinute: wordsPerMinute,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: textColor ?? theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            readingTime,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Auto-generated table of contents
class TableOfContents extends StatelessWidget {
  final List<TocItem> items;
  final Function(String)? onItemTap;
  final bool floating;
  final bool collapsible;

  const TableOfContents({
    super.key,
    required this.items,
    this.onItemTap,
    this.floating = false,
    this.collapsible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _TocItemWidget(item: item, onTap: onItemTap);
      },
    );

    if (collapsible) {
      content = ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.list, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Table of Contents',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        initiallyExpanded: true,
        children: [content],
      );
    }

    if (floating) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: content,
    );
  }
}

class _TocItemWidget extends StatelessWidget {
  final TocItem item;
  final Function(String)? onTap;

  const _TocItemWidget({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call(item.id);
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: (item.level - 1) * 16.0 + 8,
          top: 8,
          bottom: 8,
          right: 8,
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 14 - (item.level - 1),
                  fontWeight:
                      item.level == 1 ? FontWeight.bold : FontWeight.normal,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TocItem {
  final String id;
  final String title;
  final int level; // 1-6 for H1-H6

  TocItem({required this.id, required this.title, required this.level});
}

/// Extract TOC from markdown
class TocExtractor {
  static List<TocItem> extract(String markdown) {
    final items = <TocItem>[];
    final lines = markdown.split('\n');

    for (final line in lines) {
      final match = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line.trim());
      if (match != null) {
        final level = match[1]!.length;
        final title = match[2]!.trim();
        final id = _generateId(title);

        items.add(TocItem(id: id, title: title, level: level));
      }
    }

    return items;
  }

  static String _generateId(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}

/// Premium reading mode settings
class ReadingModeSettings {
  final double fontSize;
  final double lineHeight;
  final double letterSpacing;
  final double paragraphSpacing;
  final bool serifFont;

  const ReadingModeSettings({
    this.fontSize = 16,
    this.lineHeight = 1.6,
    this.letterSpacing = 0.0,
    this.paragraphSpacing = 16,
    this.serifFont = false,
  });

  ReadingModeSettings copyWith({
    double? fontSize,
    double? lineHeight,
    double? letterSpacing,
    double? paragraphSpacing,
    bool? serifFont,
  }) {
    return ReadingModeSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      serifFont: serifFont ?? this.serifFont,
    );
  }

  TextStyle toTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: fontSize,
      height: lineHeight,
      letterSpacing: letterSpacing,
      fontFamily: serifFont ? 'Serif' : null,
      color: theme.colorScheme.onSurface,
    );
  }
}

/// Premium reading mode controls
class ReadingModeControls extends StatelessWidget {
  final ReadingModeSettings settings;
  final ValueChanged<ReadingModeSettings> onChanged;

  const ReadingModeControls({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Font size
          _buildSlider(
            context,
            label: 'Font Size',
            value: settings.fontSize,
            min: 12,
            max: 24,
            onChanged: (value) {
              onChanged(settings.copyWith(fontSize: value));
            },
          ),

          // Line height
          _buildSlider(
            context,
            label: 'Line Height',
            value: settings.lineHeight,
            min: 1.2,
            max: 2.0,
            onChanged: (value) {
              onChanged(settings.copyWith(lineHeight: value));
            },
          ),

          // Serif font toggle
          SwitchListTile(
            title: const Text('Serif Font'),
            value: settings.serifFont,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onChanged(settings.copyWith(serifFont: value));
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: (newValue) {
            HapticFeedback.selectionClick();
            onChanged(newValue);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
