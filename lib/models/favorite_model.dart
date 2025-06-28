import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? serviceId,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FavoriteModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteModel &&
        other.id == id &&
        other.userId == userId &&
        other.serviceId == serviceId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        serviceId.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'FavoriteModel(id: $id, userId: $userId, serviceId: $serviceId)';
  }
}
