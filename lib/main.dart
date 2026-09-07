import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/connectivity/connectivity_service.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/progress_local_datasource.dart';
import 'data/datasources/progress_remote_datasource.dart';
import 'data/models/progress_model.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/progress_sync_coordinator.dart';
import 'firebase_options.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillUp',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'SkillUp'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('SkillUp — Groupe 32'),
      ),
    );
  }
}
