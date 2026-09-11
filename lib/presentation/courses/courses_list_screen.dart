// lib/presentation/courses/courses_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/entities/course.dart';
import 'widgets/course_tile.dart';

/// Écran Liste des cours — instanciation directe de [CourseRepositoryImpl]
/// (conception SkillUp §4–5), sans injection de dépendances.
class CoursesListScreen extends StatefulWidget {
  final ValueChanged<Course>? onCourseSelected;

  const CoursesListScreen({
    super.key,
    this.onCourseSelected,
  });

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _repo = CourseRepositoryImpl(remote: CourseRemoteDataSource());

  late Future<List<Course>> _coursesFuture = _repo.getCourses();

  Future<void> _refresh() async {
    setState(() {
      _coursesFuture = _repo.getCourses();
    });
    await _coursesFuture;
  }

  String _friendlyErrorMessage(Object error) {
    debugPrint('CoursesListScreen: échec chargement — $error');

    final text = error.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('network') ||
        text.contains('unavailable') ||
        text.contains('connection')) {
      return 'Pas de connexion. Vérifie ton réseau puis réessaie.';
    }
    if (text.contains('permission') || text.contains('permission-denied')) {
      return 'Accès refusé aux cours. Réessaie plus tard.';
    }
    return 'Impossible de charger les cours. Réessaie.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CoursesHeader(),
            Expanded(
              child: FutureBuilder<List<Course>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.moss),
                    );
                  }

                  if (snapshot.hasError) {
                    return _CoursesError(
                      message: _friendlyErrorMessage(snapshot.error!),
                      onRetry: _refresh,
                    );
                  }

                  final courses = snapshot.data ?? const <Course>[];
                  if (courses.isEmpty) {
                    return const _CoursesEmpty();
                  }

                  return RefreshIndicator(
                    color: AppColors.moss,
                    backgroundColor: AppColors.sand,
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      itemCount: courses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return CourseTile(
                          course: course,
                          index: index,
                          onTap: widget.onCourseSelected == null
                              ? null
                              : () => widget.onCourseSelected!(course),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoursesHeader extends StatelessWidget {
  const _CoursesHeader();

  Future<void> _signOut() async {
    final authRepo = AuthRepositoryImpl(remote: AuthRemoteDataSource());
    await authRepo.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SkillUp',
                  style: GoogleFonts.fraunces(
                    color: AppColors.moss,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Se déconnecter',
                onPressed: _signOut,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.forestMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Mes cours',
            style: GoogleFonts.fraunces(
              color: AppColors.forest,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisis un parcours et avance à ton rythme.',
            style: GoogleFonts.manrope(
              color: AppColors.ink.withValues(alpha: 0.72),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursesError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _CoursesError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.ink,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoursesEmpty extends StatelessWidget {
  const _CoursesEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 44,
              color: AppColors.moss,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun cours disponible pour le moment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.ink,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
