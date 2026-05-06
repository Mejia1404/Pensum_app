import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/subject.dart';

class SemesterCard extends StatefulWidget {
  final bool isDark;
  final int semesterNumber;
  final List<Subject> subjects;
  final Set<String> completedSubjects;
  final Function(Subject) onToggleSubject;
  final bool Function(Subject) isSubjectUnlocked;

  const SemesterCard({
    super.key,
    required this.isDark,
    required this.semesterNumber,
    required this.subjects,
    required this.completedSubjects,
    required this.onToggleSubject,
    required this.isSubjectUnlocked,
  });

  @override
  State<SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<SemesterCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.subjects
        .where((s) => widget.completedSubjects.contains(s.code))
        .length;
    final totalCredits = widget.subjects.fold(0, (sum, s) => sum + s.credits);
    final progress = widget.subjects.isEmpty ? 0.0 : completedCount / widget.subjects.length;

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Header del semestre
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Número de semestre
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getSemesterColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.semesterNumber}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getSemesterColor(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.semesterNumber <= 12
                              ? 'Cuatrimestre ${widget.semesterNumber}'
                              : 'Electivas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount/${widget.subjects.length} materias • $totalCredits cr',
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progreso mini
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: widget.isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(_getSemesterColor()),
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: widget.isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de materias (expandible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: widget.subjects.map((subject) {
                      final isCompleted = widget.completedSubjects.contains(subject.code);
                      final isUnlocked = widget.isSubjectUnlocked(subject);

                      return _SubjectTile(
                        subject: subject,
                        isCompleted: isCompleted,
                        isUnlocked: isUnlocked,
                        isDark: widget.isDark,
                        onTap: isUnlocked ? () => widget.onToggleSubject(subject) : null,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Color _getSemesterColor() {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
    ];
    return colors[widget.semesterNumber % colors.length];
  }
}

class _SubjectTile extends StatelessWidget {
  final Subject subject;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isDark;
  final VoidCallback? onTap;

  const _SubjectTile({
    required this.subject,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isUnlocked ? 1.0 : 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success.withOpacity(0.1)
                : (isDark
                    ? AppColors.darkSurface.withOpacity(opacity)
                    : AppColors.lightBackground.withOpacity(opacity)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.3)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.success
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)
                            .withOpacity(opacity),
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          subject.code,
                          style: TextStyle(
                            fontSize: 12,
                            color: (isDark
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textLightSecondary)
                                .withOpacity(opacity),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${subject.credits} cr',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent.withOpacity(opacity),
                            ),
                          ),
                        ),
                        if (subject.isLab) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'LAB',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary.withOpacity(opacity),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Lock icon
              if (!isUnlocked)
                Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
