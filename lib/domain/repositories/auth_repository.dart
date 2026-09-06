import '../entities/app_user.dart';

/// Contrat exposé aux écrans (Inscription / Connexion / état de session).
///
/// Toutes les méthodes d'écriture (`signUp`, `signIn`, `signOut`) lancent
/// une [AuthFailure] (voir `auth_failure.dart`) en cas d'échec, jamais une
/// exception Firebase brute.
abstract class AuthRepository {
  /// Utilisateur courant, ou `null` si personne n'est connecté.
  /// Lecture synchrone, pratique pour un premier rendu d'écran.
  AppUser? get currentUser;

  /// Émet le nouvel utilisateur courant à chaque connexion/déconnexion,
  /// pour que les écrans réagissent en direct (ex. redirection auto).
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signUp({required String email, required String password});

  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();
}
