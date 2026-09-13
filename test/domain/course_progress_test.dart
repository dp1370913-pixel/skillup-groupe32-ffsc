import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/domain/entities/course_progress.dart';
import 'package:skillup/domain/entities/lesson.dart';
import 'package:skillup/domain/entities/progress.dart';

void main() {
  List<Lesson> lessonsFor(String courseId, int count) => [
        for (var i = 0; i < count; i++)
          Lesson(id: 'lesson-$i', courseId: courseId, title: 'Leçon $i', order: i),
      ];

  Progress completedProgress(String courseId, String lessonId) => Progress(
        courseId: courseId,
        lessonId: lessonId,
        completed: true,
        updatedAt: DateTime(2026, 1, 1),
      );

  test('0/4 leçons validées -> 0 %, aucun jalon atteint', () {
    final result = CourseProgress.compute(
      courseId: 'course-1',
      lessons: lessonsFor('course-1', 4),
      progress: const [],
    );

    expect(result.percentage, 0);
    expect(result.isComplete, isFalse);
    expect(result.milestones.every((m) => !m.reached), isTrue);
  });

  test('1/4 leçons validées -> 25 %, seul le jalon 25 % est atteint', () {
    final result = CourseProgress.compute(
      courseId: 'course-1',
      lessons: lessonsFor('course-1', 4),
      progress: [completedProgress('course-1', 'lesson-0')],
    );

    expect(result.percentage, 25);
    expect(result.completedSteps, 1);
    expect(result.totalSteps, 4);
    expect(
      result.milestones.where((m) => m.reached).map((m) => m.threshold),
      [25],
    );
  });

  test('4/4 leçons validées -> 100 %, tous les jalons atteints', () {
    final result = CourseProgress.compute(
      courseId: 'course-1',
      lessons: lessonsFor('course-1', 4),
      progress: [
        for (var i = 0; i < 4; i++) completedProgress('course-1', 'lesson-$i'),
      ],
    );

    expect(result.percentage, 100);
    expect(result.isComplete, isTrue);
    expect(result.milestones.every((m) => m.reached), isTrue);
  });

  test('une leçon marquée completed: false ne compte pas comme validée', () {
    final result = CourseProgress.compute(
      courseId: 'course-1',
      lessons: lessonsFor('course-1', 2),
      progress: [
        completedProgress('course-1', 'lesson-0'),
        Progress(
          courseId: 'course-1',
          lessonId: 'lesson-1',
          completed: false,
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    );

    expect(result.completedSteps, 1);
    expect(result.percentage, 50);
  });

  test('cours sans leçon -> 0 %, pas de division par zéro', () {
    final result = CourseProgress.compute(
      courseId: 'course-vide',
      lessons: const [],
      progress: const [],
    );

    expect(result.percentage, 0);
    expect(result.ratio, 0);
    expect(result.isComplete, isFalse);
  });
}
