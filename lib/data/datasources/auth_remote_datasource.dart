import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Enveloppe fine autour de `FirebaseAuth.instance`.
///
/// Ne traduit rien : laisse remonter les [fb.FirebaseAuthException] telles
/// quelles, c'est `AuthRepositoryImpl` qui les convertit en [AuthFailure].
class AuthRemoteDataSource {
  final fb.FirebaseAuth _auth;

  AuthRemoteDataSource({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  fb.User? get currentUser => _auth.currentUser;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  Future<fb.User> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Inscription réussie mais sans utilisateur retourné.');
    }
    return user;
  }

  Future<fb.User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Connexion réussie mais sans utilisateur retourné.');
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();
}
