// lib/presentation/courses/widgets/course_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/course_progress.dart';
import 'step_trail.dart';

/// Chemin d'étapes ([StepTrail]) + badges de jalons pour un cours.
///
/// Responsive : le chemin occupe tout l'espace disponible (`Expanded`), le
/// pourcentage reste sur la même ligne, et les badges de jalons passent à
/// la ligne automatiquement (`Wrap`) si la largeur manque — utile sur les
/// petits écrans ou avec une échelle de texte agrandie.
class CourseProgressBar extends StatelessWidget {
  final CourseProgress progress;

  const CourseProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    // Cours sans leçon connue : rien à afficher plutôt qu'une barre à 0 %
    // trompeuse.
    if (progress.totalSteps == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: StepTrail(
                completedSteps: progress.completedSteps,
                totalSteps: progress.totalSteps,
                isComplete: progress.isComplete,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${progress.percentage.round()}%',
              semanticsLabel: '${progress.percentage.round()} pour cent complété',
              style: GoogleFonts.manrope(
                color: AppColors.forest,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MilestonesRow(milestones: progress.milestones),
      ],
    );
  }
}

/// Rangée de badges de jalons, réutilisable indépendamment de
/// [CourseProgressBar] (ex. écran détail d'un cours).
///
/// Responsive : passe à la ligne automatiquement (`Wrap`) si la largeur
/// manque — utile sur les petits écrans ou avec une échelle de texte
/// agrandie.
class MilestonesRow extends StatelessWidget {
  final List<ProgressMilestone> milestones;

  const MilestonesRow({super.key, required this.milestones});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final milestone in milestones) _MilestoneBadge(milestone: milestone),
      ],
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  final ProgressMilestone milestone;

  const _MilestoneBadge({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final reached = milestone.reached;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: reached ? AppColors.moss.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: reached ? AppColors.moss : AppColors.sandMuted),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reached ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: reached ? AppColors.moss : AppColors.ink.withValues(alpha: 0.38),
          ),
          const SizedBox(width: 4),
          Text(
            '${milestone.threshold}%',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: reached ? AppColors.forest : AppColors.ink.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
