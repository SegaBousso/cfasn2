import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  // Initialisation - écouter les changements d'authentification
  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // Utilisateur connecté - récupérer ses données
        final userData = await _authService.getUserData(user.uid);
        _user = userData ?? UserModel.fromFirebaseUser(user);
        _status = AuthStatus.authenticated;
      } else {
        // Utilisateur déconnecté
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      _errorMessage = null;
      notifyListeners();
    });
  }

  // Connexion avec Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null) {
        // L'utilisateur a annulé la connexion
        _status = AuthStatus.unauthenticated;
        _user = null;
      }
      // Le listener authStateChanges se chargera de mettre à jour l'état
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = _getErrorMessage(e);
      print('Erreur lors de la connexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.signOut();
      // Le listener authStateChanges se chargera de mettre à jour l'état
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('Erreur lors de la déconnexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer le compte
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.deleteAccount();
      // Le listener authStateChanges se chargera de mettre à jour l'état
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('Erreur lors de la suppression du compte: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Re-authentifier
  Future<bool> reauthenticate() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final userCredential = await _authService.reauthenticateWithGoogle();
      return userCredential != null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('Erreur lors de la re-authentification: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Recharger les données utilisateur
  Future<void> reloadUser() async {
    try {
      if (_authService.currentUser != null) {
        final userData = await _authService.getUserData(
          _authService.currentUser!.uid,
        );
        if (userData != null) {
          _user = userData;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erreur lors du rechargement de l\'utilisateur: $e');
    }
  }

  // Effacer les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers privés
  void _setLoading(bool loading) {
    if (loading) {
      _status = AuthStatus.loading;
    }
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé par un autre compte.';
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'invalid-email':
          return 'Adresse email invalide.';
        case 'operation-not-allowed':
          return 'Cette opération n\'est pas autorisée.';
        case 'requires-recent-login':
          return 'Cette opération nécessite une authentification récente.';
        case 'network-request-failed':
          return 'Erreur de réseau. Vérifiez votre connexion internet.';
        default:
          return 'Erreur d\'authentification: ${error.message}';
      }
    }
    return 'Une erreur inattendue s\'est produite.';
  }
}
