import 'dart:async';

import '../../core/connectivity/connectivity_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/progress_repository.dart';

/// Déclenche la synchronisation automatiquement :
/// - dès que le réseau revient : pousse les changements locaux en attente,
/// - dès qu'un utilisateur se connecte : rapatrie d'abord sa progression
///   distante (nouvel appareil / réinstallation), puis pousse le reste,
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
  StreamSubscription<AppUser?>? _authSub;

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
      if (user != null) _tryPullThenSync();
    });

    if (authRepository.currentUser != null) {
      _tryPullThenSync();
    } else {
      _trySync();
    }
  }

  Future<void> _tryPullThenSync() async {
    try {
      await progressRepository.pullFromRemote();
    } catch (_) {
      // Idem synchronize() : on retentera au prochain déclencheur.
    }
    await _trySync();
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
