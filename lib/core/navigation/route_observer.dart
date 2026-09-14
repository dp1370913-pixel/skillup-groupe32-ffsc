import 'package:flutter/material.dart';

/// Observateur de navigation partagé, enregistré sur le [Navigator] racine
/// dans `main.dart`. Permet à un écran (via [RouteAware]) de savoir quand il
/// redevient visible après qu'une route poussée au-dessus de lui a été
/// dépilée — y compris via le bouton "retour" du navigateur sur le web, pas
/// seulement un `Navigator.pop()` explicite déclenché depuis l'app.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
