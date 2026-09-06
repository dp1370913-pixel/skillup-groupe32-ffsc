import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';

/// Convertit un [fb.User] Firebase en entité domaine [AppUser].
///
/// Pas de persistance Hive ni de sérialisation Firestore ici : Firebase
/// Auth gère lui-même le stockage du compte, ce modèle ne fait que
/// traduire son objet SDK vers notre entité.
class AppUserModel {
  final String uid;
  final String email;

  const AppUserModel({required this.uid, required this.email});

  /// [user.email] est nullable côté SDK, mais toujours renseigné pour un
  /// compte créé par email/mot de passe. On lève une erreur explicite
  /// plutôt que de retomber sur une chaîne vide silencieuse.
  factory AppUserModel.fromFirebaseUser(fb.User user) {
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError(
        'Utilisateur Firebase ${user.uid} sans email : incohérent pour un '
        'compte email/mot de passe.',
      );
    }
    return AppUserModel(uid: user.uid, email: email);
  }

  AppUser toEntity() => AppUser(uid: uid, email: email);
}
