import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// A radial/pie menu that appears on long press with options arranged in a circle.
/// The user drags their finger toward an option to select it with a liquid metaball morphing effect.
class RadialMenu {
  static OverlayEntry? _currentEntry;
  static _RadialMenuOverlayState? _currentState;

  static void show({
    required BuildContext context,
    required List<RadialMenuItem> items,
    required Offset globalPosition,
    VoidCallback? onDismissed,
  }) {
    hide();

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => _RadialMenuOverlay(
        items: items,
        targetCenter: globalPosition,
        onDismissed: onDismissed,
      ),
    );

    overlay.insert(_currentEntry!);
  }

  static void updateDrag(Offset globalPosition) {
    _currentState?.handleExternalDrag(globalPosition);
  }

  static void endDrag(Offset globalPosition) {
    _currentState?.handleExternalEnd(globalPosition);
  }

  static void hide() {
    _currentState = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _RadialMenuOverlay extends StatefulWidget {
  final List<RadialMenuItem> items;
  final Offset targetCenter;
  final VoidCallback? onDismissed;

  const _RadialMenuOverlay({
    required this.items,
    required this.targetCenter,
    this.onDismissed,
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
  Offset? _currentFingerPos;
  bool _hasDragged = false;

  static const double _orbitRadius = 100.0;
  static const double _itemDiameter = 68.0;
  static const double _itemRadius = _itemDiameter / 2;

  @override
  void initState() {
    super.initState();
    RadialMenu._currentState = this;
    _currentFingerPos = widget.targetCenter;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    if (RadialMenu._currentState == this) {
      RadialMenu._currentState = null;
    }
    _controller.dispose();
    super.dispose();
  }

  Offset _getSafeCenter(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final size = mediaQuery.size;

    const double margin = 14.0;
    final double totalRadius = _orbitRadius + _itemRadius + margin;

    final minX = padding.left + totalRadius;
    final maxX = size.width - padding.right - totalRadius;
    final minY = padding.top + totalRadius;
    final maxY = size.height - padding.bottom - totalRadius;

    final clampedX = minX <= maxX
        ? widget.targetCenter.dx.clamp(minX, maxX)
        : size.width / 2;
    final clampedY = minY <= maxY
        ? widget.targetCenter.dy.clamp(minY, maxY)
        : size.height / 2;

    return Offset(clampedX, clampedY);
  }

  Offset? _getHoveredItemCenter(Offset safeCenter) {
    if (_hoveredItem == null || widget.items.isEmpty) return null;
    final index = widget.items.indexOf(_hoveredItem!);
    if (index < 0) return null;
    final anglePerItem = 2 * math.pi / widget.items.length;
    final angle = (index * anglePerItem) - math.pi / 2;
    return Offset(
      safeCenter.dx + math.cos(angle) * _orbitRadius,
      safeCenter.dy + math.sin(angle) * _orbitRadius,
    );
  }

  void _updateSelection(Offset fingerPos) {
    final safeCenter = _getSafeCenter(context);
    final vector = fingerPos - safeCenter;
    final distance = vector.distance;

    _currentFingerPos = fingerPos;

    if (distance > 12) {
      _hasDragged = true;
    }

    if (distance >= 28 && widget.items.isNotEmpty) {
      final angle = math.atan2(vector.dy, vector.dx);
      final itemCount = widget.items.length;
      final anglePerItem = 2 * math.pi / itemCount;

      // Center selection cone around each button
      final adjustedAngle = (angle + math.pi / 2 + anglePerItem / 2) % (2 * math.pi);
      final normalizedAngle = (adjustedAngle + 2 * math.pi) % (2 * math.pi);
      final index = (normalizedAngle / anglePerItem).floor() % itemCount;

      if (index >= 0 && index < widget.items.length) {
        final item = widget.items[index];
        if (_hoveredItem != item) {
          HapticFeedback.selectionClick();
          setState(() {
            _hoveredItem = item;
          });
        }
      }
    } else {
      if (_hoveredItem != null) {
        setState(() {
          _hoveredItem = null;
        });
      }
    }
  }

  void handleExternalDrag(Offset globalPosition) {
    if (!mounted) return;
    _updateSelection(globalPosition);
  }

  void handleExternalEnd(Offset globalPosition) {
    if (!mounted) return;
    if (_hoveredItem != null) {
      HapticFeedback.mediumImpact();
      _hoveredItem!.onTap();
      _dismiss();
    } else if (_hasDragged) {
      _dismiss();
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _updateSelection(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateSelection(details.localPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_hoveredItem != null) {
      HapticFeedback.mediumImpact();
      _hoveredItem!.onTap();
    }
    _dismiss();
  }

  void _handleTapDown(TapDownDetails details) {
    final safeCenter = _getSafeCenter(context);
    final vector = details.localPosition - safeCenter;
    final distance = vector.distance;

    if (distance >= 28 && distance <= _orbitRadius + _itemRadius + 24 && widget.items.isNotEmpty) {
      final angle = math.atan2(vector.dy, vector.dx);
      final itemCount = widget.items.length;
      final anglePerItem = 2 * math.pi / itemCount;

      final adjustedAngle = (angle + math.pi / 2 + anglePerItem / 2) % (2 * math.pi);
      final normalizedAngle = (adjustedAngle + 2 * math.pi) % (2 * math.pi);
      final index = (normalizedAngle / anglePerItem).floor() % itemCount;

      if (index >= 0 && index < widget.items.length) {
        HapticFeedback.mediumImpact();
        widget.items[index].onTap();
      }
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
    final safeCenter = _getSafeCenter(context);
    final hoveredCenter = _getHoveredItemCenter(safeCenter);

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapDown: _handleTapDown,
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final activeColor = _hoveredItem != null
                ? (_hoveredItem!.color ?? colors.accent)
                : colors.accent;

            return Opacity(
              opacity: _opacityAnimation.value.clamp(0.0, 1.0),
              child: Stack(
                children: [
                  // Smooth Glassmorphism Backdrop
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 8 * _opacityAnimation.value,
                        sigmaY: 8 * _opacityAnimation.value,
                      ),
                      child: Container(
                        color: Colors.black.withValues(
                          alpha: 0.38 * _opacityAnimation.value,
                        ),
                      ),
                    ),
                  ),

                  // Dynamic Liquid Gooey / Metaball Bridge Canvas
                  CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _LiquidGooeyPainter(
                      center: safeCenter,
                      hoveredCenter: hoveredCenter,
                      fingerPos: _currentFingerPos,
                      activeColor: activeColor,
                      isHovered: _hoveredItem != null,
                      scale: _scaleAnimation.value,
                    ),
                  ),

                  // Radial menu items and center hub scaled around safe center
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    origin: safeCenter,
                    child: Stack(
                      children: [
                        // Radial Items
                        ..._buildItems(context, colors, safeCenter),

                        // Center Hub with liquid styling
                        Positioned(
                          left: safeCenter.dx - 26,
                          top: safeCenter.dy - 26,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _hoveredItem != null
                                  ? activeColor
                                  : colors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hoveredItem != null
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : colors.borderSoft,
                                width: _hoveredItem != null ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _hoveredItem != null
                                      ? activeColor.withValues(alpha: 0.55)
                                      : Colors.black.withValues(alpha: 0.12),
                                  blurRadius: _hoveredItem != null ? 20 : 10,
                                  spreadRadius: _hoveredItem != null ? 3 : 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              _hoveredItem != null
                                  ? _hoveredItem!.icon
                                  : Icons.touch_app_rounded,
                              color: _hoveredItem != null
                                  ? Colors.white
                                  : colors.fg2,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context, AppColors colors, Offset safeCenter) {
    final itemCount = widget.items.length;
    if (itemCount == 0) return [];
    final anglePerItem = 2 * math.pi / itemCount;

    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isHovered = _hoveredItem == item;

      // First item is at top (-pi/2)
      final angle = (index * anglePerItem) - math.pi / 2;
      final dx = safeCenter.dx + math.cos(angle) * _orbitRadius - _itemRadius;
      final dy = safeCenter.dy + math.sin(angle) * _orbitRadius - _itemRadius;

      return Positioned(
        left: dx,
        top: dy,
        child: _RadialMenuItemWidget(
          item: item,
          isHovered: isHovered,
          diameter: _itemDiameter,
          onTap: () {
            HapticFeedback.mediumImpact();
            item.onTap();
            _dismiss();
          },
        ),
      );
    }).toList();
  }
}

class _RadialMenuItemWidget extends StatelessWidget {
  final RadialMenuItem item;
  final bool isHovered;
  final double diameter;
  final VoidCallback onTap;

  const _RadialMenuItemWidget({
    required this.item,
    required this.isHovered,
    required this.diameter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final itemColor = item.color ?? colors.accent;

    Color bg;
    Color fg;
    Color border;

    if (isHovered) {
      bg = itemColor;
      fg = Colors.white;
      border = Colors.white.withValues(alpha: 0.9);
    } else {
      bg = colors.surface.withValues(alpha: 0.95);
      fg = item.isDestructive ? colors.danger : colors.fg;
      border = item.isDestructive
          ? colors.danger.withValues(alpha: 0.35)
          : colors.borderSoft;
    }

    return AnimatedScale(
      scale: isHovered ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: border,
              width: isHovered ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? itemColor.withValues(alpha: 0.65)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: isHovered ? 22 : 8,
                spreadRadius: isHovered ? 4 : 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: isHovered ? 25 : 23,
                color: isHovered ? Colors.white : itemColor,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isHovered ? FontWeight.w700 : FontWeight.w600,
                  color: fg,
                  decoration: TextDecoration.none,
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
  }
}

/// Custom painter to draw organic Liquid / Metaball bridge connecting center to hovered option
class _LiquidGooeyPainter extends CustomPainter {
  final Offset center;
  final Offset? hoveredCenter;
  final Offset? fingerPos;
  final Color activeColor;
  final bool isHovered;
  final double scale;

  _LiquidGooeyPainter({
    required this.center,
    required this.hoveredCenter,
    required this.fingerPos,
    required this.activeColor,
    required this.isHovered,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scale <= 0.05) return;

    if (isHovered && hoveredCenter != null) {
      _drawHoveredLiquidBridge(canvas);
    } else if (fingerPos != null) {
      _drawFreeDragLiquidStrand(canvas);
    }
  }

  void _drawHoveredLiquidBridge(Canvas canvas) {
    const double r1 = 26.0;
    const double r2 = 34.0;
    final c1 = center;
    final c2 = hoveredCenter!;

    final path = _buildMetaballPath(
      c1: c1,
      r1: r1 * scale,
      c2: c2,
      r2: r2 * scale,
      pinchRatio: 0.32,
    );

    // 1. Outer Liquid Glow Underlay
    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, glowPaint);

    // 2. Main Liquid Body with glossy gradient
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          activeColor.withValues(alpha: 0.88),
          activeColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromPoints(c1, c2))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, liquidPaint);

    // 3. Subtle liquid sheen / inner outline
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, strokePaint);
  }

  void _drawFreeDragLiquidStrand(Canvas canvas) {
    final c1 = center;
    final c2 = fingerPos!;
    final distance = (c2 - c1).distance;
    if (distance < 18) return;

    const double r1 = 24.0;
    final double r2 = (14.0 * math.max(0.4, 1.0 - (distance / 280))).clamp(6.0, 14.0);

    final path = _buildMetaballPath(
      c1: c1,
      r1: r1 * scale,
      c2: c2,
      r2: r2 * scale,
      pinchRatio: 0.42,
    );

    // Soft liquid trail
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          activeColor.withValues(alpha: 0.4),
          activeColor.withValues(alpha: 0.75),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromPoints(c1, c2))
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, liquidPaint);

    // Liquid droplet tip
    final tipPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c2, r2 * scale * 0.7, tipPaint);
  }

  Path _buildMetaballPath({
    required Offset c1,
    required double r1,
    required Offset c2,
    required double r2,
    required double pinchRatio,
  }) {
    final d = (c2 - c1).distance;
    if (d <= 0.001) {
      return Path()..addOval(Rect.fromCircle(center: c1, radius: r1));
    }

    final theta = math.atan2(c2.dy - c1.dy, c2.dx - c1.dx);
    final u = Offset(math.cos(theta), math.sin(theta));
    final n = Offset(-math.sin(theta), math.cos(theta));

    // Dynamic tangent angles
    const double alpha1 = math.pi * 0.42; // ~75 deg
    const double alpha2 = math.pi * 0.44; // ~79 deg

    final p1a = c1 + u * (r1 * math.cos(alpha1)) + n * (r1 * math.sin(alpha1));
    final p1b = c1 + u * (r1 * math.cos(alpha1)) - n * (r1 * math.sin(alpha1));

    final p2a = c2 - u * (r2 * math.cos(alpha2)) + n * (r2 * math.sin(alpha2));
    final p2b = c2 - u * (r2 * math.cos(alpha2)) - n * (r2 * math.sin(alpha2));

    final handleLen = d * 0.38;
    final pinch = (r1 + r2) * 0.5 * pinchRatio;

    final cp1a = p1a + u * handleLen - n * pinch;
    final cp2a = p2a - u * handleLen - n * pinch;

    final cp2b = p2b - u * handleLen + n * pinch;
    final cp1b = p1b + u * handleLen + n * pinch;

    final path = Path();
    path.moveTo(p1a.dx, p1a.dy);
    path.cubicTo(cp1a.dx, cp1a.dy, cp2a.dx, cp2a.dy, p2a.dx, p2a.dy);
    path.arcToPoint(p2b, radius: Radius.circular(r2), clockwise: true);
    path.cubicTo(cp2b.dx, cp2b.dy, cp1b.dx, cp1b.dy, p1b.dx, p1b.dy);
    path.arcToPoint(p1a, radius: Radius.circular(r1), clockwise: true);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(_LiquidGooeyPainter oldDelegate) {
    return oldDelegate.fingerPos != fingerPos ||
        oldDelegate.hoveredCenter != hoveredCenter ||
        oldDelegate.center != center ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.scale != scale;
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

  /// Creates a Pomodoro / Focus item
  static RadialMenuItem pomodoro(VoidCallback onTap, AppColors colors) => RadialMenuItem(
        label: 'Pomodoro',
        icon: Icons.timer_outlined,
        onTap: onTap,
        color: colors.accent,
      );

  /// Creates an edit item
  static RadialMenuItem edit(VoidCallback onTap) => RadialMenuItem(
        label: 'Editar',
        icon: Icons.edit_outlined,
        onTap: onTap,
        color: const Color(0xFF3B82F6),
      );

  /// Creates a duplicate item
  static RadialMenuItem duplicate(VoidCallback onTap) => RadialMenuItem(
        label: 'Duplicar',
        icon: Icons.content_copy_outlined,
        onTap: onTap,
        color: const Color(0xFF8B5CF6),
      );

  /// Creates a postpone item
  static RadialMenuItem postpone(VoidCallback onTap, AppColors colors) => RadialMenuItem(
        label: 'Posponer',
        icon: Icons.schedule_outlined,
        onTap: onTap,
        color: colors.warn,
      );

  /// Creates a complete item
  static RadialMenuItem complete(VoidCallback onTap, AppColors colors) => RadialMenuItem(
        label: 'Completar',
        icon: Icons.check_circle_outline,
        onTap: onTap,
        color: colors.success,
      );

  /// Creates a delete item
  static RadialMenuItem delete(VoidCallback onTap, AppColors colors) => RadialMenuItem(
        label: 'Eliminar',
        icon: Icons.delete_outline,
        onTap: onTap,
        color: colors.danger,
        isDestructive: true,
      );
}