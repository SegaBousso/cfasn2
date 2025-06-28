import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream des changements d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }

      // Obtenir les détails d'authentification de la demande
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer une nouvelle credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Se connecter à Firebase avec la credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Sauvegarder les informations utilisateur dans Firestore
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Erreur lors de la connexion avec Google: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      // Déconnexion de Google
      await _googleSignIn.signOut();
      // Déconnexion de Firebase
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Sauvegarder l'utilisateur dans Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userModel = UserModel.fromFirebaseUser(user);

      // Vérifier si l'utilisateur existe déjà
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Mettre à jour la dernière connexion
        await _firestore.collection('users').doc(user.uid).update({
          'lastSignIn': DateTime.now().toIso8601String(),
          'displayName': user.displayName ?? 'Utilisateur',
          'photoURL': user.photoURL,
        });
      } else {
        // Créer un nouveau document utilisateur
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde utilisateur: $e');
    }
  }

  // Obtenir les données utilisateur depuis Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Stream des données utilisateur
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Supprimer le compte utilisateur
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Supprimer les données Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Supprimer le compte Firebase
        await user.delete();

        // Déconnexion de Google
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('Erreur lors de la suppression du compte: $e');
      rethrow;
    }
  }

  // Re-authentifier l'utilisateur (nécessaire pour certaines opérations sensibles)
  Future<UserCredential?> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.currentUser?.reauthenticateWithCredential(credential);
    } catch (e) {
      print('Erreur lors de la re-authentification: $e');
      rethrow;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      rethrow;
    }
  }
}
