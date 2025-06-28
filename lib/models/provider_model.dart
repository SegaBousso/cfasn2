import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String? profileImageUrl;
  final String bio;
  final String specialty;
  final int yearsOfExperience;
  final List<String> serviceIds;
  final List<String> certifications;
  final List<String> specialties;
  final List<String> workingAreas;
  final double rating;
  final int ratingsCount;
  final int completedJobs;
  final bool isVerified;
  final bool isActive;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;
  final Map<String, dynamic> businessHours;
  final Map<String, dynamic> pricing;
  final Map<String, dynamic> metadata;

  ProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.profileImageUrl,
    this.bio = '',
    this.specialty = '',
    this.yearsOfExperience = 0,
    this.serviceIds = const [],
    this.certifications = const [],
    this.specialties = const [],
    this.workingAreas = const [],
    this.rating = 0.0,
    this.ratingsCount = 0,
    this.completedJobs = 0,
    this.isVerified = false,
    this.isActive = true,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
    this.businessHours = const {},
    this.pricing = const {},
    this.metadata = const {},
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'specialty': specialty,
      'yearsOfExperience': yearsOfExperience,
      'serviceIds': serviceIds,
      'certifications': certifications,
      'specialties': specialties,
      'workingAreas': workingAreas,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'completedJobs': completedJobs,
      'isVerified': isVerified,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActiveAt': lastActiveAt != null
          ? Timestamp.fromDate(lastActiveAt!)
          : null,
      'businessHours': businessHours,
      'pricing': pricing,
      'metadata': metadata,
    };
  }

  // Créer un ProviderModel à partir d'une Map de Firestore
  factory ProviderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProviderModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'] ?? '',
      specialty: map['specialty'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      specialties: List<String>.from(map['specialties'] ?? []),
      workingAreas: List<String>.from(map['workingAreas'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingsCount: map['ratingsCount'] ?? 0,
      completedJobs: map['completedJobs'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastActiveAt: map['lastActiveAt'] is Timestamp
          ? (map['lastActiveAt'] as Timestamp).toDate()
          : null,
      businessHours: Map<String, dynamic>.from(map['businessHours'] ?? {}),
      pricing: Map<String, dynamic>.from(map['pricing'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // CopyWith pour les mises à jour
  ProviderModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    String? bio,
    String? specialty,
    int? yearsOfExperience,
    List<String>? serviceIds,
    List<String>? certifications,
    List<String>? specialties,
    List<String>? workingAreas,
    double? rating,
    int? ratingsCount,
    int? completedJobs,
    bool? isVerified,
    bool? isActive,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? businessHours,
    Map<String, dynamic>? pricing,
    Map<String, dynamic>? metadata,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      specialty: specialty ?? this.specialty,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      serviceIds: serviceIds ?? this.serviceIds,
      certifications: certifications ?? this.certifications,
      specialties: specialties ?? this.specialties,
      workingAreas: workingAreas ?? this.workingAreas,
      rating: rating ?? this.rating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      completedJobs: completedJobs ?? this.completedJobs,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      businessHours: businessHours ?? this.businessHours,
      pricing: pricing ?? this.pricing,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utiles
  bool get hasProfileImage =>
      profileImageUrl != null && profileImageUrl!.isNotEmpty;

  bool get isExperienced => yearsOfExperience >= 2;

  bool get isTopRated => rating >= 4.5 && ratingsCount >= 10;

  bool get isNewProvider => DateTime.now().difference(createdAt).inDays <= 30;

  bool get isRecentlyActive {
    if (lastActiveAt == null) return false;
    return DateTime.now().difference(lastActiveAt!).inDays <= 7;
  }

  String get experienceLevel {
    if (yearsOfExperience < 1) return 'Débutant';
    if (yearsOfExperience < 3) return 'Intermédiaire';
    if (yearsOfExperience < 5) return 'Expérimenté';
    return 'Expert';
  }

  String get statusText {
    if (!isActive) return 'Inactif';
    if (!isAvailable) return 'Indisponible';
    return 'Disponible';
  }

  @override
  String toString() {
    return 'ProviderModel(id: $id, name: $name, rating: $rating, completedJobs: $completedJobs)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProviderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
