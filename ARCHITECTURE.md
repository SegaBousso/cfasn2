# Architecture du projet Service Auth

## 📁 Structure complète

```
service/
├── 📄 README.md                    # Documentation principale
├── 📄 SETUP.md                     # Guide de configuration détaillé
├── 📄 QUICKSTART.md                # Guide de démarrage rapide
├── 📄 ARCHITECTURE.md              # Ce fichier
├── 📄 pubspec.yaml                 # Dépendances Flutter
├── 📄 analysis_options.yaml        # Configuration de l'analyse
├── 📄 firebase.json                # Configuration Firebase
├── 📄 setup.sh                     # Script de setup Linux/Mac
├── 📄 setup.ps1                    # Script de setup Windows
├── 
├── 📁 lib/                         # Code source Dart
│   ├── 📄 main.dart                # Point d'entrée de l'application
│   ├── 📄 firebase_options.dart    # Configuration Firebase générée
│   │
│   ├── 📁 models/                  # Modèles de données
│   │   └── 📄 user_model.dart      # Modèle utilisateur
│   │
│   ├── 📁 services/                # Services métier
│   │   └── 📄 auth_service.dart    # Service d'authentification
│   │
│   ├── 📁 providers/               # Providers pour la gestion d'état
│   │   └── 📄 auth_provider.dart   # Provider d'authentification
│   │
│   ├── 📁 screens/                 # Écrans de l'application
│   │   ├── 📄 auth_wrapper.dart    # Wrapper de navigation
│   │   ├── 📄 login_screen.dart    # Écran de connexion
│   │   ├── 📄 home_screen.dart     # Écran d'accueil
│   │   └── 📄 loading_screen.dart  # Écran de chargement
│   │
│   ├── 📁 widgets/                 # Widgets réutilisables
│   │   └── 📄 common_widgets.dart  # Widgets communs
│   │
│   └── 📁 utils/                   # Utilitaires
│       ├── 📄 constants.dart       # Constantes de l'application
│       └── 📄 theme.dart           # Configuration du thème
│
├── 📁 assets/                      # Ressources statiques
│   └── 📁 images/                  # Images et icônes
│
├── 📁 android/                     # Configuration Android
│   ├── 📄 build.gradle.kts         # Configuration Gradle principale
│   └── 📁 app/
│       ├── 📄 build.gradle.kts     # Configuration Gradle app
│       └── 📄 google-services.json # Configuration Firebase Android
│
├── 📁 ios/                         # Configuration iOS
│   └── 📁 Runner/
│       └── 📄 GoogleService-Info.plist # Configuration Firebase iOS
│
├── 📁 .vscode/                     # Configuration VS Code
│   └── 📄 tasks.json               # Tâches de développement
│
└── 📁 test/                        # Tests unitaires
    └── 📄 widget_test.dart         # Tests des widgets
```

## 🏗️ Architecture de l'application

### 1. Architecture générale

```
┌─────────────────┐
│   Presentation  │  ← Screens & Widgets
├─────────────────┤
│   State Mgmt    │  ← Providers (ChangeNotifier)
├─────────────────┤
│   Business      │  ← Services
├─────────────────┤
│   Data          │  ← Models & Firebase
└─────────────────┘
```

### 2. Flux de données

```
User Action → Provider → Service → Firebase → Provider → UI Update
```

### 3. Gestion des états

```
AuthStatus:
  - unknown     ← État initial
  - loading     ← Chargement en cours
  - authenticated ← Utilisateur connecté
  - unauthenticated ← Utilisateur déconnecté
```

## 🔧 Composants principaux

### 1. **AuthService** (services/auth_service.dart)
- **Responsabilité** : Gestion de l'authentification Firebase
- **Méthodes principales** :
  - `signInWithGoogle()` : Connexion Google
  - `signOut()` : Déconnexion
  - `deleteAccount()` : Suppression de compte
  - `_saveUserToFirestore()` : Sauvegarde utilisateur
  - `getUserData()` : Récupération des données

### 2. **AuthProvider** (providers/auth_provider.dart)
- **Responsabilité** : Gestion des états d'authentification
- **État géré** :
  - `AuthStatus status` : État de l'authentification
  - `UserModel? user` : Données utilisateur
  - `String? errorMessage` : Messages d'erreur

### 3. **UserModel** (models/user_model.dart)
- **Responsabilité** : Modèle de données utilisateur
- **Propriétés** :
  - `uid` : Identifiant unique
  - `email` : Adresse email
  - `displayName` : Nom d'affichage
  - `photoURL` : URL de la photo de profil
  - `createdAt` : Date de création
  - `lastSignIn` : Dernière connexion

### 4. **Screens** (screens/)
- **AuthWrapper** : Gestion de la navigation selon l'état d'auth
- **LoginScreen** : Interface de connexion
- **HomeScreen** : Écran d'accueil avec profil utilisateur
- **LoadingScreen** : Écran de chargement

## 🎨 Gestion du thème

### 1. **AppTheme** (utils/theme.dart)
- Thème clair et sombre
- Couleurs personnalisées
- Styles de composants
- Gradients et ombres

### 2. **Constantes** (utils/constants.dart)
- Tailles et espacements
- Messages d'erreur
- Configuration générale

### 3. **Widgets réutilisables** (widgets/common_widgets.dart)
- `GradientButton` : Bouton avec gradient
- `CustomCard` : Carte personnalisée
- `UserAvatar` : Avatar utilisateur
- `ErrorMessage` : Message d'erreur
- `LoadingWidget` : Indicateur de chargement

## 🔐 Sécurité

### 1. **Authentification**
- Utilisation de Firebase Auth
- Tokens sécurisés
- Validation côté serveur

### 2. **Données**
- Règles Firestore restrictives
- Validation des données
- Gestion des permissions

### 3. **Gestion des erreurs**
- Messages d'erreur localisés
- Fallbacks en cas d'échec
- Logging sécurisé

## 📊 Gestion des états

### 1. **Provider Pattern**
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    switch (authProvider.status) {
      case AuthStatus.loading:
        return LoadingScreen();
      case AuthStatus.authenticated:
        return HomeScreen();
      case AuthStatus.unauthenticated:
        return LoginScreen();
      default:
        return LoadingScreen();
    }
  },
)
```

### 2. **États possibles**
- `unknown` : État initial, vérification en cours
- `loading` : Opération en cours (connexion, déconnexion)
- `authenticated` : Utilisateur connecté avec succès
- `unauthenticated` : Utilisateur non connecté

## 🚀 Extensibilité

### 1. **Ajout de nouveaux providers d'authentification**
```dart
// Dans AuthService
Future<UserCredential?> signInWithFacebook() async {
  // Implémentation Facebook
}

// Dans AuthProvider
Future<void> signInWithFacebook() async {
  // Gestion des états
}
```

### 2. **Ajout de nouvelles fonctionnalités**
- Créer de nouveaux services dans `services/`
- Créer de nouveaux modèles dans `models/`
- Créer de nouveaux écrans dans `screens/`
- Créer de nouveaux providers dans `providers/`

### 3. **Ajout de nouveaux widgets**
- Widgets réutilisables dans `widgets/`
- Respect du design system défini dans `theme.dart`

## 🧪 Tests

### 1. **Structure des tests**
```
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── providers/
├── widget/
│   └── screens/
└── integration/
    └── auth_flow_test.dart
```

### 2. **Tests recommandés**
- Tests unitaires des modèles
- Tests des services d'authentification
- Tests des providers
- Tests d'intégration du flux d'authentification

## 📋 Bonnes pratiques

### 1. **Code Organization**
- Un fichier par classe/widget
- Noms de fichiers en snake_case
- Imports organisés (dart, flutter, packages, relatives)

### 2. **Gestion des états**
- Utiliser des providers pour les états globaux
- StatefulWidget pour les états locaux
- Éviter les setState() dans les widgets complexes

### 3. **Sécurité**
- Jamais de clés API dans le code
- Validation côté serveur obligatoire
- Gestion appropriée des erreurs

### 4. **Performance**
- Lazy loading des données
- Optimisation des rebuilds
- Cache des données fréquemment utilisées

---

Cette architecture offre une base solide et extensible pour votre projet d'authentification Flutter avec Firebase.
