import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LiquidGlassNavBar extends StatefulWidget {
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

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const _icons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.calendar_month_rounded,
    Icons.assignment_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Stats', 'Pensum', 'Tareas', 'Perfil'];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            height: 76,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              // Outer glow - subtle ambient light
              boxShadow: [
                // Main shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                  spreadRadius: -5,
                ),
                // Ambient glow
                BoxShadow(
                  color:
                      AppColors.accent.withOpacity(_glowAnimation.value * 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 5),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    // Liquid Glass layered effect
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: widget.isDark
                          ? [
                              const Color(0xFF1A1A1C).withOpacity(0.75),
                              const Color(0xFF0D0D0F).withOpacity(0.85),
                            ]
                          : [
                              Colors.white.withOpacity(0.75),
                              const Color(0xFFF5F5F7).withOpacity(0.85),
                            ],
                    ),
                    // Inner border glow - the "liquid" edge
                    border: Border.all(
                      width: 1.5,
                      color: widget.isDark
                          ? Colors.white
                              .withOpacity(0.12 + _glowAnimation.value * 0.05)
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  child: Container(
                    // Inner highlight layer for depth
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.3, 0.7, 1.0],
                        colors: widget.isDark
                            ? [
                                Colors.white.withOpacity(0.08),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.white.withOpacity(0.03),
                              ]
                            : [
                                Colors.white.withOpacity(0.9),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.white.withOpacity(0.4),
                              ],
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.isCompact ? 6 : 10),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalItems = _icons.length + 1;
        final itemWidth = constraints.maxWidth / totalItems;

        return Stack(
          children: [
            // Liquid Glass selected indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              left: itemWidth * widget.currentIndex,
              top: 8,
              bottom: 8,
              width: itemWidth,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: widget.isCompact ? 3 : 5),
                child: _LiquidGlassIndicator(
                  isDark: widget.isDark,
                  glowAnimation: _glowAnimation,
                ),
              ),
            ),
            // Nav items
            Row(
              children: [
                ...List.generate(_icons.length, (i) {
                  return SizedBox(
                    width: itemWidth,
                    child: _LiquidGlassNavItem(
                      icon: _icons[i],
                      label: _labels[i],
                      isSelected: widget.currentIndex == i,
                      isCompact: widget.isCompact,
                      isDark: widget.isDark,
                      onTap: () => widget.onTap(i),
                    ),
                  );
                }),
                // Progress indicator
                SizedBox(
                  width: itemWidth,
                  child: _LiquidGlassProgressIndicator(
                    progress: widget.progress,
                    isDark: widget.isDark,
                    isCompact: widget.isCompact,
                    onTap: widget.onProgressTap,
                    glowAnimation: _glowAnimation,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LiquidGlassIndicator extends StatelessWidget {
  final bool isDark;
  final Animation<double> glowAnimation;

  const _LiquidGlassIndicator({
    required this.isDark,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            // Glass-like fill
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF2A2A2E).withOpacity(0.9),
                      const Color(0xFF1F1F23).withOpacity(0.95),
                    ]
                  : [
                      Colors.white.withOpacity(0.95),
                      const Color(0xFFF0F0F2).withOpacity(0.98),
                    ],
            ),
            // Liquid border effect
            border: Border.all(
              width: 1,
              color: isDark
                  ? AppColors.accent
                      .withOpacity(0.3 + glowAnimation.value * 0.2)
                  : AppColors.accent.withOpacity(0.4),
            ),
            boxShadow: [
              // Inner glow
              BoxShadow(
                color: AppColors.accent
                    .withOpacity(0.15 + glowAnimation.value * 0.1),
                blurRadius: 12,
                spreadRadius: -2,
              ),
              // Subtle drop shadow
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          // Inner highlight
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: const Alignment(0.3, 0.3),
                colors: [
                  Colors.white.withOpacity(isDark ? 0.1 : 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LiquidGlassNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isCompact;

  const _LiquidGlassNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  State<_LiquidGlassNavItem> createState() => _LiquidGlassNavItemState();
}

class _LiquidGlassNavItemState extends State<_LiquidGlassNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.02), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant _LiquidGlassNavItem oldWidget) {
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
    final iconSize = widget.isCompact ? 23.0 : 25.0;
    final fontSize = widget.isCompact ? 9.5 : 10.5;

    final selectedColor = AppColors.accent;
    final unselectedColor = widget.isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.45);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
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
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    if (widget.isSelected) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent,
                          AppColors.accentLight,
                        ],
                      ).createShader(bounds);
                    }
                    return LinearGradient(
                      colors: [unselectedColor, unselectedColor],
                    ).createShader(bounds);
                  },
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: fontSize,
                  color: widget.isSelected ? selectedColor : unselectedColor,
                  letterSpacing: -0.3,
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

class _LiquidGlassProgressIndicator extends StatefulWidget {
  final double progress;
  final bool isDark;
  final bool isCompact;
  final VoidCallback? onTap;
  final Animation<double> glowAnimation;

  const _LiquidGlassProgressIndicator({
    required this.progress,
    required this.isDark,
    required this.isCompact,
    required this.glowAnimation,
    this.onTap,
  });

  @override
  State<_LiquidGlassProgressIndicator> createState() =>
      _LiquidGlassProgressIndicatorState();
}

class _LiquidGlassProgressIndicatorState
    extends State<_LiquidGlassProgressIndicator> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ringSize = widget.isCompact ? 38.0 : 42.0;
    final innerSize = ringSize - 8;
    final fontSize = widget.isCompact ? 10.0 : 11.0;
    final labelFontSize = widget.isCompact ? 8.5 : 9.5;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: widget.glowAnimation,
              builder: (context, child) {
                return Container(
                  width: ringSize + 4,
                  height: ringSize + 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(
                            0.2 + widget.glowAnimation.value * 0.15),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress ring with gradient
                  SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: CustomPaint(
                      painter: _LiquidProgressPainter(
                        progress: widget.progress,
                        isDark: widget.isDark,
                      ),
                    ),
                  ),
                  // Inner glass circle
                  Container(
                    width: innerSize,
                    height: innerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: widget.isDark
                            ? [
                                const Color(0xFF2A2A2E).withOpacity(0.9),
                                const Color(0xFF1F1F23).withOpacity(0.95),
                              ]
                            : [
                                Colors.white.withOpacity(0.95),
                                const Color(0xFFF0F0F2).withOpacity(0.98),
                              ],
                      ),
                      border: Border.all(
                        width: 1,
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: const Alignment(0.3, 0.3),
                          colors: [
                            Colors.white
                                .withOpacity(widget.isDark ? 0.08 : 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accent,
                                AppColors.accentLight,
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            '${(widget.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Progreso',
              style: TextStyle(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.45),
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidProgressPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _LiquidProgressPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const strokeWidth = 3.5;

    // Background track
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          AppColors.accent,
          AppColors.accentLight,
          AppColors.accent,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

// Backwards compatibility
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
    return const SizedBox.shrink();
  }
}
