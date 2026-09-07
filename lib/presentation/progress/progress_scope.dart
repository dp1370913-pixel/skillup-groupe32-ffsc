import 'package:flutter/widgets.dart';

import '../../domain/repositories/progress_repository.dart';

/// Rend le [ProgressRepository] accessible à tout écran descendant, sans
/// imposer de package de gestion d'état (aucun choisi pour le moment côté
/// équipe) : `ProgressScope.of(context)` depuis "Liste des cours" ou
/// "Détail d'un cours" suffit pour appeler `setLessonCompleted` /
/// `getCourseProgress`.
class ProgressScope extends InheritedWidget {
  final ProgressRepository repository;

  const ProgressScope({
    super.key,
    required this.repository,
    required super.child,
  });

  static ProgressRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope.of() appelé sans ProgressScope ancêtre.');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(ProgressScope oldWidget) => repository != oldWidget.repository;
}
