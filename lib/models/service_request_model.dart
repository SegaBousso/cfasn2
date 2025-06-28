import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceRequestStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled,
}

class ServiceRequestModel {
  final String requestId;
  final String userId;
  final String userName;
  final String userPhone;
  final String userAddress;
  final DateTime requestedDate;
  final String serviceName;
  final String serviceDescription;
  final String additionalDetails;
  final ServiceRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? providerId;
  final String? providerResponse;
  final double? estimatedPrice;
  final String? rejectionReason;

  ServiceRequestModel({
    required this.requestId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.requestedDate,
    required this.serviceName,
    required this.serviceDescription,
    required this.additionalDetails,
    this.status = ServiceRequestStatus.pending,
    DateTime? createdAt,
    this.updatedAt,
    this.providerId,
    this.providerResponse,
    this.estimatedPrice,
    this.rejectionReason,
  }) : createdAt = createdAt ?? DateTime.now();

  ServiceRequestModel copyWith({
    String? requestId,
    String? userId,
    String? userName,
    String? userPhone,
    String? userAddress,
    DateTime? requestedDate,
    String? serviceName,
    String? serviceDescription,
    String? additionalDetails,
    ServiceRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? providerId,
    String? providerResponse,
    double? estimatedPrice,
    String? rejectionReason,
  }) {
    return ServiceRequestModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userAddress: userAddress ?? this.userAddress,
      requestedDate: requestedDate ?? this.requestedDate,
      serviceName: serviceName ?? this.serviceName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      providerId: providerId ?? this.providerId,
      providerResponse: providerResponse ?? this.providerResponse,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'requestedDate': Timestamp.fromDate(requestedDate),
      'serviceName': serviceName,
      'serviceDescription': serviceDescription,
      'additionalDetails': additionalDetails,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'providerId': providerId,
      'providerResponse': providerResponse,
      'estimatedPrice': estimatedPrice,
      'rejectionReason': rejectionReason,
    };
  }

  factory ServiceRequestModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ServiceRequestModel(
      requestId: id ?? map['requestId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userAddress: map['userAddress'] ?? '',
      requestedDate: map['requestedDate'] != null
          ? (map['requestedDate'] as Timestamp).toDate()
          : DateTime.now(),
      serviceName: map['serviceName'] ?? '',
      serviceDescription: map['serviceDescription'] ?? '',
      additionalDetails: map['additionalDetails'] ?? '',
      status: ServiceRequestStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ServiceRequestStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      providerId: map['providerId'],
      providerResponse: map['providerResponse'],
      estimatedPrice: map['estimatedPrice']?.toDouble(),
      rejectionReason: map['rejectionReason'],
    );
  }

  // Getters utilitaires
  bool get isPending => status == ServiceRequestStatus.pending;
  bool get isAccepted => status == ServiceRequestStatus.accepted;
  bool get isRejected => status == ServiceRequestStatus.rejected;
  bool get isInProgress => status == ServiceRequestStatus.inProgress;
  bool get isCompleted => status == ServiceRequestStatus.completed;
  bool get isCancelled => status == ServiceRequestStatus.cancelled;

  String get statusString {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'En attente';
      case ServiceRequestStatus.accepted:
        return 'Acceptée';
      case ServiceRequestStatus.rejected:
        return 'Rejetée';
      case ServiceRequestStatus.inProgress:
        return 'En cours';
      case ServiceRequestStatus.completed:
        return 'Terminée';
      case ServiceRequestStatus.cancelled:
        return 'Annulée';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceRequestModel &&
        other.requestId == requestId &&
        other.userId == userId &&
        other.status == status;
  }

  @override
  int get hashCode => requestId.hashCode ^ userId.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'ServiceRequestModel(requestId: $requestId, serviceName: $serviceName, status: ${status.name})';
  }
}
