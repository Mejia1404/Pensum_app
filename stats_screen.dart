import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/pensum_data.dart';

class StatsScreen extends StatelessWidget {
  final Set<String> completedSubjects;
  final bool isDark;

  const StatsScreen({
    super.key,
    required this.completedSubjects,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final totalSubjects = PensumData.totalSubjects;
    final completedCount = completedSubjects.length;
    final pendingCount = totalSubjects - completedCount;

    final completedCredits = PensumData.subjects
        .where((s) => completedSubjects.contains(s.code))
        .fold(0, (sum, s) => sum + s.credits);
    final pendingCredits = PensumData.totalCredits - completedCredits;

    final progress = PensumData.totalCredits > 0
        ? completedCredits / PensumData.totalCredits
        : 0.0;

    // Stats por semestre
    final semesterStats = <int, Map<String, int>>{};
    for (var entry in PensumData.subjectsBySemester.entries) {
      final completed =
          entry.value.where((s) => completedSubjects.contains(s.code)).length;
      semesterStats[entry.key] = {
        'total': entry.value.length,
        'completed': completed,
      };
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadisticas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  PensumData.currentPensumName,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Circle Card
                _GlassCard(
                  isDark: isDark,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 12,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: isDark
                                      ? AppColors.darkBorder.withOpacity(0.3)
                                      : AppColors.lightBorder,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.primary),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(progress * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textDarkPrimary
                                          : AppColors.textLightPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Completado',
                                    style: TextStyle(
                                      fontSize: 12,
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
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatRow(
                                icon: Icons.check_circle_rounded,
                                label: 'Completadas',
                                value: '$completedCount',
                                color: AppColors.success,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _StatRow(
                                icon: Icons.pending_rounded,
                                label: 'Pendientes',
                                value: '$pendingCount',
                                color: AppColors.warning,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _StatRow(
                                icon: Icons.school_rounded,
                                label: 'Total',
                                value: '$totalSubjects',
                                color: AppColors.primary,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Credits Card
                Row(
                  children: [
                    Expanded(
                      child: _GlassCard(
                        isDark: isDark,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: AppColors.success,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$completedCredits',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textDarkPrimary
                                      : AppColors.textLightPrimary,
                                ),
                              ),
                              Text(
                                'Creditos\nCompletados',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textDarkMuted
                                      : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _GlassCard(
                        isDark: isDark,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.hourglass_top_rounded,
                                  color: AppColors.warning,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$pendingCredits',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textDarkPrimary
                                      : AppColors.textLightPrimary,
                                ),
                              ),
                              Text(
                                'Creditos\nPendientes',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textDarkMuted
                                      : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Semester Progress
                Text(
                  'Progreso por Semestre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                ...semesterStats.entries.map((entry) {
                  final semesterProgress = entry.value['total']! > 0
                      ? entry.value['completed']! / entry.value['total']!
                      : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SemesterProgressBar(
                      semester: entry.key,
                      completed: entry.value['completed']!,
                      total: entry.value['total']!,
                      progress: semesterProgress,
                      isDark: isDark,
                    ),
                  );
                }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _GlassCard({
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withOpacity(0.8)
                : AppColors.lightCard.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
      ],
    );
  }
}

class _SemesterProgressBar extends StatelessWidget {
  final int semester;
  final int completed;
  final int total;
  final double progress;
  final bool isDark;

  const _SemesterProgressBar({
    required this.semester,
    required this.completed,
    required this.total,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withOpacity(0.6)
            : AppColors.lightCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semestre $semester',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              Text(
                '$completed/$total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppColors.darkBorder.withOpacity(0.3)
                  : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation(
                progress == 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
