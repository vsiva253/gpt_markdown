import 'package:flutter/material.dart';

/// Enhanced table widget with modern styling and hover effects
class TableEnhanced extends StatefulWidget {
  final List<TableRow> rows;
  final List<String>? headers;
  final bool showHeaders;
  final bool zebraStriping;
  final bool hoverEffect;
  final bool stickyHeader;
  final Color? headerColor;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final Color? hoverColor;
  final Color? borderColor;
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final EdgeInsets? cellPadding;
  final double? borderWidth;
  final BorderRadius? borderRadius;

  const TableEnhanced({
    super.key,
    required this.rows,
    this.headers,
    this.showHeaders = true,
    this.zebraStriping = true,
    this.hoverEffect = true,
    this.stickyHeader = false,
    this.headerColor,
    this.evenRowColor,
    this.oddRowColor,
    this.hoverColor,
    this.borderColor,
    this.headerTextStyle,
    this.cellTextStyle,
    this.cellPadding,
    this.borderWidth,
    this.borderRadius,
  });

  @override
  State<TableEnhanced> createState() => _TableEnhancedState();
}

class _TableEnhancedState extends State<TableEnhanced> {
  int? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headerBgColor =
        widget.headerColor ??
        (isDark ? const Color(0xFF2D2D30) : const Color(0xFFF6F8FA));
    final evenRowBgColor =
        widget.evenRowColor ??
        (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final oddRowBgColor =
        widget.oddRowColor ??
        (isDark ? const Color(0xFF252526) : const Color(0xFFF6F8FA));
    final hoverBgColor =
        widget.hoverColor ?? theme.colorScheme.primary.withOpacity(0.08);
    final borderClr =
        widget.borderColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: borderClr, width: widget.borderWidth ?? 1),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(
                color: borderClr,
                width: widget.borderWidth ?? 1,
              ),
              verticalInside: BorderSide(
                color: borderClr,
                width: widget.borderWidth ?? 1,
              ),
            ),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              // Header row
              if (widget.showHeaders && widget.headers != null)
                TableRow(
                  decoration: BoxDecoration(color: headerBgColor),
                  children:
                      widget.headers!.map((header) {
                        return _TableCell(
                          child: Text(
                            header,
                            style:
                                widget.headerTextStyle ??
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                          ),
                          padding:
                              widget.cellPadding ??
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                        );
                      }).toList(),
                ),
              // Data rows
              ...List.generate(widget.rows.length, (index) {
                final row = widget.rows[index];
                final isEven = index % 2 == 0;
                final isHovered = widget.hoverEffect && _hoveredRow == index;

                Color? rowColor;
                if (isHovered) {
                  rowColor = hoverBgColor;
                } else if (widget.zebraStriping) {
                  rowColor = isEven ? evenRowBgColor : oddRowBgColor;
                } else {
                  rowColor = evenRowBgColor;
                }

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children:
                      row.children.map((cell) {
                        return MouseRegion(
                          onEnter: (_) {
                            if (widget.hoverEffect) {
                              setState(() => _hoveredRow = index);
                            }
                          },
                          onExit: (_) {
                            if (widget.hoverEffect) {
                              setState(() => _hoveredRow = null);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding:
                                widget.cellPadding ??
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                            child: DefaultTextStyle(
                              style:
                                  widget.cellTextStyle ??
                                  TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDark
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.black87,
                                  ),
                              child: cell,
                            ),
                          ),
                        );
                      }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _TableCell({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// Helper class to build table from markdown
class MarkdownTableBuilder {
  /// Parses markdown table and returns TableEnhanced widget
  static TableEnhanced? fromMarkdown(
    String markdown, {
    TextStyle? textStyle,
    bool zebraStriping = true,
    bool hoverEffect = true,
  }) {
    final lines = markdown.trim().split('\n');
    if (lines.length < 2) return null;

    // Parse header
    final headerLine = lines[0].trim();
    if (!headerLine.startsWith('|') || !headerLine.endsWith('|')) return null;

    final headers =
        headerLine
            .substring(1, headerLine.length - 1)
            .split('|')
            .map((h) => h.trim())
            .toList();

    // Skip separator line (line 1)
    if (lines.length < 3) return null;

    // Parse data rows
    final rows = <TableRow>[];
    for (var i = 2; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('|') || !line.endsWith('|')) continue;

      final cells =
          line
              .substring(1, line.length - 1)
              .split('|')
              .map((cell) => Text(cell.trim()))
              .cast<Widget>()
              .toList();

      if (cells.length == headers.length) {
        rows.add(TableRow(children: cells));
      }
    }

    if (rows.isEmpty) return null;

    return TableEnhanced(
      headers: headers,
      rows: rows,
      zebraStriping: zebraStriping,
      hoverEffect: hoverEffect,
      cellTextStyle: textStyle,
    );
  }
}
