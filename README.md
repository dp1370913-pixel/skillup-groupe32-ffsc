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

## Mise en route

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # régénère progress_model.g.dart
flutter test
```

L'initialisation de Firebase (`Firebase.initializeApp`) sera ajoutée dans `lib/main.dart` une fois le module `feature/auth` en place.
