import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../data/models/planning_event.dart';

/// Card widget for displaying a planning event
class PlanningEventCard extends StatelessWidget {
  final PlanningEvent event;
  final String breakLabel;

  const PlanningEventCard({
    super.key,
    required this.event,
    this.breakLabel = 'Break',
  });

  @override
  Widget build(BuildContext context) {
    // Don't render empty placeholder events
    if (event.isEmpty) {
      return const SizedBox.shrink();
    }

    if (event.isBreak) {
      return _buildBreakCard();
    }

    return _buildEventCard();
  }

  Widget _buildBreakCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.coffee, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(event.timeRange, style: AppTextStyles.caption),
          const SizedBox(width: 8),
          Text(breakLabel, style: AppTextStyles.caption),
          const Spacer(),
          Text(event.duree ?? '', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Color accent bar
              Container(width: 4, color: _getStatusColor()),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time and duration row
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              event.timeRange,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.duree ?? '',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Course name
                      Text(
                        event.displayTitle,
                        style: AppTextStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Activity type
                      if (event.typeActivite != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.typeActivite!,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                      // Instructor
                      if (event.intervenants != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.intervenants!,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (event.statutIntervention?.toLowerCase()) {
      case 'confirmé':
      case 'confirme':
        return AppColors.success;
      case 'annulé':
      case 'annule':
        return AppColors.error;
      default:
        return AppColors.gradientStart;
    }
  }
}

/// Day header for planning list
class DayHeader extends StatelessWidget {
  final DayPlanning dayPlanning;
  final bool isToday;
  final String noClassesLabel;
  final String Function(int) coursesCountLabel;

  const DayHeader({
    super.key,
    required this.dayPlanning,
    this.isToday = false,
    this.noClassesLabel = 'No classes',
    required this.coursesCountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: isToday
                  ? const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: isToday ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date_utils.DateUtils.formatShortDayName(dayPlanning.date),
              style: AppTextStyles.labelLarge.copyWith(
                color: isToday ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            date_utils.DateUtils.formatMonthDay(dayPlanning.date),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (dayPlanning.hasCourses)
            Text(
              coursesCountLabel(dayPlanning.courses.length),
              style: AppTextStyles.caption,
            )
          else
            Text(noClassesLabel, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
