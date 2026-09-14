// lib/presentation/courses/widgets/course_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/course_progress.dart';
import 'course_progress_bar.dart';

/// Tuile d'un cours : titre Fraunces, description Manrope, accent mousse.
///
/// [progress] est optionnel : `null` tant que la progression n'a pas fini
/// de se charger, ou pour un appelant qui ne suit pas la progression —
/// dans les deux cas la barre et les jalons sont simplement omis.
class CourseTile extends StatelessWidget {
  final Course course;
  final int index;
  final CourseProgress? progress;
  final VoidCallback? onTap;

  const CourseTile({
    super.key,
    required this.course,
    required this.index,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final number = (index + 1).toString().padLeft(2, '0');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sandMuted),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        number,
                        style: GoogleFonts.fraunces(
                          color: AppColors.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: GoogleFonts.fraunces(
                              color: AppColors.forest,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: AppColors.ink.withValues(alpha: 0.78),
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.moss,
                      ),
                    ),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 14),
                  // Aligné avec le titre/description (largeur du numéro +
                  // son espacement), pour garder la colonne verticale nette.
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: CourseProgressBar(progress: progress!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
