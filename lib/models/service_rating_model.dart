import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRatingModel {
  final String id;
  final String serviceId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? bookingId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVisible;
  final List<String>
  helpful; // IDs des utilisateurs qui ont trouvé l'avis utile
  final bool isVerifiedPurchase;

  ServiceRatingModel({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.bookingId,
    required this.rating,
    this.comment,
    DateTime? createdAt,
    this.updatedAt,
    this.isVisible = true,
    this.helpful = const [],
    this.isVerifiedPurchase = false,
  }) : createdAt = createdAt ?? DateTime.now();

  ServiceRatingModel copyWith({
    String? id,
    String? serviceId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? bookingId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    List<String>? helpful,
    bool? isVerifiedPurchase,
  }) {
    return ServiceRatingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isVisible: isVisible ?? this.isVisible,
      helpful: helpful ?? this.helpful,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isVisible': isVisible,
      'helpful': helpful,
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }

  factory ServiceRatingModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ServiceRatingModel(
      id: id ?? map['id'] ?? '',
      serviceId: map['serviceId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      bookingId: map['bookingId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      isVisible: map['isVisible'] ?? true,
      helpful: List<String>.from(map['helpful'] ?? []),
      isVerifiedPurchase: map['isVerifiedPurchase'] ?? false,
    );
  }

  // Getters utilitaires
  bool get hasComment => comment != null && comment!.isNotEmpty;
  int get helpfulCount => helpful.length;

  bool isHelpfulFor(String userId) => helpful.contains(userId);

  String get ratingText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Très bien';
    if (rating >= 3.5) return 'Bien';
    if (rating >= 3.0) return 'Moyen';
    if (rating >= 2.0) return 'Passable';
    return 'Décevant';
  }

  String get starsDisplay {
    return '★' * rating.round() + '☆' * (5 - rating.round());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceRatingModel &&
        other.id == id &&
        other.serviceId == serviceId &&
        other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ serviceId.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'ServiceRatingModel(id: $id, serviceId: $serviceId, rating: $rating, userName: $userName)';
  }
}
