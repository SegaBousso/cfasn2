import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  client('Client'),
  provider('Prestataire'),
  admin('Administrateur');

  const UserRole(this.label);
  final String label;
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? address;
  final String? civility;
  final DateTime createdAt;
  final DateTime lastSignIn;
  final bool isVerified;
  final bool isAdmin;
  final UserRole role;
  final String? fcmToken;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.address,
    this.civility,
    required this.createdAt,
    required this.lastSignIn,
    this.isVerified = false,
    this.isAdmin = false,
    this.role = UserRole.client,
    this.fcmToken,
    this.preferences = const {},
  });

  // Créer un UserModel à partir de Firebase User
  factory UserModel.fromFirebaseUser(dynamic user) {
    final displayName = user.displayName ?? 'Utilisateur';
    final nameParts = _splitDisplayName(displayName);

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoURL: user.photoURL,
      firstName: nameParts['firstName'] ?? '',
      lastName: nameParts['lastName'] ?? '',
      phoneNumber: user.phoneNumber,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastSignIn: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'civility': civility,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignIn': Timestamp.fromDate(lastSignIn),
      'isVerified': isVerified,
      'isAdmin': isAdmin,
      'role': role.name,
      'fcmToken': fcmToken,
      'preferences': preferences,
    };
  }

  // Créer un UserModel à partir d'une Map de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Utilisateur',
      photoURL: map['photoURL'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      civility: map['civility'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
      lastSignIn: map['lastSignIn'] is Timestamp
          ? (map['lastSignIn'] as Timestamp).toDate()
          : DateTime.parse(
              map['lastSignIn'] ?? DateTime.now().toIso8601String(),
            ),
      isVerified: map['isVerified'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.client,
      ),
      fcmToken: map['fcmToken'],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
    );
  }

  // CopyWith pour les mises à jour
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? civility,
    DateTime? createdAt,
    DateTime? lastSignIn,
    bool? isVerified,
    bool? isAdmin,
    UserRole? role,
    String? fcmToken,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      civility: civility ?? this.civility,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      preferences: preferences ?? this.preferences,
    );
  }

  // Méthodes utiles
  String get fullName => '$firstName $lastName'.trim();

  bool get hasCompleteProfile =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      phoneNumber != null &&
      address != null;

  // Méthode privée pour diviser le nom d'affichage
  static Map<String, String> _splitDisplayName(String displayName) {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return {'firstName': parts.first, 'lastName': parts.skip(1).join(' ')};
    } else {
      return {'firstName': displayName, 'lastName': ''};
    }
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
