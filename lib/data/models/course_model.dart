import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/course.dart';

/// Modèle de conversion Firestore pour un [Course].
///
/// Contrairement à `ProgressModel`, ce modèle n'est pas persisté dans Hive :
/// Course est un contenu pédagogique en lecture seule, toujours lu depuis
/// Firestore (pas de logique offline-first ici).
class CourseModel {
  final String id;
  final String title;
  final String description;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory CourseModel.fromEntity(Course c) => CourseModel(
        id: c.id,
        title: c.title,
        description: c.description,
      );

  Course toEntity() => Course(
        id: id,
        title: title,
        description: description,
      );

  /// Construit un [CourseModel] à partir d'un document Firestore
  /// `courses/{courseId}`. Lève une [FormatException] si un champ requis
  /// est manquant ou du mauvais type, plutôt que de retomber sur une
  /// valeur par défaut silencieuse.
  factory CourseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Document courses/${doc.id} introuvable ou vide.');
    }

    final title = data['title'];
    final description = data['description'];

    if (title is! String || title.isEmpty) {
      throw FormatException(
        'Champ "title" manquant ou invalide sur courses/${doc.id}.',
      );
    }
    if (description is! String) {
      throw FormatException(
        'Champ "description" manquant ou invalide sur courses/${doc.id}.',
      );
    }

    return CourseModel(id: doc.id, title: title, description: description);
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
      };
}
