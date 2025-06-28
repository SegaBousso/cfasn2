# Module Services - Architecture Refactorisée

Ce module a été refactorisé pour suivre une architecture modulaire, maintenable et réutilisable, en utilisant **Firestore** comme source de données principale.

## 📁 Structure du Dossier

```
lib/screens/user/services/
├── services/                     # Services métier
│   ├── services_data_service.dart    # Service d'accès aux données Firestore
│   └── services_service.dart         # Service de logique métier
├── widgets/                      # Widgets réutilisables
│   └── service_widgets.dart          # Widgets pour les services
├── sections/                     # Sections d'interface
│   ├── services_sections.dart        # Sections pour la liste des services
│   └── service_detail_sections.dart  # Sections pour les détails d'un service
├── dialogs/                      # Dialogs modaux
│   └── services_dialogs.dart         # Dialogs pour les filtres et actions
├── services_list_screen.dart     # Écran principal de liste des services
├── service_detail_screen.dart    # Écran de détails d'un service
└── README.md                     # Documentation
```

## 🔧 Composants Principaux

### Services

#### 1. `ServicesDataService`
- **Rôle** : Gestion des données Firestore
- **Fonctionnalités** :
  - Récupération des services depuis Firestore
  - Recherche et filtrage des services
  - Gestion des catégories
  - Récupération des services populaires/récents
  - Streams en temps réel

#### 2. `ServicesService`
- **Rôle** : Logique métier et orchestration
- **Fonctionnalités** :
  - Combinaison des données services/favoris
  - Gestion des filtres avancés
  - Actions sur les favoris
  - Détails des services avec statistiques

### Widgets Réutilisables

#### `ServiceCard`
- Affichage d'un service dans une carte
- Gestion des favoris
- Information de disponibilité
- Navigation vers les détails

#### `ServiceImage`
- Affichage d'images de services
- Gestion des erreurs de chargement
- Image par défaut

#### `ServiceRating`
- Affichage des notes et avis
- Format standardisé

#### `ServicePrice`
- Affichage des prix
- Support multi-devises

#### `ServiceAvailability`
- Indicateur de disponibilité
- Codes couleur standardisés

### Sections d'Interface

#### `ServicesSearchSection`
- Barre de recherche
- Filtres rapides par catégorie
- Bouton filtres avancés

#### `ServicesListSection`
- Liste des services avec pagination
- États de chargement et vide
- Gestion des favoris

#### `ServiceInfoSection`
- Informations principales du service
- Note et disponibilité

#### `ServiceProviderSection`
- Informations du prestataire
- Actions de contact

### Dialogs

#### `ServicesDialogs`
- Dialog de filtres avancés
- Confirmations d'actions
- Tri des services

## 🗃️ Intégration Firestore

### Collections Utilisées

1. **`services`** - Services disponibles
   ```dart
   {
     'id': 'service_id',
     'name': 'Nom du service',
     'description': 'Description...',
     'price': 50.0,
     'currency': 'EUR',
     'categoryId': 'category_id',
     'categoryName': 'Nom catégorie',
     'providerId': 'provider_id',
     'providerName': 'Nom prestataire',
     'isAvailable': true,
     'isActive': true,
     'rating': 4.5,
     'totalReviews': 23,
     'imageUrl': 'https://...',
     'tags': ['tag1', 'tag2'],
     // ... autres champs
   }
   ```

2. **`categories`** - Catégories de services
   ```dart
   {
     'id': 'category_id',
     'name': 'Nom catégorie',
     'icon': 'icon_name',
     'isActive': true,
     'servicesCount': 15
   }
   ```

### Requêtes Optimisées

- **Recherche** : Utilisation d'index Firestore pour les recherches textuelles
- **Filtrage** : Combinaison de `where()` et tri côté client
- **Pagination** : Support pour `limit()` et `startAfter()`
- **Temps réel** : Streams Firestore pour les mises à jour automatiques

## 🚀 Fonctionnalités

### Écran Liste des Services (`ServicesListScreen`)

- ✅ **Recherche en temps réel** par nom/description
- ✅ **Filtres par catégorie** avec chips interactifs
- ✅ **Filtres avancés** (prix, note, disponibilité)
- ✅ **Gestion des favoris** avec persistance Firestore
- ✅ **États de chargement** et gestion d'erreurs
- ✅ **Interface responsive** et accessible

### Écran Détails du Service (`ServiceDetailScreen`)

- ✅ **Galerie d'images** avec navigation
- ✅ **Informations complètes** du service
- ✅ **Section prestataire** avec contact
- ✅ **Avis clients** avec pagination
- ✅ **Bouton de réservation** conditionnel
- ✅ **Gestion des favoris** synchronisée

## 🎯 Améliorations Apportées

### 1. Suppression des Données Statiques
- ❌ Suppression de tous les mock data
- ✅ Remplacement par des appels Firestore
- ✅ Gestion des états de chargement
- ✅ Gestion des erreurs réseau

### 2. Architecture Modulaire
- ✅ Séparation des responsabilités
- ✅ Widgets réutilisables
- ✅ Services découplés
- ✅ Code maintenable

### 3. Performance
- ✅ Mise en cache des favoris
- ✅ Requêtes optimisées
- ✅ Chargement progressif
- ✅ États de chargement granulaires

### 4. Expérience Utilisateur
- ✅ Interface fluide et responsive
- ✅ Messages d'erreur informatifs
- ✅ Retours visuels des actions
- ✅ Navigation cohérente

## 🔄 Migration depuis l'Ancienne Version

### Changements Principaux

1. **Données** : Mock data → Firestore
2. **Structure** : Fichier monolithique → Architecture modulaire
3. **State Management** : Local state → Service layer
4. **Widgets** : Custom widgets → Composants réutilisables

### Compatibilité

- ✅ Interface utilisateur similaire
- ✅ Navigation identique
- ✅ Fonctionnalités étendues
- ✅ Performance améliorée

## 🛠️ Utilisation

### Exemple d'Utilisation des Services

```dart
// Récupérer tous les services avec favoris
final servicesData = await ServicesService().getAllServicesWithFavorites();

// Rechercher avec filtres
final filteredData = await ServicesService().searchServicesWithFilters(
  query: 'plomberie',
  categoryId: 'plumbing',
  minPrice: 20.0,
  maxPrice: 100.0,
);

// Basculer un favori
final isNowFavorite = await ServicesService().toggleServiceFavorite('service_id');
```

### Exemple d'Utilisation des Widgets

```dart
// Afficher une carte de service
ServiceCard(
  service: service,
  isFavorite: favoriteIds.contains(service.id),
  onTap: () => _navigateToDetail(service),
  onFavoriteToggle: () => _toggleFavorite(service.id),
)

// Section de recherche
ServicesSearchSection(
  searchController: _searchController,
  categories: _categories,
  selectedCategory: _selectedCategory,
  onCategoryChanged: _onCategoryChanged,
  hasActiveFilters: _hasFilters,
)
```

## 📱 Navigation

```dart
// Navigation vers les détails
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ServiceDetailScreen(service: service),
  ),
);

// Navigation vers réservation
Navigator.pushNamed(
  context,
  '/user/bookings/create',
  arguments: service,
);
```

## 🔮 Évolutions Futures

- [ ] **Cache avancé** avec synchronisation hors ligne
- [ ] **Notifications** de nouveaux services
- [ ] **Recommandations** personnalisées
- [ ] **Géolocalisation** pour services locaux
- [ ] **Chat** intégré avec prestataires
- [ ] **Système de badges** pour prestataires
- [ ] **Comparateur** de services
- [ ] **Historique** des recherches

---

Cette architecture modulaire facilite la maintenance, les tests et l'évolution future du module services. Chaque composant a une responsabilité claire et peut être modifié indépendamment.
