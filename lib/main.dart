import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/datasources/progress_local_datasource.dart';
import 'data/models/progress_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProgressModelAdapter());
  await ProgressLocalDataSource.openBox();

  // TODO(feature/auth): once Firebase est configuré par le module Auth,
  // ajouter ici `await Firebase.initializeApp(...)` avant runApp.

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
