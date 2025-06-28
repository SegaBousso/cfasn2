import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderRatingModel {
  final String id;
  final String providerId;
  final String userId;
  final String userName;
  final String? bookingId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVisible;
  final Map<String, double>
  criteriaRatings; // ex: {'quality': 4.5, 'punctuality': 5.0}

  ProviderRatingModel({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.userName,
    this.bookingId,
    required this.rating,
    this.comment,
    DateTime? createdAt,
    this.updatedAt,
    this.isVisible = true,
    this.criteriaRatings = const {},
  }) : createdAt = createdAt ?? DateTime.now();

  ProviderRatingModel copyWith({
    String? id,
    String? providerId,
    String? userId,
    String? userName,
    String? bookingId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    Map<String, double>? criteriaRatings,
  }) {
    return ProviderRatingModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isVisible: isVisible ?? this.isVisible,
      criteriaRatings: criteriaRatings ?? this.criteriaRatings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'userId': userId,
      'userName': userName,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isVisible': isVisible,
      'criteriaRatings': criteriaRatings,
    };
  }

  factory ProviderRatingModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ProviderRatingModel(
      id: id ?? map['id'] ?? '',
      providerId: map['providerId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
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
      criteriaRatings: Map<String, double>.from(
        (map['criteriaRatings'] ?? {}).map(
          (key, value) => MapEntry(key, (value ?? 0.0).toDouble()),
        ),
      ),
    );
  }

  // Getters utilitaires
  bool get hasComment => comment != null && comment!.isNotEmpty;
  bool get hasCriteriaRatings => criteriaRatings.isNotEmpty;

  double get averageCriteriaRating {
    if (criteriaRatings.isEmpty) return rating;
    return criteriaRatings.values.reduce((a, b) => a + b) /
        criteriaRatings.length;
  }

  String get ratingText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Très bien';
    if (rating >= 3.5) return 'Bien';
    if (rating >= 3.0) return 'Moyen';
    if (rating >= 2.0) return 'Passable';
    return 'Décevant';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProviderRatingModel &&
        other.id == id &&
        other.providerId == providerId &&
        other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ providerId.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'ProviderRatingModel(id: $id, providerId: $providerId, rating: $rating)';
  }
}
