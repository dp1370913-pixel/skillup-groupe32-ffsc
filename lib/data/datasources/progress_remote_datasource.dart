import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_model.dart';

/// Écriture de la progression vers le backend distant.
///
/// Abstraite pour pouvoir être substituée par un faux dans les tests
/// (voir `test/data/progress_repository_impl_test.dart`) sans dépendre
/// de Firestore.
abstract class ProgressRemoteDataSource {
  Future<void> push({required String uid, required ProgressModel model});

  /// Toute la progression connue de Firestore pour cet utilisateur, tous
  /// cours confondus. Utilisé pour rapatrier l'état d'un nouvel appareil
  /// (voir [ProgressRepositoryImpl.pullFromRemote]).
  Future<List<ProgressModel>> fetchAll({required String uid});
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

  @override
  Future<List<ProgressModel>> fetchAll({required String uid}) async {
    // Pas de collectionGroup ici : "progress" existe sous chaque
    // utilisateur, un collectionGroup sans filtre ramènerait celle des
    // autres. On parcourt donc courses/{courseId}/progress un par un.
    final coursesSnap =
        await _firestore.collection('users').doc(uid).collection('courses').get();

    final result = <ProgressModel>[];
    for (final courseDoc in coursesSnap.docs) {
      final progressSnap = await courseDoc.reference.collection('progress').get();
      for (final doc in progressSnap.docs) {
        result.add(ProgressModel.fromFirestore(doc, courseId: courseDoc.id));
      }
    }
    return result;
  }
}
