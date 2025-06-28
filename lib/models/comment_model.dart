import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String serviceId;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  final List<String> likes;
  final String? parentCommentId; // Pour les réponses
  final List<String> replies; // IDs des réponses
  final bool isVisible;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.serviceId,
    required this.text,
    DateTime? createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.likes = const [],
    this.parentCommentId,
    this.replies = const [],
    this.isVisible = true,
  }) : createdAt = createdAt ?? DateTime.now();

  CommentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? serviceId,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    List<String>? likes,
    String? parentCommentId,
    List<String>? replies,
    bool? isVisible,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      serviceId: serviceId ?? this.serviceId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isEdited: isEdited ?? this.isEdited,
      likes: likes ?? this.likes,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'serviceId': serviceId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEdited': isEdited,
      'likes': likes,
      'parentCommentId': parentCommentId,
      'replies': replies,
      'isVisible': isVisible,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CommentModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      serviceId: map['serviceId'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      isEdited: map['isEdited'] ?? false,
      likes: List<String>.from(map['likes'] ?? []),
      parentCommentId: map['parentCommentId'],
      replies: List<String>.from(map['replies'] ?? []),
      isVisible: map['isVisible'] ?? true,
    );
  }

  // Getters utilitaires
  int get likesCount => likes.length;
  int get repliesCount => replies.length;
  bool get isReply => parentCommentId != null;
  bool get hasReplies => replies.isNotEmpty;

  bool isLikedBy(String userId) => likes.contains(userId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel &&
        other.id == id &&
        other.userId == userId &&
        other.serviceId == serviceId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ serviceId.hashCode;

  @override
  String toString() {
    return 'CommentModel(id: $id, userName: $userName, text: ${text.length > 20 ? '${text.substring(0, 20)}...' : text})';
  }
}
