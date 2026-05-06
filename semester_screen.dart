import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/pensum_data.dart';
import '../../../data/models/subject.dart';

class SemesterScreen extends StatefulWidget {
  final Set<String> completedSubjects;
  final bool Function(Subject) isSubjectUnlocked;
  final void Function(Subject) toggleSubjectCompletion;
  final bool isDark;

  const SemesterScreen({
    super.key,
    required this.completedSubjects,
    required this.isSubjectUnlocked,
    required this.toggleSubjectCompletion,
    required this.isDark,
  });

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: PensumData.subjectsBySemester.keys.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text(
                  PensumData.currentPensumName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: widget.isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: widget.isDark ? AppColors.accent : AppColors.primary,
                  unselectedLabelColor: widget.isDark
                      ? AppColors.textDarkMuted
                      : AppColors.textLightMuted,
                  indicatorColor: AppColors.accent,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: List.generate(
                    PensumData.subjectsBySemester.keys.length,
                    (i) {
                      final semester = i + 1;
                      final subjects =
                          PensumData.subjectsBySemester[semester] ?? [];
                      final completedInSemester = subjects
                          .where(
                              (s) => widget.completedSubjects.contains(s.code))
                          .length;
                      final isComplete = completedInSemester == subjects.length;

                      return Tab(
                        child: Row(
                          children: [
                            if (isComplete)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Text('C${i + 1}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast,
            ),
            children: List.generate(
              PensumData.subjectsBySemester.keys.length,
              (index) {
                final semester = index + 1;
                final subjects = PensumData.subjectsBySemester[semester] ?? [];
                final completedInSemester = subjects
                    .where((s) => widget.completedSubjects.contains(s.code))
                    .length;
                final isComplete = completedInSemester == subjects.length;

                return _SemesterTabContent(
                  semester: semester,
                  subjects: subjects,
                  isComplete: isComplete,
                  completedInSemester: completedInSemester,
                  completedSubjects: widget.completedSubjects,
                  isSubjectUnlocked: widget.isSubjectUnlocked,
                  toggleSubjectCompletion: widget.toggleSubjectCompletion,
                  isDark: widget.isDark,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SemesterTabContent extends StatefulWidget {
  final int semester;
  final List<Subject> subjects;
  final bool isComplete;
  final int completedInSemester;
  final Set<String> completedSubjects;
  final bool Function(Subject) isSubjectUnlocked;
  final void Function(Subject) toggleSubjectCompletion;
  final bool isDark;

  const _SemesterTabContent({
    required this.semester,
    required this.subjects,
    required this.isComplete,
    required this.completedInSemester,
    required this.completedSubjects,
    required this.isSubjectUnlocked,
    required this.toggleSubjectCompletion,
    required this.isDark,
  });

  @override
  State<_SemesterTabContent> createState() => _SemesterTabContentState();
}

class _SemesterTabContentState extends State<_SemesterTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final totalCredits = widget.subjects.fold(0, (sum, s) => sum + s.credits);

    return ListView.builder(
      physics: const BouncingScrollPhysics(
        decelerationRate: ScrollDecelerationRate.fast,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: widget.subjects.length + 1,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isComplete
                    ? AppColors.success
                    : (widget.isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cuatrimestre ${widget.semester}',
                            style: TextStyle(
                              color: widget.isComplete
                                  ? Colors.white
                                  : (widget.isDark
                                      ? AppColors.textDarkPrimary
                                      : AppColors.textLightPrimary),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalCredits creditos totales',
                            style: TextStyle(
                              color: widget.isComplete
                                  ? Colors.white70
                                  : (widget.isDark
                                      ? AppColors.textDarkMuted
                                      : AppColors.textLightMuted),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isComplete
                            ? Colors.white.withOpacity(0.2)
                            : (widget.isDark
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.primary.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isComplete)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          Text(
                            '${widget.completedInSemester}/${widget.subjects.length}',
                            style: TextStyle(
                              color: widget.isComplete
                                  ? Colors.white
                                  : (widget.isDark
                                      ? AppColors.accent
                                      : AppColors.primary),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final subject = widget.subjects[index - 1];
        return _SubjectCard(
          subject: subject,
          isCompleted: widget.completedSubjects.contains(subject.code),
          isUnlocked: widget.isSubjectUnlocked(subject),
          onTap: () => widget.toggleSubjectCompletion(subject),
          isDark: widget.isDark,
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback onTap;
  final bool isDark;

  const _SubjectCard({
    required this.subject,
    required this.isCompleted,
    required this.isUnlocked,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: isUnlocked ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : (isDark ? AppColors.darkCard : AppColors.lightCard),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? AppColors.success
                  : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.white.withOpacity(0.2)
                      : isUnlocked
                          ? AppColors.accent.withOpacity(0.1)
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : isUnlocked
                          ? (subject.isLab
                              ? Icons.science_rounded
                              : Icons.school_rounded)
                          : Icons.lock_rounded,
                  color: isCompleted
                      ? Colors.white
                      : isUnlocked
                          ? AppColors.accent
                          : (isDark
                              ? AppColors.textDarkMuted
                              : AppColors.textLightMuted),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isCompleted
                            ? Colors.white
                            : isUnlocked
                                ? (isDark
                                    ? AppColors.textDarkPrimary
                                    : AppColors.textLightPrimary)
                                : (isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.textLightMuted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          subject.code,
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.white.withOpacity(0.8)
                                : (isDark
                                    ? AppColors.textDarkMuted
                                    : AppColors.textLightMuted),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _CreditBadge(
                          credits: subject.credits,
                          isCompleted: isCompleted,
                        ),
                        if (subject.isLab) ...[
                          const SizedBox(width: 8),
                          _LabBadge(isCompleted: isCompleted),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditBadge extends StatelessWidget {
  final int credits;
  final bool isCompleted;

  const _CreditBadge({
    required this.credits,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.white.withOpacity(0.2)
            : AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$credits CR',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isCompleted ? Colors.white : AppColors.accent,
        ),
      ),
    );
  }
}

class _LabBadge extends StatelessWidget {
  final bool isCompleted;

  const _LabBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.white.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'LAB',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isCompleted ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}
