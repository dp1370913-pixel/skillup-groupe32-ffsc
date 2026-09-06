import 'package:connectivity_plus/connectivity_plus.dart';

/// Expose l'état réseau courant et les changements de connectivité,
/// utilisé pour déclencher la synchronisation Hive -> Firestore.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Émet true dès que l'appareil retrouve une connexion.
  Stream<bool> get onConnectedChange => _connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none))
      .distinct();
}
