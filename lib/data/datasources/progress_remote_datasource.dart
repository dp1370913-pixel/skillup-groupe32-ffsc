import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_model.dart';

/// Écriture de la progression vers le backend distant.
///
/// Abstraite pour pouvoir être substituée par un faux dans les tests
/// (voir `test/data/progress_repository_impl_test.dart`) sans dépendre
/// de Firestore.
abstract class ProgressRemoteDataSource {
  Future<void> push({required String uid, required ProgressModel model});
}

/// Implémentation Firestore.
///
/// Chemin : users/{uid}/courses/{courseId}/progress/{lessonId}
/// L'uid n'est pas fixé à la construction : un utilisateur peut se
/// déconnecter/reconnecter (voire changer de compte) pendant la vie de
/// l'app, donc il est fourni à chaque appel par [ProgressRepositoryImpl].
class FirestoreProgressRemoteDataSource implements ProgressRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreProgressRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> push({required String uid, required ProgressModel model}) {
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
