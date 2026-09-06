import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/app_user_model.dart';

/// Implémentation de [AuthRepository] : délègue à [AuthRemoteDataSource]
/// (Firebase Auth) et convertit toute [fb.FirebaseAuthException] en
/// [AuthFailure] exploitable par les écrans (jamais d'exception Firebase
/// brute qui remonte).
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl({required this.remote});

  @override
  AppUser? get currentUser {
    final user = remote.currentUser;
    return user == null ? null : AppUserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return remote.authStateChanges.map(
      (user) => user == null ? null : AppUserModel.fromFirebaseUser(user).toEntity(),
    );
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remote.signUp(email: email, password: password);
      return AppUserModel.fromFirebaseUser(user).toEntity();
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remote.signIn(email: email, password: password);
      return AppUserModel.fromFirebaseUser(user).toEntity();
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<void> signOut() => remote.signOut();

  /// Traduit les codes d'erreur Firebase Auth les plus courants en
  /// [AuthFailure] avec un message français prêt à afficher.
  AuthFailure _mapFirebaseException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AuthFailure(
          AuthFailureType.invalidEmail,
          'Adresse email invalide.',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          AuthFailureType.emailAlreadyInUse,
          'Un compte existe déjà avec cet email.',
        );
      case 'weak-password':
        return const AuthFailure(
          AuthFailureType.weakPassword,
          'Mot de passe trop faible (6 caractères minimum).',
        );
      case 'user-not-found':
        return const AuthFailure(
          AuthFailureType.userNotFound,
          'Aucun compte ne correspond à cet email.',
        );
      // Les versions récentes du SDK renvoient "invalid-credential" au lieu
      // de distinguer user-not-found/wrong-password (anti-énumération).
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(
          AuthFailureType.wrongPassword,
          'Email ou mot de passe incorrect.',
        );
      case 'network-request-failed':
        return const AuthFailure(
          AuthFailureType.network,
          'Problème de connexion réseau, réessaie.',
        );
      default:
        return AuthFailure(
          AuthFailureType.unknown,
          e.message ?? 'Une erreur inattendue est survenue.',
        );
    }
  }
}
