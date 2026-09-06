/// Représente la progression d'un utilisateur sur une leçon donnée.
///
/// Entité pure (Clean Architecture) : aucune dépendance à Hive ou Firestore.
class Progress {
  final String courseId;
  final String lessonId;
  final bool completed;
  final DateTime updatedAt;

  /// true tant que cette progression n'a pas encore été poussée vers Firestore.
  final bool pendingSync;

  const Progress({
    required this.courseId,
    required this.lessonId,
    required this.completed,
    required this.updatedAt,
    this.pendingSync = false,
  });

  Progress copyWith({
    bool? completed,
    DateTime? updatedAt,
    bool? pendingSync,
  }) {
    return Progress(
      courseId: courseId,
      lessonId: lessonId,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}
