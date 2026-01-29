import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/grade_utils.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../data/models/course_grades.dart';

/// Course grades card with expandable exams list
class CourseGradesCard extends StatelessWidget {
  final CourseGrades course;
  final bool isExpanded;
  final VoidCallback onTap;
  final String avgLabel;
  final String gradedLabel;
  final String creditsLabel;
  final String unnamedExamLabel;

  const CourseGradesCard({
    super.key,
    required this.course,
    required this.isExpanded,
    required this.onTap,
    this.avgLabel = 'avg',
    this.gradedLabel = 'graded',
    this.creditsLabel = 'credits',
    this.unnamedExamLabel = 'Unnamed Exam',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.gradientStart : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.displayName,
                              style: AppTextStyles.labelLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (course.intervenants != null)
                              Text(
                                course.intervenants!,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Average grade
                      _buildAverageGrade(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.assignment,
                        '${course.gradedExamsCount}/${course.totalExamsCount} $gradedLabel',
                      ),
                      const SizedBox(width: 8),
                      if (course.inscriptionCours?.nombreCreditsPotentiels !=
                          null)
                        _buildStatChip(
                          Icons.star_outline,
                          '${course.inscriptionCours!.nombreCreditsPotentiels} $creditsLabel',
                        ),
                      const Spacer(),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded exams list
          if (isExpanded && course.epreuves.isNotEmpty) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: course.epreuves.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return ExamGradeRow(
                  epreuve: course.epreuves[index],
                  unnamedExamLabel: unnamedExamLabel,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAverageGrade() {
    final average = course.averageGrade;
    final color = GradeUtils.getGradeColor(average);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            GradeUtils.formatGrade(average),
            style: AppTextStyles.h4.copyWith(color: color),
          ),
          Text(
            avgLabel,
            style: AppTextStyles.caption.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Single exam/test grade row
class ExamGradeRow extends StatelessWidget {
  final Epreuve epreuve;
  final String unnamedExamLabel;

  const ExamGradeRow({
    super.key,
    required this.epreuve,
    this.unnamedExamLabel = 'Unnamed Exam',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Exam info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  epreuve.libelle ?? unnamedExamLabel,
                  style: AppTextStyles.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (epreuve.dateObtention != null) ...[
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date_utils.DateUtils.formatForDisplay(
                          epreuve.dateObtention!,
                        ),
                        style: AppTextStyles.caption,
                      ),
                    ],
                    if (epreuve.intervenants != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          epreuve.intervenants!,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                // Appreciation
                if (epreuve.appreciationText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    epreuve.appreciationText!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Grade
          _buildGradeBadge(),
        ],
      ),
    );
  }

  Widget _buildGradeBadge() {
    final grade = epreuve.grade;
    final color = epreuve.estAbsent
        ? AppColors.error
        : GradeUtils.getGradeColor(grade);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        epreuve.displayGrade,
        style: AppTextStyles.h4.copyWith(color: color),
      ),
    );
  }
}

/// Summary card for grades overview
class GradesSummaryCard extends StatelessWidget {
  final double? averageGrade;
  final int totalCourses;
  final int totalGradedExams;
  final String overallAverageLabel;
  final String coursesLabel;
  final String gradedLabel;
  final GradeLabelStrings? gradeLabelStrings;

  const GradesSummaryCard({
    super.key,
    this.averageGrade,
    required this.totalCourses,
    required this.totalGradedExams,
    this.overallAverageLabel = 'Overall Average',
    this.coursesLabel = 'Courses',
    this.gradedLabel = 'Graded',
    this.gradeLabelStrings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Overall average
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overallAverageLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textLight.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  averageGrade != null ? averageGrade!.toStringAsFixed(1) : '-',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textLight,
                    fontSize: 36,
                  ),
                ),
                if (averageGrade != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    GradeUtils.getGradeLabel(averageGrade, gradeLabelStrings),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Stats column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatItem(
                Icons.book_outlined,
                '$totalCourses',
                coursesLabel,
              ),
              const SizedBox(height: 12),
              _buildStatItem(
                Icons.assignment_outlined,
                '$totalGradedExams',
                gradedLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: AppColors.textLight),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Icon(icon, color: AppColors.textLight.withValues(alpha: 0.8), size: 24),
      ],
    );
  }
}
