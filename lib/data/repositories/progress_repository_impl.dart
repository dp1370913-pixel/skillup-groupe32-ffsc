import '../../domain/entities/progress.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../datasources/progress_remote_datasource.dart';
import '../models/progress_model.dart';

/// Implémentation "offline-first" :
/// - toute écriture va d'abord dans Hive (disponible même sans réseau),
/// - la synchronisation vers Firestore est déclenchée séparément
///   (retour de connexion, changement d'utilisateur...) via [synchronize].
///
/// [authRepository] fournit l'uid courant : sans utilisateur connecté,
/// il n'y a personne vers qui synchroniser, donc [synchronize] ne fait
/// rien plutôt que d'échouer.
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource local;
  final ProgressRemoteDataSource remote;
  final AuthRepository authRepository;

  ProgressRepositoryImpl({
    required this.local,
    required this.remote,
    required this.authRepository,
  });

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
    final uid = authRepository.currentUser?.uid;
    if (uid == null) return;

    final pending = local.getPendingSync();
    for (final model in pending) {
      await remote.push(uid: uid, model: model);
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

  @override
  Future<void> pullFromRemote() async {
    final uid = authRepository.currentUser?.uid;
    if (uid == null) return;

    final remoteEntries = await remote.fetchAll(uid: uid);
    for (final remoteModel in remoteEntries) {
      final localModel = local.get(
        courseId: remoteModel.courseId,
        lessonId: remoteModel.lessonId,
      );

      // Une modification locale pas encore synchronisée est prioritaire :
      // sinon on écraserait un changement que l'utilisateur vient de faire
      // hors-ligne avec une version distante plus ancienne. Au-delà de ça,
      // "dernière écriture gagne" sur updatedAt.
      final localIsAuthoritative = localModel != null &&
          (localModel.pendingSync || localModel.updatedAt.isAfter(remoteModel.updatedAt));

      if (!localIsAuthoritative) {
        await local.save(remoteModel);
      }
    }
  }
}
