import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';

/// Implémentation de [CourseRepository] : lecture directe depuis Firestore
/// via [CourseRemoteDataSource]. Pas de cache local ni de logique
/// offline-first ici (voir `course_remote_datasource.dart`).
class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remote;

  CourseRepositoryImpl({required this.remote});

  @override
  Future<List<Course>> getCourses() async {
    final models = await remote.fetchCourses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Lesson>> getLessonsForCourse(String courseId) async {
    final models = await remote.fetchLessonsForCourse(courseId);
    return models.map((m) => m.toEntity()).toList();
  }
}
