import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../data/pensum_data.dart';
import '../../../data/models/subject.dart';
import '../../home/screens/home_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../semester/screens/semester_screen.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final VoidCallback? onLogout;

  const MainScreen({
    super.key,
    required this.themeNotifier,
    this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  Set<String> completedSubjects = {};
  late SharedPreferences prefs;
  bool isLoading = true;
  String userName = 'Estudiante';
  String? profileImagePath;
  bool _isNavbarVisible = true;

  // Valores calculados cacheados
  int _completedCredits = 0;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        final pensumSuffix = PensumData.currentPensumId;
        completedSubjects =
            (prefs.getStringList('completedSubjects_$pensumSuffix') ?? [])
                .toSet();
        userName = prefs.getString('userName') ?? PensumData.currentDegree;
        profileImagePath = prefs.getString('profileImagePath');
        _updateCalculatedValues();
        isLoading = false;
      });
    }
  }

  void _updateCalculatedValues() {
    _completedCredits = PensumData.subjects
        .where((s) => completedSubjects.contains(s.code))
        .fold(0, (sum, s) => sum + s.credits);
    _progress = PensumData.totalCredits > 0
        ? _completedCredits / PensumData.totalCredits
        : 0.0;
  }

  Future<void> _saveData() async {
    final pensumSuffix = PensumData.currentPensumId;
    await prefs.setStringList(
      'completedSubjects_$pensumSuffix',
      completedSubjects.toList(),
    );
  }

  bool isSubjectUnlocked(Subject subject) {
    if (subject.prerequisites.isEmpty) return true;
    return subject.prerequisites
        .every((pre) => completedSubjects.contains(pre));
  }

  void toggleSubjectCompletion(Subject subject) {
    if (!isSubjectUnlocked(subject)) return;

    setState(() {
      if (completedSubjects.contains(subject.code)) {
        completedSubjects.remove(subject.code);
        _showSnackbar('Materia desmarcada: ${subject.name}', isError: true);
      } else {
        completedSubjects.add(subject.code);
        _showSnackbar('Materia completada: ${subject.name}', isError: false);
      }
      _updateCalculatedValues();
      _saveData();
    });
  }

  void _showSnackbar(String message, {required bool isError}) {
    final isDark = widget.themeNotifier.isDarkMode(context);
    final subjectName = message.replaceAll(
      RegExp(r'^Materia (completada|desmarcada): '),
      '',
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        );

        final overlayOpacity =
            Tween<double>(begin: 0, end: 0.2).animate(curvedAnimation);

        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: curvedAnimation,
                builder: (context, _) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8 * curvedAnimation.value,
                      sigmaY: 8 * curvedAnimation.value,
                    ),
                    child: Container(
                      color:
                          Colors.black.withOpacity(overlayOpacity.value * 0.2),
                    ),
                  );
                },
              ),
            ),
            FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                    reverseCurve: Curves.easeIn,
                  ),
                ),
                child: child,
              ),
            ),
          ],
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCard.withOpacity(0.95)
                    : AppColors.lightCard.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isError
                          ? AppColors.accent.withOpacity(0.15)
                          : AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isError
                          ? Icons.remove_circle_outline_rounded
                          : Icons.check_circle_rounded,
                      color: isError ? AppColors.accent : AppColors.success,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isError ? 'Materia desmarcada' : 'Materia completada',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDarkMuted
                                : AppColors.textLightMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subjectName,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProgressDetails() {
    final isDark = widget.themeNotifier.isDarkMode(context);
    final completed = completedSubjects.length;
    final total = PensumData.totalSubjects;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
          reverseCurve: Curves.easeInBack,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: curvedAnimation,
                builder: (context, _) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 12 * curvedAnimation.value,
                      sigmaY: 12 * curvedAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(
                          (0.4 * curvedAnimation.value).clamp(0.0, 1.0)),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.35, 0.35),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: ScaleTransition(
                  alignment: const Alignment(0.8, 0.8),
                  scale: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(curvedAnimation),
                  child: FadeTransition(
                    opacity: curvedAnimation,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tu Progreso',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 15,
                            strokeCap: StrokeCap.round,
                            backgroundColor: isDark
                                ? AppColors.darkBorder.withOpacity(0.3)
                                : AppColors.lightBorder,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.accent : AppColors.primary,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(_progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textDarkPrimary
                                    : AppColors.textLightPrimary,
                              ),
                            ),
                            Text(
                              'Completado',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailStat(
                          label: 'Completados',
                          value: '$completed',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        _DetailStat(
                          label: 'Faltantes',
                          value: '${total - completed}',
                          icon: Icons.pending_rounded,
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('selectedPensumId');
    await prefs.remove('profileImagePath');

    if (widget.onLogout != null) {
      widget.onLogout!();
    }
  }

  void _resetProgress() async {
    final pensumSuffix = PensumData.currentPensumId;
    setState(() {
      completedSubjects.clear();
      _updateCalculatedValues();
    });
    await prefs.remove('completedSubjects_$pensumSuffix');
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeNotifier,
      builder: (context, _) {
        final isDark = widget.themeNotifier.isDarkMode(context);

        if (isLoading) {
          return Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final screens = [
          // Home
          HomeScreen(
            isDark: isDark,
            userName: userName,
            profileImagePath: profileImagePath,
            completedSubjects: completedSubjects,
            progress: _progress,
            completedCredits: _completedCredits,
            onToggleSubject: toggleSubjectCompletion,
            isSubjectUnlocked: isSubjectUnlocked,
          ),

          // Stats
          StatsScreen(
            completedSubjects: completedSubjects,
            isDark: isDark,
          ),

          // Semester / Pensum
          SemesterScreen(
            completedSubjects: completedSubjects,
            isSubjectUnlocked: isSubjectUnlocked,
            toggleSubjectCompletion: toggleSubjectCompletion,
            isDark: isDark,
          ),

          // Tasks
          TasksScreen(isDark: isDark),

          // Profile
          ProfileScreen(
            isDark: isDark,
            themeNotifier: widget.themeNotifier,
            userName: userName,
            profileImagePath: profileImagePath,
            progress: _progress,
            completedCredits: _completedCredits,
            completedSubjectsCount: completedSubjects.length,
            onProfileUpdated: _loadData,
            onLogout: _handleLogout,
            onReset: _resetProgress,
          ),
        ];

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          extendBody: true,
          body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (_isNavbarVisible) setState(() => _isNavbarVisible = false);
              } else if (notification.direction == ScrollDirection.forward) {
                if (!_isNavbarVisible) setState(() => _isNavbarVisible = true);
              }
              return true;
            },
            child: SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final isNext = _currentIndex >= _previousIndex;
                  final slideIn =
                      isNext ? const Offset(0.15, 0) : const Offset(-0.15, 0);
                  final slideOut =
                      isNext ? const Offset(-0.15, 0) : const Offset(0.15, 0);

                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: (child.key == ValueKey<int>(_currentIndex))
                          ? slideIn
                          : slideOut,
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: screens[_currentIndex],
                ),
              ),
            ),
          ),
          bottomNavigationBar: AnimatedSlide(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            offset: _isNavbarVisible ? Offset.zero : const Offset(0, 1.5),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final isCompact = screenWidth < 380;

                    return LiquidGlassNavBar(
                      currentIndex: _currentIndex,
                      isDark: isDark,
                      isCompact: isCompact,
                      onTap: (index) {
                        if (_currentIndex != index) {
                          setState(() {
                            _previousIndex = _currentIndex;
                            _currentIndex = index;
                            _isNavbarVisible = true;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
