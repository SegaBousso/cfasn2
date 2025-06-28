# Service - Système d'Authentification Flutter

Ce projet constitue la base d'une application Flutter avec un système d'authentification complet utilisant Google Sign-In et Firebase.

## 🚀 Fonctionnalités

- **Authentification Google** : Connexion sécurisée avec Google
- **Gestion des utilisateurs** : Stockage des informations utilisateur dans Firestore
- **Interface moderne** : Design Material 3 avec thème personnalisé
- **Gestion des états** : Utilisation de Provider pour la gestion d'état
- **Sécurité** : Gestion des erreurs et validation des données
- **Expérience utilisateur** : Écrans de chargement et gestion des erreurs

## 📱 Captures d'écran

### Écran de connexion
- Interface moderne avec gradient
- Bouton Google Sign-In
- Gestion des erreurs en temps réel
- Indicateur de chargement

### Écran d'accueil
- Informations utilisateur personnalisées
- Statistiques du compte
- Actions rapides
- Menu contextuel avec options

## 🛠️ Technologies utilisées

- **Flutter** : Framework UI
- **Firebase Core** : Plateforme de développement
- **Firebase Auth** : Authentification
- **Cloud Firestore** : Base de données NoSQL
- **Google Sign-In** : Authentification Google
- **Provider** : Gestion d'état

## 📋 Prérequis

1. **Flutter SDK** installé
2. **Projet Firebase** configuré
3. **Google Cloud Console** configuré pour Google Sign-In
4. **Fichiers de configuration** :
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart`

## ⚙️ Configuration

### 1. Configuration Firebase

1. Créer un projet Firebase
2. Activer Authentication et Firestore
3. Configurer Google Sign-In dans Firebase Console
4. Télécharger les fichiers de configuration

### 2. Configuration Google Sign-In

#### Android
1. Ajouter `google-services.json` dans `android/app/`
2. Configurer les SHA-1 fingerprints dans Firebase Console

#### iOS
1. Ajouter `GoogleService-Info.plist` dans `ios/Runner/`
2. Configurer l'URL Scheme dans Xcode

### 3. Installation

```bash
# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 📁 Structure du projet

```
lib/
├── models/
│   └── user_model.dart          # Modèle de données utilisateur
├── providers/
│   └── auth_provider.dart       # Provider d'authentification
├── screens/
│   ├── auth_wrapper.dart        # Wrapper de navigation
│   ├── login_screen.dart        # Écran de connexion
│   ├── home_screen.dart         # Écran d'accueil
│   └── loading_screen.dart      # Écran de chargement
├── services/
│   └── auth_service.dart        # Service d'authentification
├── firebase_options.dart        # Configuration Firebase
└── main.dart                    # Point d'entrée
```

## 🔧 Services

### AuthService
- Gestion de l'authentification Google
- Sauvegarde des données utilisateur
- Gestion des sessions
- Suppression de compte

### AuthProvider
- Gestion des états d'authentification
- Gestion des erreurs
- Notifications des changements d'état

## 🎨 Interface utilisateur

### Écran de connexion
- Design moderne avec gradient
- Bouton Google Sign-In stylisé
- Messages d'erreur contextuels
- Indicateurs de chargement

### Écran d'accueil
- Carte de bienvenue personnalisée
- Informations du compte
- Actions rapides
- Menu contextuel

## 🔒 Sécurité

- Authentification sécurisée avec Google
- Validation des données côté client
- Gestion des erreurs d'authentification
- Protection des données utilisateur

## 🚦 États d'authentification

- `unknown` : État initial
- `loading` : Chargement en cours
- `authenticated` : Utilisateur connecté
- `unauthenticated` : Utilisateur déconnecté

## 📊 Gestion des données

### Firestore Collections
- `users` : Informations des utilisateurs
  - `uid` : ID utilisateur unique
  - `email` : Adresse email
  - `displayName` : Nom d'affichage
  - `photoURL` : URL de la photo de profil
  - `createdAt` : Date de création
  - `lastSignIn` : Dernière connexion

## 🔄 Flux d'authentification

1. **Initialisation** : Vérification de l'état d'authentification
2. **Connexion** : Processus Google Sign-In
3. **Sauvegarde** : Stockage des données utilisateur
4. **Navigation** : Redirection vers l'écran approprié
5. **Déconnexion** : Nettoyage des données locales

## 🛡️ Gestion des erreurs

- Messages d'erreur localisés
- Gestion des erreurs réseau
- Validation des données
- Fallbacks en cas d'échec

## 📱 Fonctionnalités avancées

- **Re-authentification** : Pour les opérations sensibles
- **Suppression de compte** : Avec confirmation
- **Mise à jour de profil** : Synchronisation automatique
- **Gestion hors ligne** : Cache des données utilisateur

## 🔮 Développements futurs

Ce système d'authentification constitue la base pour :
- Système de permissions
- Gestion des rôles utilisateur
- Fonctionnalités sociales
- Système de notification
- Analyse des données utilisateur

## 🤝 Contribution

Ce projet est conçu pour être étendu. Les contributions sont les bienvenues pour :
- Améliorer l'interface utilisateur
- Ajouter de nouvelles fonctionnalités
- Optimiser les performances
- Corriger les bugs

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

---

**Note** : Ce système d'authentification est prêt pour la production et peut être étendu selon les besoins spécifiques du projet.
