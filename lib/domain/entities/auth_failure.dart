/// Catégories d'erreurs d'authentification connues, indépendantes de
/// Firebase : les écrans se basent sur [AuthFailureType] pour adapter leur
/// message/UI, [AuthFailure.message] donne un texte déjà prêt à afficher.
enum AuthFailureType {
  invalidEmail,
  emailAlreadyInUse,
  weakPassword,
  userNotFound,
  wrongPassword,
  network,
  unknown,
}

/// Erreur d'authentification exploitable par les écrans, avec un message
/// déjà en français — évite de laisser fuiter une [FirebaseAuthException]
/// brute jusqu'à l'UI.
class AuthFailure implements Exception {
  final AuthFailureType type;
  final String message;

  const AuthFailure(this.type, this.message);

  @override
  String toString() => 'AuthFailure($type): $message';
}
