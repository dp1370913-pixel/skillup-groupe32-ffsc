// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/connectivity/connectivity_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/progress_local_datasource.dart';
import 'data/datasources/progress_remote_datasource.dart';
import 'data/models/progress_model.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/progress_sync_coordinator.dart';
import 'domain/entities/app_user.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/progress_repository.dart';
import 'firebase_options.dart';
import 'presentation/auth/login_screen.dart';
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

  runApp(
    MyApp(
      authRepository: authRepository,
      progressRepository: progressRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.authRepository,
    required this.progressRepository,
  });

  final AuthRepository authRepository;
  final ProgressRepository progressRepository;

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      repository: progressRepository,
      child: MaterialApp(
        title: 'SkillUp',
        theme: AppTheme.light,
        home: StreamBuilder<AppUser?>(
          stream: authRepository.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.sand,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.moss),
                ),
              );
            }

            if (snapshot.data == null) {
              return const LoginScreen();
            }

            return CoursesListScreen(
              onCourseSelected: (course) {
                // Placeholder : brancher l'écran détail ici plus tard.
                debugPrint(
                  'Cours sélectionné : ${course.id} — ${course.title}',
                );
              },
            );
          },
        ),
      ),
    );
  }
}
