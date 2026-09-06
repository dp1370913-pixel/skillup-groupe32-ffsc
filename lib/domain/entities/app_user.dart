/// Représente un utilisateur authentifié sur SkillUp.
///
/// Entité pure (Clean Architecture) : aucune dépendance à Firebase.
class AppUser {
  final String uid;
  final String email;

  const AppUser({
    required this.uid,
    required this.email,
  });
}
