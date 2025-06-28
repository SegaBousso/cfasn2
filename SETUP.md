# Configuration Firebase et Google Sign-In

## Étapes de configuration

### 1. Configuration Firebase Console

1. **Créer un projet Firebase**
   - Aller sur [Firebase Console](https://console.firebase.google.com/)
   - Cliquer sur "Créer un projet"
   - Suivre les étapes de création

2. **Configurer Authentication**
   - Dans Firebase Console, aller dans "Authentication"
   - Cliquer sur "Commencer"
   - Aller dans "Sign-in method"
   - Activer "Google" comme fournisseur de connexion

3. **Configurer Firestore**
   - Dans Firebase Console, aller dans "Firestore Database"
   - Cliquer sur "Créer une base de données"
   - Choisir "Commencer en mode test" (pour le développement)
   - Sélectionner une région proche

### 2. Configuration Android

1. **Ajouter l'application Android**
   - Dans Firebase Console, cliquer sur l'icône Android
   - Package name : `com.example.service`
   - App nickname : `Service Android`
   - Télécharger `google-services.json`

2. **Installer google-services.json**
   ```bash
   # Placer le fichier dans :
   android/app/google-services.json
   ```

3. **Configurer les SHA-1 fingerprints**
   ```bash
   # Obtenir le SHA-1 fingerprint (debug)
   cd android
   ./gradlew signingReport
   
   # Ou utiliser keytool
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   
   - Copier le SHA-1 dans Firebase Console > Paramètres du projet > Vos applications > Android

### 3. Configuration iOS

1. **Ajouter l'application iOS**
   - Dans Firebase Console, cliquer sur l'icône iOS
   - Bundle ID : `com.example.service`
   - App nickname : `Service iOS`
   - Télécharger `GoogleService-Info.plist`

2. **Installer GoogleService-Info.plist**
   ```bash
   # Placer le fichier dans :
   ios/Runner/GoogleService-Info.plist
   ```

3. **Configurer Xcode**
   - Ouvrir `ios/Runner.xcworkspace` dans Xcode
   - Ajouter le fichier `GoogleService-Info.plist` au projet
   - Configurer l'URL Scheme dans `Info.plist`

### 4. Configuration Google Cloud Console

1. **Aller sur Google Cloud Console**
   - [Google Cloud Console](https://console.cloud.google.com/)
   - Sélectionner le projet Firebase

2. **API et services**
   - Aller dans "API et services" > "Identifiants"
   - Créer un client OAuth 2.0 pour Android
   - Ajouter le SHA-1 fingerprint
   - Configurer le package name

### 5. Génération des options Firebase

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer le projet
flutterfire configure
```

### 6. Vérification de la configuration

1. **Fichiers requis**
   - ✅ `android/app/google-services.json`
   - ✅ `ios/Runner/GoogleService-Info.plist`
   - ✅ `lib/firebase_options.dart`

2. **Configuration Gradle**
   - ✅ `android/app/build.gradle.kts` contient `com.google.gms.google-services`
   - ✅ `android/build.gradle.kts` contient les dépendances Firebase

3. **Permissions Android**
   ```xml
   <!-- android/app/src/main/AndroidManifest.xml -->
   <uses-permission android:name="android.permission.INTERNET" />
   ```

### 7. Test de la configuration

```bash
# Tester sur Android
flutter run -d android

# Tester sur iOS
flutter run -d ios
```

## Dépannage

### Erreur : "Google Sign-In failed"
- Vérifier que le SHA-1 est correctement configuré
- Vérifier que l'application est bien ajoutée dans Firebase Console
- Vérifier que Google Sign-In est activé dans Authentication

### Erreur : "Firebase project not found"
- Vérifier que `google-services.json` est dans le bon répertoire
- Vérifier que le package name correspond

### Erreur : "Network error"
- Vérifier la connexion internet
- Vérifier les permissions réseau

## Configuration de production

### Android
1. Générer un keystore de production
2. Obtenir le SHA-1 du keystore de production
3. Ajouter le SHA-1 dans Firebase Console

### iOS
1. Configurer les certificats de distribution
2. Mettre à jour les Bundle IDs
3. Configurer les URL Schemes

## Sécurité

### Règles Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Authentification
- Toujours vérifier l'authentification côté serveur
- Utiliser des tokens sécurisés
- Implémenter la re-authentification pour les opérations sensibles

## Monitoring

### Firebase Analytics
- Activer Analytics dans Firebase Console
- Suivre les événements d'authentification
- Analyser les métriques utilisateur

### Crashlytics
- Activer Crashlytics pour le suivi des erreurs
- Ajouter des logs personnalisés
- Monitorer les performances
