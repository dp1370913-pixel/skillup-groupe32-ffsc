# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SkillUp — Flutter Summer Camp 2026, Groupe 32. A Flutter app (mobile-first, multi-platform scaffolding present) for tracking course/lesson progress with offline-first sync to Firestore.

## Commands

```bash
flutter pub get                                             # install dependencies
dart run build_runner build --delete-conflicting-outputs    # regenerate *.g.dart (Hive adapters), needed after editing any @HiveType/@HiveField model
flutter test                                                 # run all tests
flutter test test/widget_test.dart                           # run a single test file
flutter analyze                                               # lint/static analysis (flutter_lints via analysis_options.yaml)
```

There is no CI config in this repo yet — `flutter analyze` and `flutter test` are the checks to run manually before considering a change done.

## Architecture

Clean Architecture, layered under `lib/`:

- `domain/` — pure business entities and repository contracts (`Progress`, `ProgressRepository`). No Hive/Firestore imports allowed here.
- `data/` — concrete implementations:
  - `data/models/` — Hive-persisted models (`ProgressModel`, generated `*.g.dart` via `build_runner`) that mirror domain entities and convert to/from them (`fromEntity`/`toEntity`) and to Firestore maps (`toFirestore`).
  - `data/datasources/` — `ProgressLocalDataSource` (Hive box access) and `ProgressRemoteDataSource` (Firestore writes).
  - `data/repositories/` — `ProgressRepositoryImpl`, the only place that coordinates local + remote sources.
- `presentation/` — screens/widgets; not yet created, reserved for the Auth / course list / course detail modules other contributors are building.
- `core/` — cross-cutting services, e.g. `core/connectivity/ConnectivityService` (wraps `connectivity_plus`, exposes `isOnline()` and `onConnectedChange`).

Screens/callers should depend on `ProgressRepository` (the domain contract), never on Hive or Firestore types directly.

### Offline-first sync strategy

- Every progress update is written **immediately** to the local Hive box `progress_box` via `ProgressRepositoryImpl.setLessonCompleted`, with `pendingSync: true`.
- `ProgressRepository.synchronize()` pushes all locally-pending entries to Firestore, then rewrites them locally with `pendingSync: false`. It is meant to be triggered by `ConnectivityService.onConnectedChange` when connectivity returns (not yet wired up in `main.dart`).
- `ProgressLocalDataSource.getPendingSync()` / `getForCourse()` are the only Hive read paths; the local box is always the source of truth for what the UI reads (`getCourseProgress`).

### Hive model conventions

- `@HiveType(typeId: ...)` values must stay globally unique across the whole project. `ProgressModel` uses `typeId: 0`; reserve a new id for any other `HiveObject` (users, courses, etc.) rather than reusing one.
- Hive keys for progress entries are `ProgressModel.keyFor(courseId, lessonId)` — one entry per lesson, keyed by `"$courseId::$lessonId"`.
- After adding/changing `@HiveField`s, re-run the `build_runner` command above and register any new adapter in `main.dart` (`Hive.registerAdapter(...)`) before opening its box.

### Firestore layout (provisional)

`ProgressRemoteDataSource` writes to `users/{uid}/courses/{courseId}/progress/{lessonId}`. This path is a placeholder — it must be aligned with whatever data model the `feature/firestore-model` branch/module defines. Check that branch before assuming this path is final.

### Known gaps / in-progress integration points

- `main.dart` initializes Hive and opens the progress box, but Firebase (`Firebase.initializeApp`) is **not yet called** — it's expected to be added once the `feature/auth` module lands (see `TODO(feature/auth)` in `lib/main.dart`).
- There is no dependency-injection/composition-root wiring yet connecting `ProgressRepositoryImpl` (with its `local`/`remote` datasources) or `ConnectivityService` into the widget tree — this will need to happen alongside the `presentation/` screens.


## Contexte produit
SkillUp — app de suivi d'apprentissage (FFSC 2026). Utilisateurs suivent des
cours, cochent des leçons, voient leur progression en % et débloquent des
jalons (25/50/75/100%).

## Direction artistique — à respecter strictement
- Palette : forêt #1F3A2E (fond sombre), mousse #3E7C59 (accent principal),
  or #C9962F (jalons/succès uniquement), sable #EDE6D3 (fond clair, cartes),
  encre #182620 (texte).
- Typographie : Google Fonts "Fraunces" pour les titres/gros chiffres,
  "Manrope" pour le texte courant. Package: google_fonts.
- INTERDIT : dégradé bleu-violet par défaut, Material 3 non personnalisé
  tel quel, icônes Material génériques sans retouche, ombres portées par
  défaut de Flutter, boutons ronds bleus standards.
- Le calcul de progression et les jalons doivent visuellement rappeler un
  "parcours" (chemin, étapes), pas une simple barre de progression plate.

## Périmètre de cette session
Je travaille uniquement sur feature/firestore-model. Le module
feature/persistance-locale (Hive, ProgressRepository, ConnectivityService)
a été écrit par un autre membre de l'équipe et est en attente de revue —
ne le modifie pas. S'il te semble avoir un problème, dis-le-moi en texte,
ne corrige rien dedans.

## Exigence qualité
Comporte-toi comme une développeuse Flutter senior : code propre, noms
explicites, gestion d'erreurs réelle (pas de TODO vides), et une interface
soignée qui évite les défauts visuels typiques d'un rendu généré à la
va-vite.

## Style de travail attendu
- Explique en français, simplement, je suis débutante.
- Propose toujours un plan avant d'écrire du code, attends ma validation.
- Après chaque fonctionnalité, dis-moi la commande exacte à lancer pour
  tester, et ce que je dois voir à l'écran.