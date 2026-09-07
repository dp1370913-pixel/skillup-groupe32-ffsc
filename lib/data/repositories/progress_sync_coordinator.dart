import 'dart:async';

import '../../core/connectivity/connectivity_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/progress_repository.dart';

/// Déclenche `ProgressRepository.synchronize()` automatiquement :
/// - dès que le réseau revient,
/// - dès qu'un utilisateur se connecte,
/// - une fois au démarrage (au cas où l'app est lancée déjà en ligne
///   avec une session active et des entrées en attente d'un run précédent).
///
/// N'échoue jamais bruyamment : une synchro ratée (réseau instable,
/// Firestore indisponible) sera retentée au prochain déclencheur.
class ProgressSyncCoordinator {
  final ProgressRepository progressRepository;
  final AuthRepository authRepository;
  final ConnectivityService connectivityService;

  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<dynamic>? _authSub;

  ProgressSyncCoordinator({
    required this.progressRepository,
    required this.authRepository,
    required this.connectivityService,
  });

  void start() {
    _connectivitySub = connectivityService.onConnectedChange.listen((online) {
      if (online) _trySync();
    });

    _authSub = authRepository.authStateChanges.listen((user) {
      if (user != null) _trySync();
    });

    _trySync();
  }

  Future<void> _trySync() async {
    try {
      await progressRepository.synchronize();
    } catch (_) {
      // Volontairement silencieux : on retentera au prochain déclencheur
      // (retour réseau, connexion utilisateur). Pas de queue d'erreurs
      // pour l'instant, cf. amélioration possible si des logs sont ajoutés.
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _authSub?.cancel();
  }
}
