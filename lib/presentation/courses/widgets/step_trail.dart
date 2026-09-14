import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Visualise une progression comme un chemin d'étapes — un segment par
/// leçon — plutôt qu'une barre de remplissage continue.
///
/// Conforme à la direction artistique SkillUp : la progression doit
/// rappeler un parcours (chemin, étapes), pas une simple barre plate.
class StepTrail extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final bool isComplete;

  const StepTrail({
    super.key,
    required this.completedSteps,
    required this.totalSteps,
    this.isComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSteps == 0) {
      return const SizedBox.shrink();
    }

    final fillColor = isComplete ? AppColors.gold : AppColors.moss;

    return Row(
      children: [
        for (var i = 0; i < totalSteps; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                color: i < completedSteps ? fillColor : AppColors.sandMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
