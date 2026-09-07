import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Construit un [ProgressModel] depuis un document
  /// `users/{uid}/courses/{courseId}/progress/{lessonId}`.
  /// Le résultat n'est jamais `pendingSync` : il vient déjà de Firestore.
  factory ProgressModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String courseId,
  }) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Document progress/${doc.id} introuvable ou vide.');
    }

    final completed = data['completed'];
    final updatedAt = data['updatedAt'];

    if (completed is! bool) {
      throw FormatException(
        'Champ "completed" manquant ou invalide sur progress/${doc.id}.',
      );
    }
    if (updatedAt is! String) {
      throw FormatException(
        'Champ "updatedAt" manquant ou invalide sur progress/${doc.id}.',
      );
    }

    return ProgressModel(
      courseId: courseId,
      lessonId: doc.id,
      completed: completed,
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
