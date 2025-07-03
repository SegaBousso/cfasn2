import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';

enum BookingStatus {
  pending('En attente'),
  confirmed('Confirmée'),
  inProgress('En cours'),
  completed('Terminée'),
  cancelled('Annulée'),
  refunded('Remboursée');

  const BookingStatus(this.label);
  final String label;
}

enum PaymentStatus {
  pending('En attente'),
  paid('Payé'),
  failed('Échoué'),
  refunded('Remboursé');

  const PaymentStatus(this.label);
  final String label;
}

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String? userAddress;
  final DateTime bookingDate;
  final DateTime serviceDate;
  final ServiceModel service;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final String serviceDescription;
  final String additionalDetails;
  final double totalAmount;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? providerId;
  final String? providerName;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final Map<String, dynamic> metadata;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    this.userAddress,
    required this.bookingDate,
    required this.serviceDate,
    required this.service,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    required this.paymentMethod,
    required this.serviceDescription,
    this.additionalDetails = '',
    required this.totalAmount,
    this.currency = 'EUR',
    required this.createdAt,
    required this.updatedAt,
    this.providerId,
    this.providerName,
    this.cancellationReason,
    this.cancelledAt,
    this.metadata = const {},
  });

  // Créer à partir d'un utilisateur et d'un service
  factory BookingModel.create({
    required String id,
    required UserModel user,
    required ServiceModel service,
    required DateTime serviceDate,
    required String paymentMethod,
    String serviceDescription = '',
    String additionalDetails = '',
  }) {
    final now = DateTime.now();
    return BookingModel(
      id: id,
      userId: user.uid,
      userName: user.displayName,
      userEmail: user.email,
      userPhone: user.phoneNumber,
      userAddress: user.address,
      bookingDate: now,
      serviceDate: serviceDate,
      service: service,
      status: BookingStatus.pending, // Valeur par défaut ajoutée
      paymentStatus: PaymentStatus.pending, // Valeur par défaut ajoutée
      paymentMethod: paymentMethod,
      serviceDescription: serviceDescription.isEmpty
          ? service.description
          : serviceDescription,
      additionalDetails: additionalDetails,
      totalAmount: service.price,
      currency: service.currency,
      createdAt: now,
      updatedAt: now,
      providerId: service.providerId?.isNotEmpty == true
          ? service.providerId
          : null,
      providerName: service.providerName?.isNotEmpty == true
          ? service.providerName
          : null,
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'serviceDate': Timestamp.fromDate(serviceDate),
      'service': service.toMap(),
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod,
      'serviceDescription': serviceDescription,
      'additionalDetails': additionalDetails,
      'totalAmount': totalAmount,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'providerId': providerId,
      'providerName': providerName,
      'cancellationReason': cancellationReason,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
      'metadata': metadata,
    };
  }

  // Créer un BookingModel à partir d'une Map de Firestore
  factory BookingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookingModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'],
      userAddress: map['userAddress'],
      bookingDate: map['bookingDate'] is Timestamp
          ? (map['bookingDate'] as Timestamp).toDate()
          : DateTime.now(),
      serviceDate: map['serviceDate'] is Timestamp
          ? (map['serviceDate'] as Timestamp).toDate()
          : DateTime.now(),
      service: ServiceModel.fromMap(map['service'], map['service']['id'] ?? ''),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: map['paymentMethod'] ?? '',
      serviceDescription: map['serviceDescription'] ?? '',
      additionalDetails: map['additionalDetails'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'EUR',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      providerId: map['providerId'],
      providerName: map['providerName'],
      cancellationReason: map['cancellationReason'],
      cancelledAt: map['cancelledAt'] is Timestamp
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // Créer à partir d'un DocumentSnapshot de Firestore
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromMap(data, doc.id);
  }

  // Convertir en Map pour Firestore (alias de toMap)
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // CopyWith pour les mises à jour
  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAddress,
    DateTime? bookingDate,
    DateTime? serviceDate,
    ServiceModel? service,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? serviceDescription,
    String? additionalDetails,
    double? totalAmount,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? providerId,
    String? providerName,
    String? cancellationReason,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userAddress: userAddress ?? this.userAddress,
      bookingDate: bookingDate ?? this.bookingDate,
      serviceDate: serviceDate ?? this.serviceDate,
      service: service ?? this.service,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utiles
  String get formattedAmount => '$totalAmount $currency';

  bool get canBeCancelled =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get isActive =>
      status != BookingStatus.cancelled && status != BookingStatus.completed;

  Duration get timeUntilService => serviceDate.difference(DateTime.now());

  bool get isUpcoming => serviceDate.isAfter(DateTime.now());

  bool get isPast => serviceDate.isBefore(DateTime.now());

  @override
  String toString() {
    return 'BookingModel(id: $id, service: ${service.name}, status: ${status.label}, amount: $formattedAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
