import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String serviceId;
  final String serviceName;
  final String? providerId;
  final String? providerName;
  final String? bookingId;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool isVisible;
  final int helpfulCount;
  final Map<String, dynamic> metadata;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.serviceId,
    required this.serviceName,
    this.providerId,
    this.providerName,
    this.bookingId,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isVisible = true,
    this.helpfulCount = 0,
    this.metadata = const {},
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerId': providerId,
      'providerName': providerName,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'isVisible': isVisible,
      'helpfulCount': helpfulCount,
      'metadata': metadata,
    };
  }

  // Créer un ReviewModel à partir d'une Map de Firestore
  factory ReviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReviewModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      providerId: map['providerId'],
      providerName: map['providerName'],
      bookingId: map['bookingId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      photos: List<String>.from(map['photos'] ?? []),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      isVisible: map['isVisible'] ?? true,
      helpfulCount: map['helpfulCount'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // Créer un ReviewModel à partir d'un document Firestore
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromMap(data, doc.id);
  }

  // Convertir en Map pour Firestore (alias de toMap)
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // CopyWith pour les mises à jour
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? serviceId,
    String? serviceName,
    String? providerId,
    String? providerName,
    String? bookingId,
    double? rating,
    String? comment,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isVisible,
    int? helpfulCount,
    Map<String, dynamic>? metadata,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isVisible: isVisible ?? this.isVisible,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utiles
  bool get hasPhotos => photos.isNotEmpty;

  bool get isRecent => DateTime.now().difference(createdAt).inDays <= 30;

  String get ratingStars {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;

    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';
    stars += '☆' * (5 - fullStars - (hasHalfStar ? 1 : 0));

    return stars;
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  String get ratingText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Très bien';
    if (rating >= 3.0) return 'Bien';
    if (rating >= 2.0) return 'Moyen';
    return 'Décevant';
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, serviceName: $serviceName, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
