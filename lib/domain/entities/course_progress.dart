import 'lesson.dart';
import 'progress.dart';

/// Un palier de progression fixe (25 %, 50 %, 75 %, 100 %) et si le cours
/// l'a atteint ou non.
class ProgressMilestone {
  final int threshold;
  final bool reached;

  const ProgressMilestone({required this.threshold, required this.reached});
}

/// Résumé de progression d'un utilisateur sur un [Course] : pourcentage
/// global et jalons atteints.
///
/// Formule : (nombre d'étapes [Lesson] dont [Progress.isCompleted] est vrai
/// / nombre total d'étapes) * 100. Une leçon sans entrée de progression
/// connue est considérée comme non terminée.
///
/// Entité pure (Clean Architecture) : ne dépend ni de Hive, ni de Firestore,
/// ni de Flutter — seulement de [Lesson] et [Progress].
class CourseProgress {
  final String courseId;
  final int completedSteps;
  final int totalSteps;
  final List<ProgressMilestone> milestones;

  const CourseProgress({
    required this.courseId,
    required this.completedSteps,
    required this.totalSteps,
    required this.milestones,
  });

  /// Jalons par défaut : 25 %, 50 %, 75 %, 100 %.
  static const List<int> defaultThresholds = [25, 50, 75, 100];

  /// Pourcentage global, entre 0 et 100. 0 si le cours n'a aucune leçon
  /// (évite une division par zéro plutôt que de renvoyer NaN).
  double get percentage => totalSteps == 0 ? 0 : (completedSteps / totalSteps) * 100;

  /// Même valeur que [percentage], normalisée entre 0.0 et 1.0, prête à
  /// être branchée sur un [LinearProgressIndicator].
  double get ratio => totalSteps == 0 ? 0 : completedSteps / totalSteps;

  bool get isComplete => totalSteps > 0 && completedSteps == totalSteps;

  /// Calcule la progression d'un cours à partir de ses leçons
  /// ([CourseRepository.getLessonsForCourse]) et des entrées de progression
  /// connues ([ProgressRepository.getCourseProgress]).
  factory CourseProgress.compute({
    required String courseId,
    required List<Lesson> lessons,
    required List<Progress> progress,
    List<int> milestoneThresholds = defaultThresholds,
  }) {
    final completedLessonIds = progress
        .where((p) => p.isCompleted)
        .map((p) => p.lessonId)
        .toSet();

    final totalSteps = lessons.length;
    final completedSteps =
        lessons.where((lesson) => completedLessonIds.contains(lesson.id)).length;

    final percentage = totalSteps == 0 ? 0.0 : (completedSteps / totalSteps) * 100;

    final milestones = [
      for (final threshold in milestoneThresholds)
        ProgressMilestone(threshold: threshold, reached: percentage >= threshold),
    ];

    return CourseProgress(
      courseId: courseId,
      completedSteps: completedSteps,
      totalSteps: totalSteps,
      milestones: milestones,
    );
  }
}
