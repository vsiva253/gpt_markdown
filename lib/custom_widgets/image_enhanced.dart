import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium app-native image renderer with gestures and hero animations
/// Way better than GitHub's static images!
class ImageEnhanced extends StatefulWidget {
  final String url;
  final String? alt;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableZoom;
  final bool enableHero;
  final bool showCaption;
  final BorderRadius? borderRadius;

  const ImageEnhanced({
    super.key,
    required this.url,
    this.alt,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.enableZoom = true,
    this.enableHero = true,
    this.showCaption = true,
    this.borderRadius,
  });

  @override
  State<ImageEnhanced> createState() => _ImageEnhancedState();
}

class _ImageEnhancedState extends State<ImageEnhanced>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    // Native hero animation (app-like, not web modal)
    HapticFeedback.mediumImpact(); // Haptic feedback!

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullscreenImageViewer(
            url: widget.url,
            alt: widget.alt,
            heroTag: widget.url,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showImageActions() {
    // Native bottom sheet (app-like)
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('View Fullscreen'),
                  onTap: () {
                    Navigator.pop(context);
                    _openFullscreen();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Save Image'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement native save
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share Image'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement native share
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy Image URL'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.url));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL copied!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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

    Widget imageWidget = Image.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _isLoading = false;
          _controller.forward();
          return FadeTransition(opacity: _fadeAnimation, child: child);
        }

        // Premium loading indicator (app-like)
        return SizedBox(
          width: widget.width,
          height: widget.height ?? 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
                const SizedBox(height: 16),
                Text('Loading image...', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        _hasError = true;
        // Premium error state (app-like)
        return Container(
          width: widget.width,
          height: widget.height ?? 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
              if (widget.alt != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.alt!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );

    // Wrap with hero animation if enabled
    if (widget.enableHero && !_hasError) {
      imageWidget = Hero(tag: widget.url, child: imageWidget);
    }

    return GestureDetector(
      onTap: widget.enableZoom && !_hasError ? _openFullscreen : null,
      onLongPress: !_hasError ? _showImageActions : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded corners and shadow (app-like)
            Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                child: imageWidget,
              ),
            ),

            // Caption (if enabled)
            if (widget.showCaption &&
                widget.alt != null &&
                widget.alt!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  widget.alt!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fullscreen image viewer with pinch-to-zoom (app-native)
class _FullscreenImageViewer extends StatefulWidget {
  final String url;
  final String? alt;
  final String heroTag;

  const _FullscreenImageViewer({
    required this.url,
    this.alt,
    required this.heroTag,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismissible background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),

          // Zoomable image
          Center(
            child: Hero(
              tag: widget.heroTag,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(widget.url, fit: BoxFit.contain),
              ),
            ),
          ),

          // Close button (app-like FAB)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.black54,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),

          // Caption overlay (if available)
          if (widget.alt != null && widget.alt!.isNotEmpty)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.alt!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Parser for images in markdown with size support
class ImageParser {
  /// Parses image syntax: ![alt](url) or ![widthxheight alt](url)
  static ImageMatch? tryParse(String text) {
    // Support for size specification: ![100x200 alt](url)
    final pattern = RegExp(r'!\[(?:(\d+)x(\d+)\s+)?([^\]]*)\]\(([^)]+)\)');

    final match = pattern.firstMatch(text);
    if (match == null) return null;

    final widthStr = match.group(1);
    final heightStr = match.group(2);
    final alt = match.group(3);
    final url = match.group(4);

    if (url == null) return null;

    return ImageMatch(
      url: url.trim(),
      alt: alt?.trim(),
      width: widthStr != null ? double.tryParse(widthStr) : null,
      height: heightStr != null ? double.tryParse(heightStr) : null,
      fullMatch: match.group(0)!,
      start: match.start,
      end: match.end,
    );
  }
}

class ImageMatch {
  final String url;
  final String? alt;
  final double? width;
  final double? height;
  final String fullMatch;
  final int start;
  final int end;

  const ImageMatch({
    required this.url,
    this.alt,
    this.width,
    this.height,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}
