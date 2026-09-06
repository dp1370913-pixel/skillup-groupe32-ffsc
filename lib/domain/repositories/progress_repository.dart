import '../entities/progress.dart';

/// Contrat exposé aux écrans (Liste des cours / Détail d'un cours).
///
/// L'implémentation gère la logique locale (Hive) + distante (Firestore),
/// les écrans n'ont pas à savoir laquelle des deux sources répond.
abstract class ProgressRepository {
  /// Marque une leçon comme terminée (ou non), en local immédiatement.
  Future<void> setLessonCompleted({
    required String courseId,
    required String lessonId,
    required bool completed,
  });

  /// Progression connue pour un cours (source locale, toujours disponible).
  List<Progress> getCourseProgress(String courseId);

  /// Pousse vers Firestore toutes les entrées locales marquées `pendingSync`.
  /// À appeler quand la connectivité revient.
  Future<void> synchronize();
}
