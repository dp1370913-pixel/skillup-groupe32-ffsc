// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/progress_local_datasource.dart';
import 'data/models/progress_model.dart';
import 'firebase_options.dart';
import 'presentation/courses/courses_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProgressModelAdapter());
  await ProgressLocalDataSource.openBox();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillUp',
      theme: AppTheme.light,
      home: CoursesListScreen(
        onCourseSelected: (course) {
          // Placeholder : brancher l'écran détail ici plus tard.
          debugPrint('Cours sélectionné : ${course.id} — ${course.title}');
        },
      ),
    );
  }
}
