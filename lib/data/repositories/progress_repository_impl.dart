import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../datasources/progress_remote_datasource.dart';
import '../models/progress_model.dart';

/// Implémentation "offline-first" :
/// - toute écriture va d'abord dans Hive (disponible même sans réseau),
/// - la synchronisation vers Firestore est déclenchée séparément
///   (retour de connexion, bouton manuel, timer...) via [synchronize].
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource local;
  final ProgressRemoteDataSource remote;

  ProgressRepositoryImpl({required this.local, required this.remote});

  @override
  Future<void> setLessonCompleted({
    required String courseId,
    required String lessonId,
    required bool completed,
  }) async {
    final model = ProgressModel(
      courseId: courseId,
      lessonId: lessonId,
      completed: completed,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    await local.save(model);
  }

  @override
  List<Progress> getCourseProgress(String courseId) {
    return local.getForCourse(courseId).map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> synchronize() async {
    final pending = local.getPendingSync();
    for (final model in pending) {
      await remote.push(model);
      final synced = ProgressModel(
        courseId: model.courseId,
        lessonId: model.lessonId,
        completed: model.completed,
        updatedAt: model.updatedAt,
        pendingSync: false,
      );
      await local.save(synced);
    }
  }
}
