# Architecture des Écrans - Service App

## Vue d'ensemble

Cette application nécessite trois interfaces principales :
1. **Interface Client** - Pour les utilisateurs finaux
2. **Interface Prestataire** - Pour les fournisseurs de services  
3. **Interface Admin** - Pour l'administration complète

## 🏠 Interface Client (User Role)

### Authentification
- ✅ `login_screen.dart` (existant)
- ✅ `auth_wrapper.dart` (existant)
- 🆕 `register_screen.dart`
- 🆕 `forgot_password_screen.dart`
- 🆕 `verify_phone_screen.dart`

### Navigation Principale
- ✅ `home_screen.dart` (existant)
- 🆕 `search_screen.dart`
- 🆕 `categories_screen.dart`
- 🆕 `favorites_screen.dart`
- 🆕 `notifications_screen.dart`

### Services & Réservations
- 🆕 `service_details_screen.dart`
- 🆕 `service_booking_screen.dart`
- 🆕 `booking_confirmation_screen.dart`
- 🆕 `my_bookings_screen.dart`
- 🆕 `booking_details_screen.dart`
- 🆕 `service_request_screen.dart`
- 🆕 `my_requests_screen.dart`

### Profil & Paramètres
- 🆕 `profile_screen.dart`
- 🆕 `edit_profile_screen.dart`
- 🆕 `settings_screen.dart`
- 🆕 `help_support_screen.dart`

### Évaluations & Commentaires
- 🆕 `rate_service_screen.dart`
- 🆕 `rate_provider_screen.dart`
- 🆕 `reviews_screen.dart`

## 🔧 Interface Prestataire (Provider Role)

### Tableau de Bord
- 🆕 `provider_dashboard_screen.dart`
- 🆕 `provider_analytics_screen.dart`
- 🆕 `provider_earnings_screen.dart`

### Gestion des Services
- 🆕 `provider_services_screen.dart`
- 🆕 `add_edit_service_screen.dart`
- 🆕 `service_requests_received_screen.dart`

### Gestion des Réservations
- 🆕 `provider_bookings_screen.dart`
- 🆕 `booking_management_screen.dart`
- 🆕 `calendar_screen.dart`

### Profil Prestataire
- 🆕 `provider_profile_screen.dart`
- 🆕 `edit_provider_profile_screen.dart`
- 🆕 `portfolio_screen.dart`
- 🆕 `certifications_screen.dart`

### Évaluations Reçues
- 🆕 `provider_reviews_screen.dart`
- 🆕 `ratings_analytics_screen.dart`

## 👑 Interface Administration (Admin Role)

### Dashboard Principal
- 🆕 `admin_dashboard_screen.dart`
- 🆕 `admin_analytics_screen.dart`
- 🆕 `admin_reports_screen.dart`
- 🆕 `admin_statistics_screen.dart`

### Gestion des Utilisateurs
- 🆕 `admin_users_screen.dart`
- 🆕 `admin_user_details_screen.dart`
- 🆕 `admin_user_edit_screen.dart`
- 🆕 `admin_banned_users_screen.dart`

### Gestion des Prestataires
- 🆕 `admin_providers_screen.dart`
- 🆕 `admin_provider_details_screen.dart`
- 🆕 `admin_provider_verification_screen.dart`
- 🆕 `admin_provider_approval_screen.dart`

### Gestion des Services
- 🆕 `admin_services_screen.dart`
- 🆕 `admin_service_details_screen.dart`
- 🆕 `admin_categories_management_screen.dart`
- 🆕 `admin_service_moderation_screen.dart`

### Gestion des Réservations
- 🆕 `admin_bookings_screen.dart`
- 🆕 `admin_booking_details_screen.dart`
- 🆕 `admin_disputes_screen.dart`
- 🆕 `admin_refunds_screen.dart`

### Gestion du Contenu
- 🆕 `admin_reviews_moderation_screen.dart`
- 🆕 `admin_comments_moderation_screen.dart`
- 🆕 `admin_notifications_management_screen.dart`
- 🆕 `admin_content_management_screen.dart`

### Configuration Système
- 🆕 `admin_settings_screen.dart`
- 🆕 `admin_app_config_screen.dart`
- 🆕 `admin_payment_settings_screen.dart`
- 🆕 `admin_email_templates_screen.dart`

### Logs & Monitoring
- 🆕 `admin_logs_screen.dart`
- 🆕 `admin_system_health_screen.dart`
- 🆕 `admin_error_tracking_screen.dart`

## 🔄 Écrans Partagés

### Composants Réutilisables
- 🆕 `chat_screen.dart` (Support client)
- 🆕 `image_viewer_screen.dart`
- 🆕 `map_screen.dart`
- 🆕 `payment_screen.dart`
- 🆕 `camera_screen.dart`
- 🆕 `document_viewer_screen.dart`

### Erreurs & États
- 🆕 `error_screen.dart`
- 🆕 `maintenance_screen.dart`
- 🆕 `no_internet_screen.dart`
- 🆕 `empty_state_screen.dart`

## 📱 Structure de Navigation

### Bottom Navigation (Client)
1. **Accueil** - `home_screen.dart`
2. **Recherche** - `search_screen.dart`
3. **Réservations** - `my_bookings_screen.dart`
4. **Favoris** - `favorites_screen.dart`
5. **Profil** - `profile_screen.dart`

### Bottom Navigation (Prestataire)
1. **Dashboard** - `provider_dashboard_screen.dart`
2. **Services** - `provider_services_screen.dart`
3. **Réservations** - `provider_bookings_screen.dart`
4. **Calendrier** - `calendar_screen.dart`
5. **Profil** - `provider_profile_screen.dart`

### Sidebar Navigation (Admin)
- **Dashboard**
- **Utilisateurs**
- **Prestataires**
- **Services**
- **Réservations**
- **Contenu**
- **Configuration**
- **Logs**

## 🎯 Priorités de Développement

### Phase 1 - MVP Client
1. Authentification complète
2. Navigation de base
3. Catalogue de services
4. Système de réservation
5. Profil utilisateur

### Phase 2 - Interface Prestataire
1. Dashboard prestataire
2. Gestion des services
3. Gestion des réservations
4. Profil prestataire

### Phase 3 - Administration
1. Dashboard admin
2. Gestion des utilisateurs
3. Modération du contenu
4. Analytics et rapports

### Phase 4 - Fonctionnalités Avancées
1. Chat en temps réel
2. Géolocalisation
3. Paiements intégrés
4. Notifications push

## 🔒 Contrôle d'Accès par Rôle

```dart
// Exemple de routing conditionnel
Route<dynamic> generateRoute(RouteSettings settings) {
  final user = Provider.of<AuthProvider>(context).user;
  
  switch (user.role) {
    case UserRole.admin:
      return AdminRoutes.generateRoute(settings);
    case UserRole.provider:
      return ProviderRoutes.generateRoute(settings);
    case UserRole.user:
    default:
      return UserRoutes.generateRoute(settings);
  }
}
```

## 📐 Conventions de Nommage

- **Écrans Client** : `[feature]_screen.dart`
- **Écrans Prestataire** : `provider_[feature]_screen.dart`
- **Écrans Admin** : `admin_[feature]_screen.dart`
- **Composants** : `[feature]_widget.dart`
- **Dialogs** : `[feature]_dialog.dart`

Cette architecture modulaire permet une évolution progressive et une maintenance facilitée.
