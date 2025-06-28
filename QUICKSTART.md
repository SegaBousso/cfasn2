# Guide de démarrage rapide - Service Auth

## 🚀 Démarrage rapide (5 minutes)

### 1. Prérequis
- Flutter SDK installé et configuré
- Un projet Firebase créé
- Android Studio ou VS Code avec les extensions Flutter

### 2. Configuration Firebase EXPRESS

#### A. Créer le projet Firebase
1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Créer un nouveau projet : "service-auth"
3. Activer Google Analytics (optionnel)

#### B. Configurer Authentication
1. Dans Firebase Console → Authentication → Sign-in method
2. Activer "Google" comme provider
3. Configurer les domaines autorisés si nécessaire

#### C. Configurer Firestore
1. Dans Firebase Console → Firestore Database
2. Créer la base de données en mode "test"
3. Choisir une région proche (ex: europe-west1)

### 3. Configuration des plateformes

#### Android (Obligatoire)
```bash
# 1. Ajouter l'app Android dans Firebase Console
# Package name: com.example.service
# SHA-1: Obtenir avec la commande ci-dessous

# 2. Obtenir le SHA-1 fingerprint
cd android
./gradlew signingReport
# Copier le SHA-1 et l'ajouter dans Firebase Console

# 3. Télécharger google-services.json
# Placer dans: android/app/google-services.json
```

#### iOS (Optionnel pour test)
```bash
# 1. Ajouter l'app iOS dans Firebase Console
# Bundle ID: com.example.service

# 2. Télécharger GoogleService-Info.plist
# Placer dans: ios/Runner/GoogleService-Info.plist
```

### 4. Configuration automatique

#### Option A: Script automatique (Recommandé)
```bash
# Windows PowerShell
.\setup.ps1

# Linux/Mac
chmod +x setup.sh
./setup.sh
```

#### Option B: Configuration manuelle
```bash
# 1. Installer les dépendances
flutter pub get

# 2. Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# 3. Configurer Firebase
flutterfire configure
# Sélectionner le projet créé
# Sélectionner les plateformes (Android minimum)
```

### 5. Test de l'application

```bash
# Vérifier la configuration
flutter doctor

# Lancer l'application
flutter run --debug

# Ou utiliser la tâche VS Code
# Ctrl+Shift+P → "Tasks: Run Task" → "Flutter: Run Debug"
```

## 🎯 Points clés pour le test

### Test d'authentification
1. **Écran de connexion** : Doit afficher le bouton Google Sign-In
2. **Processus de connexion** : Doit ouvrir la popup Google
3. **Écran d'accueil** : Doit afficher les informations utilisateur
4. **Déconnexion** : Menu → Se déconnecter

### Vérification des données
1. **Firestore** : Vérifier la collection "users" dans Firebase Console
2. **Authentification** : Vérifier les utilisateurs dans Authentication
3. **Logs** : Vérifier les logs de debug dans la console

## 🔧 Configuration avancée

### Règles Firestore sécurisées
```javascript
// À appliquer dans Firestore → Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Variables d'environnement
```bash
# Créer un fichier .env à la racine
FIREBASE_PROJECT_ID=your-project-id
GOOGLE_CLIENT_ID=your-client-id
```

### Configuration pour production
```bash
# Générer le keystore de production
keytool -genkey -v -keystore ~/release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias release

# Configurer android/key.properties
storePassword=your-password
keyPassword=your-password
keyAlias=release
storeFile=release-key.keystore
```

## 🐛 Dépannage express

### Erreur: "Google Sign-In failed"
```bash
# Vérifier le SHA-1
cd android && ./gradlew signingReport

# Ajouter le SHA-1 dans Firebase Console
# Redémarrer l'application
```

### Erreur: "Firebase project not found"
```bash
# Vérifier google-services.json
ls -la android/app/google-services.json

# Re-exécuter flutterfire configure
flutterfire configure
```

### Erreur de compilation
```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get
flutter run
```

## 📱 Fonctionnalités disponibles

### ✅ Implémentées
- [x] Connexion Google Sign-In
- [x] Sauvegarde automatique des données utilisateur
- [x] Écran d'accueil personnalisé
- [x] Gestion des erreurs
- [x] Déconnexion sécurisée
- [x] Suppression de compte
- [x] Interface Material 3
- [x] Gestion des états de chargement

### 🔄 À développer
- [ ] Authentification email/mot de passe
- [ ] Authentification avec d'autres providers
- [ ] Système de permissions
- [ ] Notifications push
- [ ] Mode hors ligne
- [ ] Analyse et métriques

## 🎉 Félicitations !

Votre système d'authentification est maintenant opérationnel ! 

### Prochaines étapes recommandées :
1. **Tester** toutes les fonctionnalités
2. **Personnaliser** l'interface selon vos besoins
3. **Ajouter** les fonctionnalités métier
4. **Configurer** l'environnement de production
5. **Implémenter** les analytics et monitoring

### Ressources utiles :
- [Documentation Flutter](https://docs.flutter.dev/)
- [Documentation Firebase](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

---

**Note importante** : Ce système constitue une base solide pour votre projet d'envergure. Il est conçu pour être extensible et maintenir une architecture propre.
