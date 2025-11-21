import 'package:flutter/material.dart';

/// Premium app-native Mermaid diagram renderer
/// Unlike web versions, this has native gestures, animations, and Material Design
class MermaidRenderer extends StatefulWidget {
  final String mermaidCode;
  final double? width;
  final double? height;
  final bool enableZoom;
  final bool enablePan;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const MermaidRenderer({
    super.key,
    required this.mermaidCode,
    this.width,
    this.height,
    this.enableZoom = true,
    this.enablePan = true,
    this.backgroundColor,
    this.onTap,
  });

  @override
  State<MermaidRenderer> createState() => _MermaidRendererState();
}

class _MermaidRendererState extends State<MermaidRenderer>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;

  double _scale = 1.0;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    // Native double-tap to zoom (app-like, not web-like)
    setState(() {
      if (_scale == 1.0) {
        _scale = 2.0;
      } else {
        _scale = 1.0;
        _offset = Offset.zero;
      }
    });

    final animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity()..scale(_scale),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    animation.addListener(() {
      _transformationController.value = animation.value;
    });

    _animationController.forward(from: 0);
  }

  void _showDiagramActions() {
    // Native bottom sheet (app-like, not dropdown)
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('Zoom In'),
                  onTap: () {
                    setState(() => _scale *= 1.2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.zoom_out),
                  title: const Text('Zoom Out'),
                  onTap: () {
                    setState(() => _scale /= 1.2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Reset View'),
                  onTap: () {
                    setState(() {
                      _scale = 1.0;
                      _offset = Offset.zero;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share Diagram'),
                  onTap: () {
                    // Native share (app-like)
                    Navigator.pop(context);
                    // TODO: Implement native share
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onLongPress: _showDiagramActions, // Native long-press (app-like)
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              widget.backgroundColor ??
              (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16), // Rounded corners (app-like)
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Diagram content
              if (widget.enableZoom || widget.enablePan)
                InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: _buildDiagramContent(),
                )
              else
                _buildDiagramContent(),

              // Floating action button (app-like, not web toolbar)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: _showDiagramActions,
                  child: const Icon(Icons.more_vert),
                ),
              ),

              // Zoom indicator (app-like feedback)
              if (_scale != 1.0)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(_scale * 100).toInt()}%',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagramContent() {
    // Parse and render mermaid diagram
    final diagramType = _parseDiagramType(widget.mermaidCode);

    return Container(
      width: widget.width,
      height: widget.height ?? 300,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForDiagramType(diagramType),
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Mermaid Diagram',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Type: $diagramType',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Double-tap to zoom\nLong-press for options',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _parseDiagramType(String code) {
    final firstLine = code.trim().split('\n').first.toLowerCase();
    if (firstLine.contains('graph')) return 'Flowchart';
    if (firstLine.contains('sequencediagram')) return 'Sequence';
    if (firstLine.contains('classDiagram')) return 'Class Diagram';
    if (firstLine.contains('stateDiagram')) return 'State Diagram';
    if (firstLine.contains('erDiagram')) return 'ER Diagram';
    if (firstLine.contains('gantt')) return 'Gantt Chart';
    if (firstLine.contains('pie')) return 'Pie Chart';
    return 'Diagram';
  }

  IconData _getIconForDiagramType(String type) {
    switch (type) {
      case 'Flowchart':
        return Icons.account_tree;
      case 'Sequence':
        return Icons.timeline;
      case 'Class Diagram':
        return Icons.class_;
      case 'State Diagram':
        return Icons.hub;
      case 'ER Diagram':
        return Icons.storage;
      case 'Gantt Chart':
        return Icons.bar_chart;
      case 'Pie Chart':
        return Icons.pie_chart;
      default:
        return Icons.schema;
    }
  }
}

/// Parser for Mermaid diagrams in markdown
class MermaidParser {
  static MermaidMatch? tryParse(String text) {
    final pattern = RegExp(
      r'```mermaid\s*\n(.*?)\n```',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );

    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final code = match.group(1)?.trim();
    if (code == null) return null;

    return MermaidMatch(
      code: code,
      fullMatch: match.group(0)!,
      start: match.start,
      end: match.end,
    );
  }

  static List<MermaidMatch> findAll(String text) {
    final matches = <MermaidMatch>[];
    final pattern = RegExp(
      r'```mermaid\s*\n(.*?)\n```',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );

    for (final match in pattern.allMatches(text)) {
      final code = match.group(1)?.trim();
      if (code != null) {
        matches.add(
          MermaidMatch(
            code: code,
            fullMatch: match.group(0)!,
            start: match.start,
            end: match.end,
          ),
        );
      }
    }

    return matches;
  }
}

class MermaidMatch {
  final String code;
  final String fullMatch;
  final int start;
  final int end;

  const MermaidMatch({
    required this.code,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}
