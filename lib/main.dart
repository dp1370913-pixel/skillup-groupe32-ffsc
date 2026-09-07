// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/connectivity/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/progress_local_datasource.dart';
import 'data/datasources/progress_remote_datasource.dart';
import 'data/models/progress_model.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/progress_sync_coordinator.dart';
import 'domain/repositories/progress_repository.dart';
import 'firebase_options.dart';
import 'presentation/courses/courses_list_screen.dart';
import 'presentation/progress/progress_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProgressModelAdapter());
  await ProgressLocalDataSource.openBox();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepositoryImpl(remote: AuthRemoteDataSource());
  final progressRepository = ProgressRepositoryImpl(
    local: ProgressLocalDataSource(),
    remote: FirestoreProgressRemoteDataSource(),
    authRepository: authRepository,
  );

  ProgressSyncCoordinator(
    progressRepository: progressRepository,
    authRepository: authRepository,
    connectivityService: ConnectivityService(),
  ).start();

  runApp(MyApp(progressRepository: progressRepository));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.progressRepository});

  final ProgressRepository progressRepository;

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      repository: progressRepository,
      child: MaterialApp(
        title: 'SkillUp',
        theme: AppTheme.light,
        home: CoursesListScreen(
          onCourseSelected: (course) {
            // Placeholder : brancher l'écran détail ici plus tard.
            debugPrint('Cours sélectionné : ${course.id} — ${course.title}');
          },
        ),
      ),
    );
  }
}
