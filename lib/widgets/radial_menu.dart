import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/app_theme.dart';

/// A radial/pie menu that appears on long press with options arranged in a circle.
/// The user drags their finger toward an option to select it.
class RadialMenu {
  final List<RadialMenuItem> items;
  final Offset center;
  final VoidCallback? onDismissed;
  final Color? backgroundColor;
  final double radius;
  final double itemRadius;

  const RadialMenu({
    required this.items,
    required this.center,
    this.onDismissed,
    this.backgroundColor,
    this.radius = 120,
    this.itemRadius = 44,
  });

  /// Shows the radial menu as an overlay
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required List<RadialMenuItem> items,
    required Offset globalPosition,
    VoidCallback? onDismissed,
    double itemRadius = 44,
  }) {
    // Remove any existing menu
    hide();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final localPosition = renderBox?.globalToLocal(globalPosition) ?? globalPosition;

    _currentEntry = OverlayEntry(
      builder: (context) => _RadialMenuOverlay(
        items: items,
        center: localPosition,
        onDismissed: onDismissed,
        itemRadius: itemRadius,
      ),
    );

    overlay.insert(_currentEntry!);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _RadialMenuOverlay extends StatefulWidget {
  final List<RadialMenuItem> items;
  final Offset center;
  final VoidCallback? onDismissed;
  final double itemRadius;

  const _RadialMenuOverlay({
    required this.items,
    required this.center,
    this.onDismissed,
    this.itemRadius = 44,
  });

  @override
  State<_RadialMenuOverlay> createState() => _RadialMenuOverlayState();
}

class _RadialMenuOverlayState extends State<_RadialMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  RadialMenuItem? _hoveredItem;
  Offset _dragStart = Offset.zero;
  bool _hasMoved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    _hasMoved = false;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final currentPos = details.localPosition;
    final delta = currentPos - _dragStart;
    final distance = delta.distance;

    if (distance > 10) {
      _hasMoved = true;
    }

    if (_hasMoved) {
      // Calculate angle from center
      final center = widget.center;
      final vector = currentPos - center;
      final angle = math.atan2(vector.dy, vector.dx);

      // Find which item is under the finger
      final itemCount = widget.items.length;
      final anglePerItem = 2 * math.pi / itemCount;
      // Adjust so first item is at top (-pi/2)
      final adjustedAngle = angle + math.pi / 2;
      final normalizedAngle = (adjustedAngle + 2 * math.pi) % (2 * math.pi);
      final index = (normalizedAngle / anglePerItem).floor() % itemCount;

      setState(() {
        _hoveredItem = widget.items[index];
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_hasMoved && _hoveredItem != null) {
      _hoveredItem!.onTap();
    }
    _dismiss();
  }

  void _handleTapDown(TapDownDetails details) {
    // Check if tap is on an item
    final center = widget.center;
    final vector = details.localPosition - center;
    final distance = vector.distance;

    if (distance > 60 && distance < 160) {
      final angle = math.atan2(vector.dy, vector.dx);
      final itemCount = widget.items.length;
      final anglePerItem = 2 * math.pi / itemCount;
      final adjustedAngle = angle + math.pi / 2;
      final normalizedAngle = (adjustedAngle + 2 * math.pi) % (2 * math.pi);
      final index = (normalizedAngle / anglePerItem).floor() % itemCount;

      widget.items[index].onTap();
    }
    _dismiss();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      RadialMenu.hide();
      widget.onDismissed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapDown: _handleTapDown,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              origin: widget.center,
              child: Stack(
                children: [
                  // Background dim
                  Container(
                    color: Colors.black.withOpacity(0.3 * _opacityAnimation.value),
                  ),
                  // Menu items
                  ..._buildItems(context, colors),
                  // Center hub
                  Positioned(
                    left: widget.center.dx - 32,
                    top: widget.center.dy - 32,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.borderSoft, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: colors.accent.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.drag_indicator,
                        color: colors.accent,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context, AppColors colors) {
    final itemCount = widget.items.length;
    final anglePerItem = 2 * math.pi / itemCount;
    const orbitRadius = 100.0;

    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isHovered = _hoveredItem == item;

      // Calculate position (first item at top)
      final angle = (index * anglePerItem) - math.pi / 2;
      final dx = widget.center.dx + math.cos(angle) * orbitRadius - widget.itemRadius;
      final dy = widget.center.dy + math.sin(angle) * orbitRadius - widget.itemRadius;

      return Positioned(
        left: dx,
        top: dy,
        child: _RadialMenuItemWidget(
          item: item,
          isHovered: isHovered,
          onTap: () {
            item.onTap();
            _dismiss();
          },
        ),
      );
    }).toList();
  }
}

class _RadialMenuItemWidget extends StatefulWidget {
  final RadialMenuItem item;
  final bool isHovered;
  final VoidCallback onTap;

  const _RadialMenuItemWidget({
    required this.item,
    required this.isHovered,
    required this.onTap,
  });

  @override
  State<_RadialMenuItemWidget> createState() => _RadialMenuItemWidgetState();
}

class _RadialMenuItemWidgetState extends State<_RadialMenuItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.elasticOut,
    );

    if (widget.isHovered) {
      _hoverController.forward();
    }
  }

  @override
  void didUpdateWidget(_RadialMenuItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered != oldWidget.isHovered) {
      if (widget.isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_scaleAnimation.value * 0.3),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: widget.isHovered ? colors.accent : colors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isHovered
                      ? colors.accent
                      : colors.borderSoft,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isHovered
                        ? colors.accent.withOpacity(0.5)
                        : Colors.black.withOpacity(0.15),
                    blurRadius: widget.isHovered ? 20 : 10,
                    spreadRadius: widget.isHovered ? 4 : 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.item.icon,
                    size: 28,
                    color: widget.isHovered
                        ? colors.accentOn
                        : colors.fg,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: widget.isHovered
                          ? colors.accentOn
                          : colors.fg2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Represents an item in the radial menu
class RadialMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isDestructive;

  const RadialMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.isDestructive = false,
  });

  /// Creates a standard edit item
  static RadialMenuItem edit(VoidCallback onTap) => RadialMenuItem(
        label: 'Editar',
        icon: Icons.edit_outlined,
        onTap: onTap,
      );

  /// Creates a duplicate item
  static RadialMenuItem duplicate(VoidCallback onTap) => RadialMenuItem(
        label: 'Duplicar',
        icon: Icons.content_copy_outlined,
        onTap: onTap,
      );

  /// Creates a delete item
  static RadialMenuItem delete(VoidCallback onTap) => RadialMenuItem(
        label: 'Eliminar',
        icon: Icons.delete_outline,
        onTap: onTap,
        isDestructive: true,
      );

  /// Creates a postpone item
  static RadialMenuItem postpone(VoidCallback onTap) => RadialMenuItem(
        label: 'Posponer',
        icon: Icons.schedule_outlined,
        onTap: onTap,
      );

  /// Creates a complete item
  static RadialMenuItem complete(VoidCallback onTap) => RadialMenuItem(
        label: 'Completar',
        icon: Icons.check_circle_outline,
        onTap: onTap,
        color: Colors.green,
      );

  /// Creates a reminder item
  static RadialMenuItem reminder(VoidCallback onTap) => RadialMenuItem(
        label: 'Recordatorio',
        icon: Icons.notifications_outlined,
        onTap: onTap,
      );
}