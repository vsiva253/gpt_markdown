import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium app-native task list with swipe gestures and animations
/// Not just checkboxes - interactive, swipeable tasks!
class TaskListItem extends StatefulWidget {
  final String text;
  final bool isChecked;
  final TaskStatus status;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onDelete;
  final TextStyle? textStyle;

  const TaskListItem({
    super.key,
    required this.text,
    this.isChecked = false,
    this.status = TaskStatus.pending,
    this.onChanged,
    this.onDelete,
    this.textStyle,
  });

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  late Animation<double> _slideAnimation;

  double _dragExtent = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isChecked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    if (widget.isChecked) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    widget.onChanged?.call(!widget.isChecked);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = details.primaryDelta ?? 0;
      _isDragging = true;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent < -100) {
      // Swipe left to delete
      HapticFeedback.mediumImpact();
      widget.onDelete?.call();
    }

    setState(() {
      _dragExtent = 0;
      _isDragging = false;
    });
  }

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.status) {
      case TaskStatus.completed:
        return theme.colorScheme.primary;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.pending:
        return theme.colorScheme.outline;
      case TaskStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.radio_button_checked;
      case TaskStatus.pending:
        return Icons.radio_button_unchecked;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context);

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Delete background (revealed on swipe)
          if (_isDragging && _dragExtent < 0)
            Positioned.fill(
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),

          // Main task item
          Transform.translate(
            offset: Offset(_dragExtent.clamp(-120, 0), 0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated checkbox
                  GestureDetector(
                    onTap: _handleTap,
                    child: AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: statusColor, width: 2),
                            color:
                                widget.isChecked
                                    ? statusColor
                                    : Colors.transparent,
                          ),
                          child:
                              widget.isChecked
                                  ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: theme.colorScheme.onPrimary,
                                  )
                                  : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Task text
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, child) {
                        return Text(
                          widget.text,
                          style: (widget.textStyle ??
                                  theme.textTheme.bodyMedium)
                              ?.copyWith(
                                decoration:
                                    widget.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    widget.isChecked
                                        ? theme.colorScheme.onSurface
                                            .withOpacity(0.5)
                                        : theme.colorScheme.onSurface,
                              ),
                        );
                      },
                    ),
                  ),

                  // Status indicator
                  if (widget.status != TaskStatus.pending)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: statusColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Task status enum
enum TaskStatus { pending, inProgress, completed, cancelled }

/// Task list container
class TaskList extends StatelessWidget {
  final List<TaskItem> tasks;
  final ValueChanged<int>? onTaskToggle;
  final ValueChanged<int>? onTaskDelete;

  const TaskList({
    super.key,
    required this.tasks,
    this.onTaskToggle,
    this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            return TaskListItem(
              text: task.text,
              isChecked: task.isChecked,
              status: task.status,
              onChanged: (checked) => onTaskToggle?.call(index),
              onDelete: () => onTaskDelete?.call(index),
            );
          }).toList(),
    );
  }
}

/// Task item data model
class TaskItem {
  final String text;
  final bool isChecked;
  final TaskStatus status;

  const TaskItem({
    required this.text,
    this.isChecked = false,
    this.status = TaskStatus.pending,
  });

  TaskItem copyWith({String? text, bool? isChecked, TaskStatus? status}) {
    return TaskItem(
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
      status: status ?? this.status,
    );
  }
}

/// Parser for task lists in markdown
/// Supports:
/// - [ ] Pending task
/// - [x] Completed task
/// - [/] In progress task
/// - [~] Cancelled task
class TaskListParser {
  /// Parse a single task line
  static TaskMatch? tryParse(String line) {
    final patterns = [
      RegExp(r'^[\s]*-\s*\[\s*\]\s*(.+)$'), // [ ] pending
      RegExp(r'^[\s]*-\s*\[x\]\s*(.+)$', caseSensitive: false), // [x] completed
      RegExp(r'^[\s]*-\s*\[\/\]\s*(.+)$'), // [/] in progress
      RegExp(r'^[\s]*-\s*\[~\]\s*(.+)$'), // [~] cancelled
    ];

    for (int i = 0; i < patterns.length; i++) {
      final match = patterns[i].firstMatch(line);
      if (match != null) {
        final text = match.group(1);
        if (text == null) continue;

        TaskStatus status;
        bool isChecked;

        switch (i) {
          case 0: // [ ]
            status = TaskStatus.pending;
            isChecked = false;
            break;
          case 1: // [x]
            status = TaskStatus.completed;
            isChecked = true;
            break;
          case 2: // [/]
            status = TaskStatus.inProgress;
            isChecked = false;
            break;
          case 3: // [~]
            status = TaskStatus.cancelled;
            isChecked = false;
            break;
          default:
            status = TaskStatus.pending;
            isChecked = false;
        }

        return TaskMatch(
          text: text.trim(),
          status: status,
          isChecked: isChecked,
          fullMatch: match.group(0)!,
          start: match.start,
          end: match.end,
        );
      }
    }

    return null;
  }

  /// Find all tasks in text
  static List<TaskMatch> findAll(String text) {
    final tasks = <TaskMatch>[];
    final lines = text.split('\n');

    for (final line in lines) {
      final task = tryParse(line);
      if (task != null) {
        tasks.add(task);
      }
    }

    return tasks;
  }
}

class TaskMatch {
  final String text;
  final TaskStatus status;
  final bool isChecked;
  final String fullMatch;
  final int start;
  final int end;

  const TaskMatch({
    required this.text,
    required this.status,
    required this.isChecked,
    required this.fullMatch,
    required this.start,
    required this.end,
  });
}
