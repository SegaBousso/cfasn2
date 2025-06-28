import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  bookingCompleted,
  serviceRequested,
  serviceAccepted,
  serviceRejected,
  newReview,
  newComment,
  promotionalOffer,
  systemUpdate,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final bool isVisible;
  final String? imageUrl;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    DateTime? createdAt,
    this.isRead = false,
    this.isVisible = true,
    this.imageUrl,
    this.actionUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    bool? isVisible,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isVisible: isVisible ?? this.isVisible,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'isVisible': isVisible,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return NotificationModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      isVisible: map['isVisible'] ?? true,
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
    );
  }

  // Getters utilitaires
  String get typeString {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return 'Réservation confirmée';
      case NotificationType.bookingCancelled:
        return 'Réservation annulée';
      case NotificationType.bookingCompleted:
        return 'Réservation terminée';
      case NotificationType.serviceRequested:
        return 'Demande de service';
      case NotificationType.serviceAccepted:
        return 'Service accepté';
      case NotificationType.serviceRejected:
        return 'Service rejeté';
      case NotificationType.newReview:
        return 'Nouvel avis';
      case NotificationType.newComment:
        return 'Nouveau commentaire';
      case NotificationType.promotionalOffer:
        return 'Offre promotionnelle';
      case NotificationType.systemUpdate:
        return 'Mise à jour système';
    }
  }

  bool get isBookingRelated => [
    NotificationType.bookingConfirmed,
    NotificationType.bookingCancelled,
    NotificationType.bookingCompleted,
  ].contains(type);

  bool get isServiceRelated => [
    NotificationType.serviceRequested,
    NotificationType.serviceAccepted,
    NotificationType.serviceRejected,
  ].contains(type);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: ${type.name}, isRead: $isRead)';
  }
}
