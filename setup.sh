#!/bin/bash

# Script de configuration automatique pour le projet Flutter Auth Service
# Ce script automatise les étapes de configuration de base

echo "🚀 Configuration du projet Flutter Auth Service"
echo "================================================"

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

# Vérifier si dart est installé
if ! command -v dart &> /dev/null; then
    echo "❌ Dart n'est pas installé. Veuillez installer Dart d'abord."
    exit 1
fi

echo "✅ Flutter et Dart sont installés"

# Nettoyer et récupérer les dépendances
echo "📦 Installation des dépendances..."
flutter clean
flutter pub get

# Vérifier la configuration Flutter
echo "🔧 Vérification de la configuration Flutter..."
flutter doctor

# Installer FlutterFire CLI si pas déjà installé
echo "🔥 Configuration de FlutterFire CLI..."
if ! command -v flutterfire &> /dev/null; then
    echo "📥 Installation de FlutterFire CLI..."
    dart pub global activate flutterfire_cli
else
    echo "✅ FlutterFire CLI est déjà installé"
fi

# Créer les répertoires nécessaires
echo "📁 Création des répertoires..."
mkdir -p assets/images
mkdir -p lib/models
mkdir -p lib/providers
mkdir -p lib/screens
mkdir -p lib/services

echo "✅ Structure des dossiers créée"

# Instructions pour la suite
echo ""
echo "🎉 Configuration de base terminée !"
echo ""
echo "📋 Étapes suivantes :"
echo "1. Configurer Firebase Console (voir SETUP.md)"
echo "2. Ajouter google-services.json dans android/app/"
echo "3. Ajouter GoogleService-Info.plist dans ios/Runner/"
echo "4. Exécuter : flutterfire configure"
echo "5. Tester l'application : flutter run"
echo ""
echo "📖 Consultez README.md et SETUP.md pour plus de détails"
echo ""
echo "🔗 Liens utiles :"
echo "   Firebase Console: https://console.firebase.google.com/"
echo "   Google Cloud Console: https://console.cloud.google.com/"
echo ""
echo "💡 Tip: Utilisez 'flutter run --debug' pour le développement"
