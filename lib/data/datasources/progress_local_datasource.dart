import 'package:hive/hive.dart';

import '../models/progress_model.dart';

/// Accès à la boîte Hive contenant la progression, en local.
class ProgressLocalDataSource {
  static const String boxName = 'progress_box';

  Box<ProgressModel> get _box => Hive.box<ProgressModel>(boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<ProgressModel>(boxName);
    }
  }

  Future<void> save(ProgressModel model) {
    final key = ProgressModel.keyFor(
      courseId: model.courseId,
      lessonId: model.lessonId,
    );
    return _box.put(key, model);
  }

  List<ProgressModel> getForCourse(String courseId) {
    return _box.values.where((m) => m.courseId == courseId).toList();
  }

  List<ProgressModel> getPendingSync() {
    return _box.values.where((m) => m.pendingSync).toList();
  }
}
