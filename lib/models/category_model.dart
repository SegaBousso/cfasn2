import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? iconName;
  final String? imageUrl;
  final Color color;
  final bool isActive;
  final int sortOrder;
  final int serviceCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconName,
    this.imageUrl,
    this.color = Colors.blue,
    this.isActive = true,
    this.sortOrder = 0,
    this.serviceCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'color': color.value,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'serviceCount': serviceCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  // Méthode alternative pour Firestore
  Map<String, dynamic> toFirestore() => toMap();

  // Créer un CategoryModel à partir d'une Map de Firestore
  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'],
      imageUrl: map['imageUrl'],
      color: Color(map['color'] ?? Colors.blue.value),
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      serviceCount: map['serviceCount'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // CopyWith pour les mises à jour
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? imageUrl,
    Color? color,
    bool? isActive,
    int? sortOrder,
    int? serviceCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      serviceCount: serviceCount ?? this.serviceCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Méthodes utiles
  IconData get icon {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'repair':
        return Icons.build;
      case 'garden':
        return Icons.yard;
      case 'beauty':
        return Icons.face;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'transport':
        return Icons.directions_car;
      case 'technology':
        return Icons.computer;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  bool get hasServices => serviceCount > 0;

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, serviceCount: $serviceCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
