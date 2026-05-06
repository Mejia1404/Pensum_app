import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final bool isCompact;
  final ValueChanged<int> onTap;
  final double progress;
  final VoidCallback? onProgressTap;

  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
    this.isCompact = false,
    this.progress = 0.0,
    this.onProgressTap,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.calendar_month_rounded,
    Icons.assignment_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Stats', 'Pensum', 'Tareas', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C1E).withOpacity(0.85)
                  : const Color(0xFFF2F2F7).withOpacity(0.85),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 5 nav items + 1 progress indicator = 6 items
                final totalItems = _icons.length + 1;
                final itemWidth = constraints.maxWidth / totalItems;
                
                return Stack(
                  children: [
                    // Sliding indicator for selected nav item
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left: itemWidth * currentIndex,
                      top: 8,
                      bottom: 8,
                      width: itemWidth,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: isDark ? null : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Nav items row
                    Row(
                      children: [
                        // Navigation items
                        ...List.generate(_icons.length, (i) {
                          return SizedBox(
                            width: itemWidth,
                            child: _IOSNavItem(
                              icon: _icons[i],
                              label: _labels[i],
                              isSelected: currentIndex == i,
                              isCompact: isCompact,
                              isDark: isDark,
                              onTap: () => onTap(i),
                            ),
                          );
                        }),
                        // Progress indicator integrated into navbar
                        SizedBox(
                          width: itemWidth,
                          child: _IntegratedProgressIndicator(
                            progress: progress,
                            isDark: isDark,
                            isCompact: isCompact,
                            onTap: onProgressTap,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _IOSNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isCompact;

  const _IOSNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  State<_IOSNavItem> createState() => _IOSNavItemState();
}

class _IOSNavItemState extends State<_IOSNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.98), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant _IOSNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSelected && widget.isSelected) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isCompact ? 22.0 : 24.0;
    final fontSize = widget.isCompact ? 9.0 : 10.0;

    // iOS-style colors
    final selectedColor = AppColors.accent; // Cyan blue for selected
    final unselectedColor = widget.isDark
        ? Colors.white.withOpacity(0.45)
        : Colors.black.withOpacity(0.4);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isSelected ? _bounceAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Icon(
                    widget.icon,
                    key: ValueKey('${widget.isSelected}_${widget.icon}'),
                    color: widget.isSelected ? selectedColor : unselectedColor,
                    size: iconSize,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: fontSize,
                  color: widget.isSelected ? selectedColor : unselectedColor,
                  letterSpacing: -0.2,
                ),
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntegratedProgressIndicator extends StatefulWidget {
  final double progress;
  final bool isDark;
  final bool isCompact;
  final VoidCallback? onTap;

  const _IntegratedProgressIndicator({
    required this.progress,
    required this.isDark,
    required this.isCompact,
    this.onTap,
  });

  @override
  State<_IntegratedProgressIndicator> createState() => _IntegratedProgressIndicatorState();
}

class _IntegratedProgressIndicatorState extends State<_IntegratedProgressIndicator> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ringSize = widget.isCompact ? 36.0 : 40.0;
    final innerSize = ringSize - 6;
    final fontSize = widget.isCompact ? 9.0 : 10.0;
    final labelFontSize = widget.isCompact ? 8.0 : 9.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CircularProgressIndicator(
                    value: widget.progress,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    backgroundColor: widget.isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                  ),
                ),
                // Inner circle with percentage
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF2C2C2E)
                        : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${(widget.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Progreso',
              style: TextStyle(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.45)
                    : Colors.black.withOpacity(0.4),
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep ProgressFab for backwards compatibility but it's no longer needed
class ProgressFab extends StatelessWidget {
  final double progress;
  final bool isDark;
  final VoidCallback onTap;
  final double size;

  const ProgressFab({
    super.key,
    required this.progress,
    required this.isDark,
    required this.onTap,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final ringSize = size + 8;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: isDark
                  ? AppColors.darkBorder.withOpacity(0.3)
                  : AppColors.lightBorder.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.accent : AppColors.accent,
              ),
            ),
          ),
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
