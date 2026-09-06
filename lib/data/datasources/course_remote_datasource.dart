import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/course_model.dart';
import '../models/lesson_model.dart';

/// Lecture des cours et leçons depuis Firestore.
///
/// Chemin : `courses/{courseId}` et `courses/{courseId}/lessons/{lessonId}`.
/// Contenu partagé entre tous les utilisateurs (pas de scoping par uid),
/// contrairement à [ProgressRemoteDataSource] qui écrit sous `users/{uid}/...`.
class CourseRemoteDataSource {
  final FirebaseFirestore _firestore;

  CourseRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<CourseModel>> fetchCourses() async {
    final snapshot = await _firestore.collection('courses').get();
    return snapshot.docs.map(CourseModel.fromFirestore).toList();
  }

  /// Leçons du cours [courseId], triées par ordre croissant du champ
  /// `order` directement par la requête Firestore.
  Future<List<LessonModel>> fetchLessonsForCourse(String courseId) async {
    final snapshot = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => LessonModel.fromFirestore(doc, courseId: courseId))
        .toList();
  }
}
