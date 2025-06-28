import 'package:cloud_firestore/cloud_firestore.dart';

/// Script pour promouvoir un utilisateur en administrateur
/// ⚠️ À utiliser uniquement pour créer le premier admin !
class AdminPromotion {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Promouvoir un utilisateur en administrateur
  /// [userEmail] - Email de l'utilisateur à promouvoir
  static Future<bool> promoteToAdmin(String userEmail) async {
    try {
      // Chercher l'utilisateur par email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Utilisateur non trouvé avec l\'email: $userEmail');
        return false;
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      print('👤 Utilisateur trouvé: ${userData['displayName']}');
      print('📧 Email: ${userData['email']}');
      print('🎭 Rôle actuel: ${userData['role']}');

      // Mettre à jour vers admin
      await _firestore.collection('users').doc(userDoc.id).update({
        'role': 'admin',
        'isAdmin': true,
      });

      print('✅ Utilisateur promu en administrateur avec succès !');
      print('🔄 L\'utilisateur doit se reconnecter pour voir les changements.');

      return true;
    } catch (e) {
      print('❌ Erreur lors de la promotion: $e');
      return false;
    }
  }

  /// Lister tous les administrateurs
  static Future<void> listAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      print('👥 Administrateurs dans le système:');
      print('═══════════════════════════════════');

      if (querySnapshot.docs.isEmpty) {
        print('   Aucun administrateur trouvé.');
      } else {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          print('   • ${data['displayName']} (${data['email']})');
        }
      }

      print('═══════════════════════════════════');
    } catch (e) {
      print('❌ Erreur lors de la récupération des admins: $e');
    }
  }

  /// Rétrograder un admin en client
  static Future<bool> demoteAdmin(String userEmail) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Utilisateur non trouvé avec l\'email: $userEmail');
        return false;
      }

      final userDoc = querySnapshot.docs.first;

      await _firestore.collection('users').doc(userDoc.id).update({
        'role': 'client',
        'isAdmin': false,
      });

      print('✅ Administrateur rétrogradé en client avec succès !');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la rétrogradation: $e');
      return false;
    }
  }
}

/// Exemple d'utilisation:
/// 
/// void main() async {
///   // Promouvoir votre email en admin
///   await AdminPromotion.promoteToAdmin('votre.email@gmail.com');
///   
///   // Lister tous les admins
///   await AdminPromotion.listAdmins();
/// }
