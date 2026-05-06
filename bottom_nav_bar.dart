import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final bool isCompact;
  final ValueChanged<int> onTap;

  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
    this.isCompact = false,
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
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withOpacity(0.75)
                  : AppColors.lightSurface.withOpacity(0.75),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _icons.length;
                return Stack(
                  children: [
                    // Sliding indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left: itemWidth * currentIndex,
                      top: 10,
                      bottom: 10,
                      width: itemWidth,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: isCompact ? 0 : 2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Icons
                    Row(
                      children: List.generate(_icons.length, (i) {
                        return SizedBox(
                          width: itemWidth,
                          child: _LiquidNavItem(
                            icon: _icons[i],
                            label: _labels[i],
                            isSelected: currentIndex == i,
                            isCompact: isCompact,
                            isDark: isDark,
                            onTap: () => onTap(i),
                          ),
                        );
                      }),
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

class _LiquidNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isCompact;

  const _LiquidNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  State<_LiquidNavItem> createState() => _LiquidNavItemState();
}

class _LiquidNavItemState extends State<_LiquidNavItem>
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
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant _LiquidNavItem oldWidget) {
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
    final iconSize = widget.isCompact ? 20.0 : 22.0;
    final fontSize = widget.isCompact ? 9.0 : 10.0;

    final selectedColor = widget.isDark ? Colors.white : AppColors.primary;
    final unselectedColor = widget.isDark
        ? Colors.white.withOpacity(0.5)
        : AppColors.textLightMuted.withOpacity(0.7);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
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
                  duration: const Duration(milliseconds: 300),
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
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: fontSize,
                  color: widget.isSelected ? selectedColor : unselectedColor,
                  letterSpacing: widget.isSelected ? 0.2 : 0.0,
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
