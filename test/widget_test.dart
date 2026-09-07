import 'package:flutter_test/flutter_test.dart';

import 'package:skillup/domain/entities/progress.dart';
import 'package:skillup/domain/repositories/progress_repository.dart';
import 'package:skillup/main.dart';

class _FakeProgressRepository implements ProgressRepository {
  @override
  Future<void> setLessonCompleted({
    required String courseId,
    required String lessonId,
    required bool completed,
  }) async {}

  @override
  List<Progress> getCourseProgress(String courseId) => const [];

  @override
  Future<void> synchronize() async {}

  @override
  Future<void> pullFromRemote() async {}
}

void main() {
  testWidgets('App builds and shows home title', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(progressRepository: _FakeProgressRepository()));

    expect(find.text('SkillUp — Groupe 32'), findsOneWidget);
  });
}
