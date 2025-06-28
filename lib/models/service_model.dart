import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  final String? imageUrl;
  final double rating;
  final int totalReviews;
  final double price;
  final String currency;
  final String? estimatedDuration;
  final String categoryId;
  final String categoryName;
  final String? providerId;
  final String? providerName;
  final bool isAvailable;
  final bool isActive;
  final int likesCount;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.imageUrl,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.price,
    this.currency = 'EUR',
    this.estimatedDuration,
    required this.categoryId,
    required this.categoryName,
    this.providerId,
    this.providerName,
    this.isAvailable = true,
    this.isActive = true,
    this.likesCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.tags = const [],
    this.metadata = const {},
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'price': price,
      'currency': currency,
      'estimatedDuration': estimatedDuration,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'providerId': providerId,
      'providerName': providerName,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'tags': tags,
      'metadata': metadata,
    };
  }

  // Méthodes spécifiques pour Firestore
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // Créer un ServiceModel à partir d'une Map de Firestore
  factory ServiceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'],
      imageUrl: map['imageUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'EUR',
      estimatedDuration: map['estimatedDuration'],
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      providerId: map['providerId'],
      providerName: map['providerName'],
      isAvailable: map['isAvailable'] ?? true,
      isActive: map['isActive'] ?? true,
      likesCount: map['likesCount'] ?? 0,
      viewsCount: map['viewsCount'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // Factory method spécifique pour Firestore
  factory ServiceModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ServiceModel.fromMap(data, documentId);
  }

  // CopyWith pour les mises à jour
  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    String? imageUrl,
    double? rating,
    int? totalReviews,
    double? price,
    String? currency,
    String? estimatedDuration,
    String? categoryId,
    String? categoryName,
    String? providerId,
    String? providerName,
    bool? isAvailable,
    bool? isActive,
    int? likesCount,
    int? viewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utiles
  String get formattedPrice => '$price $currency';

  bool get hasImage => imageUrl != null || imagePath != null;

  String get displayImage => imageUrl ?? imagePath ?? '';

  bool get isPopular => rating >= 4.0 && totalReviews >= 10;

  bool get isNew => DateTime.now().difference(createdAt).inDays <= 30;

  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name, price: $formattedPrice, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
