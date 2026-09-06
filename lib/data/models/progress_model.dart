import 'package:hive/hive.dart';

import '../../domain/entities/progress.dart';

part 'progress_model.g.dart';

/// Modèle de persistance Hive, miroir de l'entité [Progress].
///
/// typeId doit rester unique dans tout le projet : réservez un id à part
/// si d'autres membres ajoutent leurs propres HiveObject (users, courses...).
@HiveType(typeId: 0)
class ProgressModel extends HiveObject {
  @HiveField(0)
  final String courseId;

  @HiveField(1)
  final String lessonId;

  @HiveField(2)
  final bool completed;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final bool pendingSync;

  ProgressModel({
    required this.courseId,
    required this.lessonId,
    required this.completed,
    required this.updatedAt,
    this.pendingSync = false,
  });

  factory ProgressModel.fromEntity(Progress p) => ProgressModel(
        courseId: p.courseId,
        lessonId: p.lessonId,
        completed: p.completed,
        updatedAt: p.updatedAt,
        pendingSync: p.pendingSync,
      );

  Progress toEntity() => Progress(
        courseId: courseId,
        lessonId: lessonId,
        completed: completed,
        updatedAt: updatedAt,
        pendingSync: pendingSync,
      );

  /// Clé unique utilisée comme clé Hive (une entrée par leçon).
  static String keyFor({required String courseId, required String lessonId}) =>
      '$courseId::$lessonId';

  Map<String, dynamic> toFirestore() => {
        'courseId': courseId,
        'lessonId': lessonId,
        'completed': completed,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
