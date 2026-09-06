/// Représente un cours proposé sur SkillUp.
///
/// Entité pure (Clean Architecture) : aucune dépendance à Firestore.
class Course {
  final String id;
  final String title;
  final String description;

  const Course({
    required this.id,
    required this.title,
    required this.description,
  });
}
