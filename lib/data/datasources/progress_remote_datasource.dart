import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_model.dart';

/// Écriture de la progression vers Firestore.
///
/// Chemin attendu : users/{uid}/courses/{courseId}/progress/{lessonId}
/// À ajuster une fois le modèle de données Firestore (feature/firestore-model)
/// figé par le reste de l'équipe.
class ProgressRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String uid;

  ProgressRemoteDataSource({
    required this.uid,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> push(ProgressModel model) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('courses')
        .doc(model.courseId)
        .collection('progress')
        .doc(model.lessonId)
        .set(model.toFirestore(), SetOptions(merge: true));
  }
}
