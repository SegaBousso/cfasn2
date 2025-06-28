# Plan des Écrans - Service App

## Vue d'ensemble
Basé sur les modèles créés, voici l'architecture complète des écrans nécessaires pour l'application de services.

## 🏗️ Structure des Dossiers

```
lib/screens/
├── auth/                    # Authentification
│   ├── auth_wrapper.dart    ✅ Existant
│   ├── login_screen.dart    ✅ Existant
│   ├── register_screen.dart
│   └── forgot_password_screen.dart
│
├── user/                    # Interface utilisateur
│   ├── home_screen.dart     ✅ Existant
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   └── profile_settings_screen.dart
│   ├── services/
│   │   ├── services_list_screen.dart
│   │   ├── service_detail_screen.dart
│   │   ├── search_services_screen.dart
│   │   └── categories_screen.dart
│   ├── bookings/
│   │   ├── my_bookings_screen.dart
│   │   ├── booking_detail_screen.dart
│   │   ├── create_booking_screen.dart
│   │   └── booking_history_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   ├── service_requests/
│   │   ├── my_requests_screen.dart
│   │   ├── create_request_screen.dart
│   │   └── request_detail_screen.dart
│   ├── reviews/
│   │   ├── write_review_screen.dart
│   │   └── my_reviews_screen.dart
│   └── notifications/
│       └── notifications_screen.dart
│
├── provider/                # Interface prestataire
│   ├── provider_home_screen.dart
│   ├── profile/
│   │   ├── provider_profile_screen.dart
│   │   ├── edit_provider_profile_screen.dart
│   │   └── provider_portfolio_screen.dart
│   ├── services/
│   │   ├── my_services_screen.dart
│   │   ├── add_service_screen.dart
│   │   ├── edit_service_screen.dart
│   │   └── service_analytics_screen.dart
│   ├── bookings/
│   │   ├── provider_bookings_screen.dart
│   │   ├── booking_management_screen.dart
│   │   └── calendar_screen.dart
│   ├── requests/
│   │   ├── service_requests_screen.dart
│   │   └── request_response_screen.dart
│   ├── reviews/
│   │   ├── provider_reviews_screen.dart
│   │   └── reviews_analytics_screen.dart
│   └── earnings/
│       ├── earnings_screen.dart
│       └── earnings_analytics_screen.dart
│
├── admin/                   # Administration
│   ├── admin_dashboard_screen.dart
│   ├── users/
│   │   ├── users_management_screen.dart
│   │   ├── user_detail_screen.dart
│   │   └── user_verification_screen.dart
│   ├── providers/
│   │   ├── providers_management_screen.dart
│   │   ├── provider_verification_screen.dart
│   │   └── provider_approval_screen.dart
│   ├── services/
│   │   ├── services_management_screen.dart
│   │   ├── service_moderation_screen.dart
│   │   └── categories_management_screen.dart
│   ├── bookings/
│   │   ├── bookings_overview_screen.dart
│   │   ├── disputes_screen.dart
│   │   └── refunds_screen.dart
│   ├── reviews/
│   │   ├── reviews_moderation_screen.dart
│   │   └── reported_reviews_screen.dart
│   ├── analytics/
│   │   ├── platform_analytics_screen.dart
│   │   ├── financial_reports_screen.dart
│   │   └── user_insights_screen.dart
│   ├── content/
│   │   ├── content_management_screen.dart
│   │   ├── notifications_management_screen.dart
│   │   └── app_settings_screen.dart
│   └── support/
│       ├── support_tickets_screen.dart
│       └── system_logs_screen.dart
│
└── shared/                  # Écrans partagés
    ├── loading_screen.dart
    ├── error_screen.dart
    ├── no_internet_screen.dart
    ├── maintenance_screen.dart
    └── onboarding/
        ├── welcome_screen.dart
        ├── tutorial_screen.dart
        └── permissions_screen.dart
```

## 🔐 Contrôle d'Accès par Rôle

### Utilisateur Standard
- Interface complète utilisateur
- Pas d'accès admin/provider

### Prestataire 
- Interface utilisateur + provider
- Gestion de ses services et réservations

### Administrateur
- Accès complet à toutes les interfaces
- Outils de modération et analytics

## 🎯 Priorités de Développement

### Phase 1 - MVP
1. Services (liste, détail, réservation)
2. Dashboard prestataire basique
3. Panel admin essentiel

### Phase 2 - Fonctionnalités Avancées
1. Analytics et rapports
2. Système de reviews complet
3. Notifications avancées

Cette architecture permet une évolution progressive et modulaire de l'application.
