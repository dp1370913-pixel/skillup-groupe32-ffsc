import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:skillup/data/datasources/progress_local_datasource.dart';
import 'package:skillup/data/datasources/progress_remote_datasource.dart';
import 'package:skillup/data/models/progress_model.dart';
import 'package:skillup/data/repositories/progress_repository_impl.dart';
import 'package:skillup/domain/entities/app_user.dart';
import 'package:skillup/domain/repositories/auth_repository.dart';

/// [AuthRepository] de test : uid réglable directement, pas de Firebase.
class FakeAuthRepository implements AuthRepository {
  AppUser? user;

  FakeAuthRepository({this.user});

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AppUser> signUp({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

/// Remplace Firestore : enregistre juste ce qui a été poussé.
class FakeProgressRemoteDataSource implements ProgressRemoteDataSource {
  final List<({String uid, ProgressModel model})> pushed = [];

  @override
  Future<void> push({required String uid, required ProgressModel model}) async {
    pushed.add((uid: uid, model: model));
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProgressModelAdapter());
    }
    await ProgressLocalDataSource.openBox();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('setLessonCompleted écrit en local et marque pendingSync', () async {
    final repo = ProgressRepositoryImpl(
      local: ProgressLocalDataSource(),
      remote: FakeProgressRemoteDataSource(),
      authRepository: FakeAuthRepository(),
    );

    await repo.setLessonCompleted(
      courseId: 'course-1',
      lessonId: 'lesson-1',
      completed: true,
    );

    final progress = repo.getCourseProgress('course-1');
    expect(progress, hasLength(1));
    expect(progress.single.completed, isTrue);
    expect(progress.single.pendingSync, isTrue);
  });

  test('synchronize() pousse les entrées en attente et les marque comme synchronisées', () async {
    final local = ProgressLocalDataSource();
    final remote = FakeProgressRemoteDataSource();
    final repo = ProgressRepositoryImpl(
      local: local,
      remote: remote,
      authRepository: FakeAuthRepository(user: const AppUser(uid: 'u1', email: 'a@b.com')),
    );

    await repo.setLessonCompleted(
      courseId: 'course-1',
      lessonId: 'lesson-1',
      completed: true,
    );

    await repo.synchronize();

    expect(remote.pushed, hasLength(1));
    expect(remote.pushed.single.uid, 'u1');
    expect(local.getPendingSync(), isEmpty);
  });

  test("synchronize() ne fait rien si personne n'est connecté", () async {
    final local = ProgressLocalDataSource();
    final remote = FakeProgressRemoteDataSource();
    final repo = ProgressRepositoryImpl(
      local: local,
      remote: remote,
      authRepository: FakeAuthRepository(user: null),
    );

    await repo.setLessonCompleted(
      courseId: 'course-1',
      lessonId: 'lesson-1',
      completed: true,
    );

    await repo.synchronize();

    expect(remote.pushed, isEmpty);
    expect(local.getPendingSync(), hasLength(1));
  });
}
