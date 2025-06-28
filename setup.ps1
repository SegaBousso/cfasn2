# Script de configuration automatique pour Windows PowerShell
# Configuration du projet Flutter Auth Service

Write-Host "🚀 Configuration du projet Flutter Auth Service" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Vérifier si Flutter est installé
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter est installé" -ForegroundColor Green
}
catch {
    Write-Host "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord." -ForegroundColor Red
    exit 1
}

# Vérifier si Dart est installé
try {
    $dartVersion = dart --version
    Write-Host "✅ Dart est installé" -ForegroundColor Green
}
catch {
    Write-Host "❌ Dart n'est pas installé. Veuillez installer Dart d'abord." -ForegroundColor Red
    exit 1
}

# Nettoyer et récupérer les dépendances
Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
flutter clean
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dépendances installées avec succès" -ForegroundColor Green
}
else {
    Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
    exit 1
}

# Vérifier la configuration Flutter
Write-Host "🔧 Vérification de la configuration Flutter..." -ForegroundColor Yellow
flutter doctor

# Installer FlutterFire CLI si pas déjà installé
Write-Host "🔥 Configuration de FlutterFire CLI..." -ForegroundColor Yellow
try {
    $flutterfireVersion = flutterfire --version
    Write-Host "✅ FlutterFire CLI est déjà installé" -ForegroundColor Green
}
catch {
    Write-Host "📥 Installation de FlutterFire CLI..." -ForegroundColor Yellow
    dart pub global activate flutterfire_cli
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ FlutterFire CLI installé avec succès" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Erreur lors de l'installation de FlutterFire CLI" -ForegroundColor Red
    }
}

# Créer les répertoires nécessaires
Write-Host "📁 Création des répertoires..." -ForegroundColor Yellow
$directories = @(
    "assets\images",
    "lib\models",
    "lib\providers", 
    "lib\screens",
    "lib\services"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✅ Créé: $dir" -ForegroundColor Green
    }
    else {
        Write-Host "✅ Existe déjà: $dir" -ForegroundColor Green
    }
}

# Instructions pour la suite
Write-Host ""
Write-Host "🎉 Configuration de base terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Étapes suivantes :" -ForegroundColor Cyan
Write-Host "1. Configurer Firebase Console (voir SETUP.md)" -ForegroundColor White
Write-Host "2. Ajouter google-services.json dans android/app/" -ForegroundColor White
Write-Host "3. Ajouter GoogleService-Info.plist dans ios/Runner/" -ForegroundColor White
Write-Host "4. Exécuter : flutterfire configure" -ForegroundColor White
Write-Host "5. Tester l'application : flutter run" -ForegroundColor White
Write-Host ""
Write-Host "📖 Consultez README.md et SETUP.md pour plus de détails" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Liens utiles :" -ForegroundColor Cyan
Write-Host "   Firebase Console: https://console.firebase.google.com/" -ForegroundColor Blue
Write-Host "   Google Cloud Console: https://console.cloud.google.com/" -ForegroundColor Blue
Write-Host ""
Write-Host "💡 Tip: Utilisez 'flutter run --debug' pour le développement" -ForegroundColor Yellow

# Pause pour permettre à l'utilisateur de lire les instructions
Write-Host ""
Write-Host "Appuyez sur Entrée pour continuer..." -ForegroundColor Gray
Read-Host
