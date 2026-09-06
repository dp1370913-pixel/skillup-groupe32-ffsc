import '../entities/course.dart';
import '../entities/lesson.dart';

/// Contrat exposé aux écrans (Liste des cours / Détail d'un cours).
///
/// Course et Lesson sont du contenu pédagogique (pas des données saisies
/// par l'utilisateur) : contrairement à `ProgressRepository`, ce contrat
/// n'a pas besoin de logique offline-first ou de synchronisation — il lit
/// directement la source de données (Firestore).
abstract class CourseRepository {
  /// Liste des cours disponibles, sans ordre imposé.
  Future<List<Course>> getCourses();

  /// Leçons d'un cours donné, triées par [Lesson.order].
  Future<List<Lesson>> getLessonsForCourse(String courseId);
}
