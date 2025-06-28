import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  bookingCompleted,
  newMessage,
  serviceUpdate,
  promotion,
  reminder,
  system,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => NotificationType.system,
      ),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: data['data'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
      'data': data,
    };
  }
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  // Envoyer une notification
  Future<bool> sendNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(notification.id)
          .set(notification.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
      return false;
    }
  }

  // Récupérer les notifications d'un utilisateur
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des notifications: $e');
      return [];
    }
  }

  // Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
      });
      return true;
    } catch (e) {
      print('Erreur lors du marquage comme lu: $e');
      return false;
    }
  }

  // Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Erreur lors du marquage global: $e');
      return false;
    }
  }

  // Compter les notifications non lues
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Erreur lors du comptage: $e');
      return 0;
    }
  }

  // Stream des notifications en temps réel
  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Notifications spécifiques pour les réservations
  Future<void> notifyBookingConfirmed(
    String userId,
    String serviceName,
    String bookingId,
  ) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: 'Réservation confirmée',
      message: 'Votre réservation pour "$serviceName" a été confirmée.',
      type: NotificationType.bookingConfirmed,
      createdAt: DateTime.now(),
      data: {'bookingId': bookingId, 'serviceName': serviceName},
    );

    await sendNotification(notification);
  }

  Future<void> notifyBookingCancelled(
    String userId,
    String serviceName,
    String reason,
  ) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: 'Réservation annulée',
      message:
          'Votre réservation pour "$serviceName" a été annulée. Raison: $reason',
      type: NotificationType.bookingCancelled,
      createdAt: DateTime.now(),
      data: {'serviceName': serviceName, 'reason': reason},
    );

    await sendNotification(notification);
  }
}
