// lib/presentation/courses/courses_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/navigation/route_observer.dart';
import '../../core/theme/app_colors.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../progress/progress_scope.dart';
import 'widgets/course_tile.dart';

/// Écran Liste des cours — instanciation directe de [CourseRepositoryImpl]
/// (conception SkillUp §4–5), sans injection de dépendances.
class CoursesListScreen extends StatefulWidget {
  final ValueChanged<Course>? onCourseSelected;
  final VoidCallback? onLogout;

  const CoursesListScreen({
    super.key,
    this.onCourseSelected,
    this.onLogout,
  });

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> with RouteAware {
  final _repo = CourseRepositoryImpl(remote: CourseRemoteDataSource());

  late Future<List<Course>> _coursesFuture = _repo.getCourses();

  /// Progression par cours (pourcentage + jalons), calculée une fois les
  /// cours et leurs leçons chargés. `null` tant qu'elle n'a pas encore été
  /// déclenchée pour le lot de cours courant (voir [build]).
  Future<Map<String, CourseProgress>>? _progressFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Appelé par [appRouteObserver] quand une route poussée au-dessus de cet
  /// écran (l'écran détail d'un cours) est dépilée et qu'on redevient
  /// visible — peu importe comment (flèche de l'app, bouton "retour" du
  /// navigateur sur le web...). L'utilisateur a pu cocher des leçons
  /// entre-temps : on recharge la progression pour le refléter.
  @override
  void didPopNext() {
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _coursesFuture = _repo.getCourses();
      _progressFuture = null;
    });
    await _coursesFuture;
  }

  /// Pour chaque cours : récupère ses leçons (nombre total d'étapes) puis
  /// calcule (pourcentage / jalons) à partir de la progression déjà connue
  /// en local ([ProgressRepository.getCourseProgress] est synchrone — pas
  /// besoin d'attendre Firestore).
  Future<Map<String, CourseProgress>> _loadCourseProgress(
    List<Course> courses,
    ProgressRepository progressRepository,
  ) async {
    final entries = await Future.wait(
      courses.map((course) async {
        final lessons = await _repo.getLessonsForCourse(course.id);
        final progress = progressRepository.getCourseProgress(course.id);
        return MapEntry(
          course.id,
          CourseProgress.compute(
            courseId: course.id,
            lessons: lessons,
            progress: progress,
          ),
        );
      }),
    );
    return Map.fromEntries(entries);
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
            _CoursesHeader(onLogout: widget.onLogout),
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

                  // Déclenché une fois par lot de cours chargé (voir
                  // _refresh pour la remise à zéro) : ProgressScope.of a
                  // besoin du BuildContext, donc c'est fait ici plutôt
                  // qu'en initState.
                  _progressFuture ??= _loadCourseProgress(
                    courses,
                    ProgressScope.of(context),
                  );

                  return RefreshIndicator(
                    color: AppColors.moss,
                    backgroundColor: AppColors.sand,
                    onRefresh: _refresh,
                    child: FutureBuilder<Map<String, CourseProgress>>(
                      future: _progressFuture,
                      builder: (context, progressSnapshot) {
                        // Pas d'erreur explicite ici : les tuiles s'affichent
                        // simplement sans barre de progression si le calcul
                        // échoue (`progressByCourse` reste vide), plutôt que
                        // de bloquer toute la liste des cours pour ça.
                        final progressByCourse =
                            progressSnapshot.data ?? const <String, CourseProgress>{};

                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                          itemCount: courses.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CourseTile(
                              course: course,
                              index: index,
                              progress: progressByCourse[course.id],
                              onTap: widget.onCourseSelected == null
                                  ? null
                                  : () => widget.onCourseSelected!(course),
                            );
                          },
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
  final VoidCallback? onLogout;

  const _CoursesHeader({this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SkillUp',
                  style: GoogleFonts.fraunces(
                    color: AppColors.moss,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
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
          ),
          if (onLogout != null)
            IconButton(
              onPressed: onLogout,
              tooltip: 'Se déconnecter',
              icon: const Icon(Icons.logout_rounded, color: AppColors.forest),
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
