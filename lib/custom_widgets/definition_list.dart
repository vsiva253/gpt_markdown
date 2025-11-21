import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium app-native definition list
/// Not just text - expandable, tappable definitions!
class DefinitionList extends StatelessWidget {
  final List<DefinitionItem> items;
  final bool expandable;
  final bool showDividers;

  const DefinitionList({
    super.key,
    required this.items,
    this.expandable = true,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          DefinitionListItem(item: items[i], expandable: expandable),
          if (showDividers && i < items.length - 1)
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
        ],
      ],
    );
  }
}

/// Single definition item with expand/collapse
class DefinitionListItem extends StatefulWidget {
  final DefinitionItem item;
  final bool expandable;

  const DefinitionListItem({
    super.key,
    required this.item,
    this.expandable = true,
  });

  @override
  State<DefinitionListItem> createState() => _DefinitionListItemState();
}

class _DefinitionListItemState extends State<DefinitionListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _iconRotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start expanded if not expandable
    if (!widget.expandable) {
      _isExpanded = true;
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (!widget.expandable) return;

    HapticFeedback.lightImpact();

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term (always visible)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon (if expandable)
                  if (widget.expandable)
                    RotationTransition(
                      turns: _iconRotation,
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                  // Term text
                  Expanded(
                    child: Text(
                      widget.item.term,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // Badge (if multiple definitions)
                  if (widget.item.definitions.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.item.definitions.length}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Definitions (expandable)
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    widget.item.definitions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final definition = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Number badge (if multiple definitions)
                            if (widget.item.definitions.length > 1)
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),

                            // Definition text
                            Expanded(
                              child: Text(
                                definition,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Definition item data model
class DefinitionItem {
  final String term;
  final List<String> definitions;

  const DefinitionItem({required this.term, required this.definitions});
}

/// Parser for definition lists in markdown
/// Supports:
/// Term
/// : Definition 1
/// : Definition 2
class DefinitionListParser {
  /// Parse definition list from text
  static List<DefinitionItem> parse(String text) {
    final items = <DefinitionItem>[];
    final lines = text.split('\n');

    String? currentTerm;
    List<String> currentDefinitions = [];

    for (final line in lines) {
      final trimmed = line.trim();

      // Check if it's a definition line (starts with :)
      if (trimmed.startsWith(':')) {
        final definition = trimmed.substring(1).trim();
        if (definition.isNotEmpty) {
          currentDefinitions.add(definition);
        }
      } else if (trimmed.isNotEmpty) {
        // It's a term line
        // Save previous term if exists
        if (currentTerm != null && currentDefinitions.isNotEmpty) {
          items.add(
            DefinitionItem(
              term: currentTerm,
              definitions: List.from(currentDefinitions),
            ),
          );
        }

        // Start new term
        currentTerm = trimmed;
        currentDefinitions = [];
      }
    }

    // Add last term
    if (currentTerm != null && currentDefinitions.isNotEmpty) {
      items.add(
        DefinitionItem(term: currentTerm, definitions: currentDefinitions),
      );
    }

    return items;
  }

  /// Check if text contains definition list
  static bool hasDefinitionList(String text) {
    final lines = text.split('\n');
    bool hasDefinition = false;

    for (final line in lines) {
      if (line.trim().startsWith(':')) {
        hasDefinition = true;
        break;
      }
    }

    return hasDefinition;
  }
}

/// Glossary widget (collection of definitions with search)
class Glossary extends StatefulWidget {
  final List<DefinitionItem> items;
  final bool showSearch;

  const Glossary({super.key, required this.items, this.showSearch = true});

  @override
  State<Glossary> createState() => _GlossaryState();
}

class _GlossaryState extends State<Glossary> {
  String _searchQuery = '';
  List<DefinitionItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.items.where((item) {
              return item.term.toLowerCase().contains(_searchQuery) ||
                  item.definitions.any(
                    (def) => def.toLowerCase().contains(_searchQuery),
                  );
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.book, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Glossary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_filteredItems.length} terms',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),

        // Search bar (if enabled)
        if (widget.showSearch) ...[
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search terms...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            onChanged: _handleSearch,
          ),
        ],

        const SizedBox(height: 16),

        // Definition list
        if (_filteredItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No terms found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          DefinitionList(items: _filteredItems),
      ],
    );
  }
}
