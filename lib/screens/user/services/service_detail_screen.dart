import 'package:flutter/material.dart';
import '../../../services/review_service.dart';
import '../../../models/service_model.dart';
import '../../../models/review_model.dart';
import '../../../models/provider_model.dart';
import 'services/services_service.dart';
import 'sections/service_detail_sections.dart';
import 'widgets/service_widgets.dart';
import '../bookings/create_booking_screen.dart';
import '../../admin/providers/admin_provider_manager.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  final ServicesService _servicesService = ServicesService();
  final AdminProviderManager _providerManager = AdminProviderManager();

  bool _isFavorite = false;
  bool _isLoadingFavorite = true;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = true;
  ProviderModel? _provider;
  bool _isLoadingProvider = true;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Images du service (utilise displayImage pour simplifier)
  List<String> get _serviceImages {
    final imageUrl = widget.service.displayImage;
    if (imageUrl.isNotEmpty) {
      return [imageUrl];
    }
    // Image par défaut si aucune image
    return [
      'https://via.placeholder.com/400x300/6366f1/FFFFFF?text=${Uri.encodeComponent(widget.service.name)}',
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  /// Charge tous les détails du service
  Future<void> _loadServiceDetails() async {
    await Future.wait([
      _loadFavoriteStatus(),
      _loadReviews(),
      _loadProviderDetails(),
    ]);
  }

  /// Charge le statut favori
  Future<void> _loadFavoriteStatus() async {
    try {
      final isFavorite = await _servicesService.isServiceFavorite(
        widget.service.id,
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = isFavorite;
        _isLoadingFavorite = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingFavorite = false);
      _showErrorMessage('Erreur lors du chargement des favoris');
    }
  }

  /// Charge les avis du service
  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getServiceReviews(widget.service.id);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingReviews = false);
      _showErrorMessage('Erreur lors du chargement des avis');
    }
  }

  /// Charge les détails du prestataire
  Future<void> _loadProviderDetails() async {
    if (widget.service.providerId == null) {
      setState(() => _isLoadingProvider = false);
      return;
    }

    try {
      final provider = await _providerManager.getProviderById(
        widget.service.providerId!,
      );
      if (!mounted) return;
      setState(() {
        _provider = provider;
        _isLoadingProvider = false;
      });
    } catch (e) {
      print('Erreur lors du chargement du prestataire: $e');
      if (!mounted) return;
      setState(() => _isLoadingProvider = false);
    }
  }

  /// Bascule le statut favori
  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    if (!mounted) return;
    setState(() => _isLoadingFavorite = true);

    try {
      final newFavoriteStatus = await _servicesService.toggleServiceFavorite(
        widget.service.id,
      );

      if (!mounted) return;
      setState(() {
        _isFavorite = newFavoriteStatus;
        _isLoadingFavorite = false;
      });

      _showSuccessMessage(
        _isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingFavorite = false);
      _showErrorMessage('Erreur lors de la modification des favoris');
    }
  }

  /// Contacte le prestataire
  void _contactProvider() {
    if (_provider != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Contacter ${_provider!.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Téléphone: ${_provider!.phoneNumber}'),
              const SizedBox(height: 8),
              Text('Email: ${_provider!.email}'),
              const SizedBox(height: 8),
              Text('Spécialité: ${_provider!.specialty}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implémenter l'appel téléphonique ou l'envoi d'email
                _showSuccessMessage(
                  'Fonctionnalité de contact en cours de développement',
                );
              },
              child: const Text('Contacter'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations du prestataire non disponibles'),
        ),
      );
    }
  }

  /// Réserve le service
  void _bookService() {
    if (!widget.service.isAvailable) {
      _showErrorMessage('Ce service n\'est pas disponible actuellement');
      return;
    }

    // Navigation vers la page de réservation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBookingScreen(service: widget.service),
      ),
    );
  }

  /// Affiche tous les avis
  void _viewAllReviews() {
    Navigator.pushNamed(
      context,
      '/user/reviews',
      arguments: {
        'serviceId': widget.service.id,
        'serviceName': widget.service.name,
      },
    );
  }

  /// Affiche un message d'erreur
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Affiche un message de succès
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceInfoSection(service: widget.service),
                const SizedBox(height: 16),
                ServiceProviderSection(
                  service: widget.service,
                  onContactTap: _contactProvider,
                ),
                const SizedBox(height: 16),
                ServiceDescriptionSection(service: widget.service),
                const SizedBox(height: 16),
                ServicePricingSection(service: widget.service),
                const SizedBox(height: 16),
                ServiceReviewsSection(
                  reviews: _reviews,
                  isLoading: _isLoadingReviews,
                  onViewAllTap: _reviews.length > 3 ? _viewAllReviews : null,
                ),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Construit l'app bar avec l'image en arrière-plan
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: _serviceImages.length,
              itemBuilder: (context, index) {
                return ServiceImage(
                  imageUrl: _serviceImages[index],
                  size: double.infinity,
                );
              },
            ),
            if (_serviceImages.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _serviceImages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        _isLoadingFavorite
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
      ],
    );
  }

  /// Construit la barre du bas avec le bouton de réservation
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.service.providerName != null) ...[
              OutlinedButton(
                onPressed: _contactProvider,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.message),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: widget.service.isAvailable ? _bookService : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.service.isAvailable
                      ? 'Réserver maintenant'
                      : 'Service indisponible',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
