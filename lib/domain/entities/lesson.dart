/// Représente une leçon appartenant à un [Course].
///
/// Entité pure (Clean Architecture) : aucune dépendance à Firestore.
class Lesson {
  final String id;
  final String courseId;
  final String title;

  /// Position de la leçon dans le parcours du cours (0, 1, 2, ...).
  /// Utilisé pour afficher les leçons dans l'ordre sous forme de chemin,
  /// pas juste une liste plate.
  final int order;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
  });
}
