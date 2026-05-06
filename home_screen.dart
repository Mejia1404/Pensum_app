import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/pensum_data.dart';
import '../../../data/models/subject.dart';
import '../widgets/progress_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/semester_card.dart';

class HomeScreen extends StatelessWidget {
  final bool isDark;
  final String userName;
  final String? profileImagePath;
  final Set<String> completedSubjects;
  final double progress;
  final int completedCredits;
  final Function(Subject) onToggleSubject;
  final bool Function(Subject) isSubjectUnlocked;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.userName,
    this.profileImagePath,
    required this.completedSubjects,
    required this.progress,
    required this.completedCredits,
    required this.onToggleSubject,
    required this.isSubjectUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con saludo
          _buildHeader(),
          const SizedBox(height: 24),

          // Card de progreso principal
          ProgressCard(
            isDark: isDark,
            progress: progress,
            completedCredits: completedCredits,
            totalCredits: PensumData.totalCredits,
            completedSubjects: completedSubjects.length,
            totalSubjects: PensumData.totalSubjects,
          ),
          const SizedBox(height: 20),

          // Stats rápidos
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  isDark: isDark,
                  icon: Icons.school_rounded,
                  title: 'Materias',
                  value: '${completedSubjects.length}/${PensumData.totalSubjects}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  isDark: isDark,
                  icon: Icons.stars_rounded,
                  title: 'Créditos',
                  value: '$completedCredits/${PensumData.totalCredits}',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Título de semestres
          Text(
            'Tu Pensum',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            PensumData.currentPensumName,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de semestres
          ...PensumData.subjectsBySemester.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SemesterCard(
                isDark: isDark,
                semesterNumber: entry.key,
                subjects: entry.value,
                completedSubjects: completedSubjects,
                onToggleSubject: onToggleSubject,
                isSubjectUnlocked: isSubjectUnlocked,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Foto de perfil
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipOval(
            child: profileImagePath != null && File(profileImagePath!).existsSync()
                ? Image.file(
                    File(profileImagePath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: Icon(
                      Icons.person_rounded,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      size: 28,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),

        // Saludo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Badge de universidad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            PensumData.currentUniversity,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}
