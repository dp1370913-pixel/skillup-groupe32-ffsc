import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../progress/progress_scope.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _repo = CourseRepositoryImpl(
    remote: CourseRemoteDataSource(),
  );

  late Future<List<Lesson>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _repo.getLessonsForCourse(widget.course.id);
  }

  ProgressRepository _getProgressRepository(BuildContext context) {
    return ProgressScope.of(context);
  }

  bool _isLessonCompleted(
    List<Progress> progressList,
    String lessonId,
  ) {
    for (final progress in progressList) {
      if (progress.lessonId == lessonId) {
        return progress.completed;
      }
    }

    return false;
  }

  Future<void> _toggleLesson(
    Lesson lesson,
    bool completed,
  ) async {
    final progressRepository = _getProgressRepository(context);

    await progressRepository.setLessonCompleted(
      courseId: widget.course.id,
      lessonId: lesson.id,
      completed: completed,
    );

    if (mounted) {
      setState(() {});
    }
  }

  double _calculateProgress(
    List<Lesson> lessons,
    List<Progress> progressList,
  ) {
    if (lessons.isEmpty) {
      return 0;
    }

    var completedCount = 0;

    for (final lesson in lessons) {
      if (_isLessonCompleted(progressList, lesson.id)) {
        completedCount++;
      }
    }

    return completedCount / lessons.length;
  }

  @override
  Widget build(BuildContext context) {
    final progressRepository = _getProgressRepository(context);

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.forest,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Détail du cours',
          style: GoogleFonts.fraunces(
            color: AppColors.forest,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<Lesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.moss,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  'Impossible de charger les leçons.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.error,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }

          final lessons = snapshot.data ?? const <Lesson>[];

          final progressList =
              progressRepository.getCourseProgress(widget.course.id);

          final progress = _calculateProgress(
            lessons,
            progressList,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.title,
                  style: GoogleFonts.fraunces(
                    color: AppColors.forest,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.course.description,
                  style: GoogleFonts.manrope(
                    color: AppColors.ink.withValues(alpha: 0.78),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),

                // Progression
                Text(
                  'Progression',
                  style: GoogleFonts.fraunces(
                    color: AppColors.moss,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).round()} %',
                      style: GoogleFonts.fraunces(
                        color: AppColors.forest,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${lessons.where((lesson) => _isLessonCompleted(progressList, lesson.id)).length}/${lessons.length} leçons',
                      style: GoogleFonts.manrope(
                        color: AppColors.ink.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor:
                        AppColors.ink.withValues(alpha: 0.10),
                    color: AppColors.moss,
                  ),
                ),

                const SizedBox(height: 28),

                // Liste des leçons
                Text(
                  'Leçons',
                  style: GoogleFonts.fraunces(
                    color: AppColors.moss,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                if (lessons.isEmpty)
                  Text(
                    'Aucune leçon disponible pour ce cours.',
                    style: GoogleFonts.manrope(
                      color: AppColors.ink.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                  )
                else
                  for (final lesson in lessons)
                    _LessonTile(
                      lesson: lesson,
                      completed: _isLessonCompleted(
                        progressList,
                        lesson.id,
                      ),
                      onChanged: (value) {
                        _toggleLesson(
                          lesson,
                          value,
                        );
                      },
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final bool completed;
  final ValueChanged<bool> onChanged;

  const _LessonTile({
    required this.lesson,
    required this.completed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: CheckboxListTile(
        value: completed,
        onChanged: (value) {
          onChanged(value ?? false);
        },
        controlAffinity: ListTileControlAffinity.trailing,
        secondary: CircleAvatar(
          backgroundColor:
              completed ? AppColors.moss : AppColors.forest,
          child: Text(
            '${lesson.order + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          lesson.title,
          style: GoogleFonts.manrope(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          completed ? 'Leçon terminée' : 'Leçon non terminée',
          style: GoogleFonts.manrope(
            color: AppColors.ink.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}