import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/lesson.dart';

/// Modèle de conversion Firestore pour une [Lesson].
///
/// Comme [CourseModel], pas de persistance Hive : lecture directe depuis
/// Firestore (contenu pédagogique, pas une donnée saisie par l'utilisateur).
class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final int order;

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
  });

  factory LessonModel.fromEntity(Lesson l) => LessonModel(
        id: l.id,
        courseId: l.courseId,
        title: l.title,
        order: l.order,
      );

  Lesson toEntity() => Lesson(
        id: id,
        courseId: courseId,
        title: title,
        order: order,
      );

  /// Construit un [LessonModel] à partir d'un document Firestore
  /// `courses/{courseId}/lessons/{lessonId}`. [courseId] vient du chemin
  /// (le document lui-même ne le répète pas), donc il est passé à part.
  factory LessonModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String courseId,
  }) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Document lessons/${doc.id} introuvable ou vide.');
    }

    final title = data['title'];
    final order = data['order'];

    if (title is! String || title.isEmpty) {
      throw FormatException(
        'Champ "title" manquant ou invalide sur lessons/${doc.id}.',
      );
    }
    if (order is! int) {
      throw FormatException(
        'Champ "order" manquant ou invalide sur lessons/${doc.id}.',
      );
    }

    return LessonModel(id: doc.id, courseId: courseId, title: title, order: order);
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'order': order,
      };
}
