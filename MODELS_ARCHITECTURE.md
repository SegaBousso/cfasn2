# Architecture des Modèles - Service App

Ce document décrit l'architecture et l'utilisation des modèles de données pour l'application de services.

## Vue d'ensemble

L'application utilise une architecture basée sur des modèles de données immutables avec sérialisation Firestore. Chaque modèle suit les conventions suivantes :

- **Immutabilité** : Les modèles sont immutables avec des méthodes `copyWith()` pour les modifications
- **Sérialisation** : Support complet de la sérialisation vers/depuis Firestore
- **Méthodes utilitaires** : Getters et méthodes helper pour faciliter l'utilisation
- **Validation** : Override des méthodes `==`, `hashCode` et `toString()` pour la comparaison

## Modèles Principaux

### 1. UserModel (`user_model.dart`)
Modèle représentant un utilisateur de l'application.

**Caractéristiques clés :**
- Support des rôles : `user`, `admin`, `provider`
- Gestion des préférences utilisateur
- Support de l'authentification Firebase
- Gestion des favoris et de l'historique

### 2. ServiceModel (`service_model.dart`)
Modèle représentant un service proposé.

**Caractéristiques clés :**
- Gestion des évaluations et commentaires
- Support des catégories
- Statistiques (vues, likes, jobs complétés)
- Disponibilité et tarification

### 3. BookingModel (`booking_model.dart`)
Modèle représentant une réservation.

**Caractéristiques clés :**
- Statuts de réservation (en attente, confirmé, terminé, etc.)
- Gestion des paiements
- Détails du service et du client
- Historique des modifications

### 4. ProviderModel (`provider_model.dart`)
Modèle représentant un prestataire de services.

**Caractéristiques clés :**
- Profil détaillé avec bio et expérience
- Gestion des certifications et spécialités
- Évaluations et portfolio
- Services proposés

### 5. CategoryModel (`category_model.dart`)
Modèle représentant une catégorie de services.

**Caractéristiques clés :**
- Organisation hiérarchique des services
- Métadonnées visuelles (icônes, couleurs)
- Comptage dynamique des services

## Modèles Secondaires

### 6. ReviewModel (`review_model.dart`)
Gestion des avis clients sur les services.

### 7. CommentModel (`comment_model.dart`)
Système de commentaires avec support des réponses.

**Fonctionnalités :**
- Commentaires imbriqués (réponses)
- Système de likes
- Modération et visibilité

### 8. FavoriteModel (`favorite_model.dart`)
Gestion des services favoris des utilisateurs.

### 9. ServiceRequestModel (`service_request_model.dart`)
Modèle pour les demandes de services personnalisés.

**Statuts supportés :**
- `pending` : En attente
- `accepted` : Acceptée
- `rejected` : Rejetée
- `inProgress` : En cours
- `completed` : Terminée
- `cancelled` : Annulée

### 10. NotificationModel (`notification_model.dart`)
Système de notifications push et in-app.

**Types de notifications :**
- Réservations (confirmé, annulé, terminé)
- Services (demandé, accepté, rejeté)
- Interactions (avis, commentaires)
- Promotions et mises à jour

### 11. ProviderRatingModel (`provider_rating_model.dart`)
Évaluations détaillées des prestataires.

**Fonctionnalités :**
- Évaluation globale et par critères
- Commentaires détaillés
- Historique des évaluations

### 12. ServiceRatingModel (`service_rating_model.dart`)
Évaluations spécifiques aux services.

**Fonctionnalités :**
- Système d'étoiles
- Votes d'utilité
- Vérification d'achat

## Utilisation

### Import
```dart
import 'package:service/models/models.dart';
```

### Création d'un modèle
```dart
final user = UserModel(
  uid: 'user123',
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe',
);
```

### Modification immutable
```dart
final updatedUser = user.copyWith(
  firstName: 'Jane',
  updatedAt: DateTime.now(),
);
```

### Sérialisation Firestore
```dart
// Vers Firestore
final data = user.toMap();
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set(data);

// Depuis Firestore
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc('user123')
    .get();
final user = UserModel.fromMap(doc.data()!);
```

## Bonnes Pratiques

1. **Validation** : Toujours valider les données avant création
2. **Null Safety** : Utiliser les types nullables appropriés
3. **Immutabilité** : Ne jamais modifier directement les propriétés
4. **Performance** : Utiliser les indexes Firestore pour les requêtes fréquentes
5. **Sécurité** : Valider côté serveur avec les règles Firestore

## Extensions Futures

L'architecture permet facilement d'ajouter :
- Nouveaux types d'entités
- Champs supplémentaires
- Relations complexes
- Cache local
- Synchronisation offline

## Relations Entre Modèles

```
UserModel
├── BookingModel (userId)
├── ReviewModel (userId)
├── CommentModel (userId)
├── FavoriteModel (userId)
├── ServiceRequestModel (userId)
└── NotificationModel (userId)

ProviderModel
├── ServiceModel (providerId)
├── BookingModel (providerId)
├── ProviderRatingModel (providerId)
└── ServiceRequestModel (providerId)

ServiceModel
├── BookingModel (serviceId)
├── ReviewModel (serviceId)
├── CommentModel (serviceId)
├── FavoriteModel (serviceId)
└── ServiceRatingModel (serviceId)

CategoryModel
└── ServiceModel (categoryId)
```

Cette architecture modulaire facilite la maintenance et l'évolution de l'application.
