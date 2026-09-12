# skillup-groupe32-ffsc
Projet SkillUp — Flutter Summer Camp 2026 — Groupe 32

## Architecture

Clean Architecture, organisée par couches dans `lib/` :

- `domain/` — entités métier pures et contrats de repository (`Progress`, `ProgressRepository`).
- `data/` — implémentations concrètes : modèles Hive (`ProgressModel`), sources de données locale (Hive) et distante (Firestore), et `ProgressRepositoryImpl`.
- `presentation/` — écrans et widgets (à compléter par les modules Auth / Liste des cours / Détail d'un cours).
- `core/` — services transverses (ex. `ConnectivityService`).

## Module « Persistance locale (Hive) »

Stratégie *offline-first* : toute mise à jour de progression est écrite immédiatement dans une box Hive locale (`progress_box`), puis marquée `pendingSync`. Un appel à `ProgressRepository.synchronize()` (déclenché au retour de connexion via `ConnectivityService`) pousse les entrées en attente vers Firestore.

⚠️ Le chemin Firestore utilisé (`users/{uid}/courses/{courseId}/progress/{lessonId}`) est provisoire : à aligner avec le modèle défini par le module `feature/firestore-model` dès qu'il est disponible.

## Module « Suivi de progression (pourcentage + jalons) »

Affiche, pour chaque cours de l'écran « Liste des cours », un pourcentage global de complétion et des badges de jalons (25 %, 50 %, 75 %, 100 %).

**Formule** : `(nombre d'étapes validées / nombre total d'étapes) * 100`, où une « étape » est une [`Lesson`](lib/domain/entities/lesson.dart) et « validée » signifie qu'une entrée [`Progress`](lib/domain/entities/progress.dart) existe pour elle avec `completed == true` (exposé aussi via le getter `isCompleted`, plus explicite côté logique métier). Une leçon sans entrée de progression connue est considérée comme non terminée.

### Fichiers

| Fichier | Rôle |
| --- | --- |
| `lib/domain/entities/progress.dart` | Getter `isCompleted` (alias de `completed`) sur l'entité existante. |
| `lib/domain/entities/course_progress.dart` | Entité pure `CourseProgress` (`completedSteps`, `totalSteps`, `percentage`, `ratio`, `isComplete`, `milestones`) + factory `CourseProgress.compute(courseId, lessons, progress)` qui applique la formule ci-dessus et calcule les 4 jalons par défaut (`CourseProgress.defaultThresholds = [25, 50, 75, 100]`). Aucune dépendance à Flutter/Hive/Firestore. |
| `lib/presentation/courses/widgets/course_progress_bar.dart` | Widget `CourseProgressBar` : `LinearProgressIndicator` (rempli via `CourseProgress.ratio`) + pourcentage arrondi, et une rangée de badges de jalons (`Wrap`, donc responsive — les badges passent à la ligne si l'espace manque). Un badge atteint est plein (icône `check_circle`, couleur mousse) ; un badge non atteint reste en contour. |
| `lib/presentation/courses/widgets/course_tile.dart` | Prend un paramètre optionnel `progress: CourseProgress?` et affiche `CourseProgressBar` sous le titre/la description, alignée avec eux. `null` → aucune barre affichée (cours sans progression chargée). |
| `lib/presentation/courses/courses_list_screen.dart` | `_CoursesListScreenState` calcule la progression de tous les cours visibles une fois qu'ils sont chargés : pour chaque cours, récupère ses leçons via `CourseRepository.getLessonsForCourse` (Firestore) et sa progression via `ProgressScope.of(context)` → `ProgressRepository.getCourseProgress` (Hive, synchrone), puis construit un `Map<courseId, CourseProgress>` transmis à chaque `CourseTile`. Recalculé au pull-to-refresh (`RefreshIndicator`). |
| `test/domain/course_progress_test.dart` | Tests unitaires de `CourseProgress.compute` : 0 %, 25 %, 100 %, leçon marquée `completed: false`, cours sans leçon (pas de division par zéro). |

### Points d'attention pour la suite

- Le calcul repose entièrement sur la progression **locale** (Hive), toujours disponible hors-ligne — pas d'appel réseau supplémentaire au-delà du chargement des leçons.
- Si le calcul de progression échoue pour une raison quelconque, l'écran affiche quand même la liste des cours (sans barre) plutôt que de bloquer toute la page.
- Les seuils de jalons (`milestoneThresholds`) sont un paramètre optionnel de `CourseProgress.compute` : personnalisables par cours si besoin plus tard (ex. cours avec un seul jalon à 100 %).
- Pas de mise à jour « live » après une leçon marquée terminée sur un autre écran (pas encore de state management partagé côté équipe, voir `progress_scope.dart`) : un retour sur l'écran « Liste des cours » ou un pull-to-refresh est nécessaire pour rafraîchir les barres.

## Mise en route

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # régénère progress_model.g.dart
flutter test
```

L'initialisation de Firebase (`Firebase.initializeApp`) sera ajoutée dans `lib/main.dart` une fois le module `feature/auth` en place.
