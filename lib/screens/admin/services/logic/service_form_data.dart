import '../../../../models/models.dart';
import '../../../../utils/event_bus.dart';

/// Singleton pour gérer les données du formulaire de service
class ServiceFormData {
  static final ServiceFormData _instance = ServiceFormData._internal();
  factory ServiceFormData() => _instance;
  static ServiceFormData get instance => _instance;
  ServiceFormData._internal();

  // Données du formulaire
  String _name = '';
  String _description = '';
  double _price = 0.0;
  String _categoryId = '';
  String _categoryName = '';
  List<String> _tags = [];
  bool _isAvailable = true;
  bool _isActive = true;
  String? _imageUrl;
  bool _isEditing = false;

  // Getters
  String get name => _name;
  String get description => _description;
  double get price => _price;
  String get categoryId => _categoryId;
  String get categoryName => _categoryName;
  List<String> get tags => List.unmodifiable(_tags);
  bool get isAvailable => _isAvailable;
  bool get isActive => _isActive;
  String? get imageUrl => _imageUrl;
  bool get isEditing => _isEditing;

  // Update methods
  void updateName(String name) {
    _name = name;
    _notifyListeners();
  }

  void updateDescription(String description) {
    _description = description;
    _notifyListeners();
  }

  void updatePrice(double price) {
    _price = price;
    _notifyListeners();
  }

  void updateCategory(String categoryId, String categoryName) {
    _categoryId = categoryId;
    _categoryName = categoryName;
    _notifyListeners();
  }

  void updateTags(List<String> tags) {
    _tags = List.from(tags);
    _notifyListeners();
  }

  void updateAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
    _notifyListeners();
  }

  void updateActive(bool isActive) {
    _isActive = isActive;
    _notifyListeners();
  }

  void updateImageUrl(String? imageUrl) {
    _imageUrl = imageUrl;
    _notifyListeners();
  }

  /// Initialize form data from existing service or create new
  void initializeFromService(ServiceModel? service) {
    if (service != null) {
      _name = service.name;
      _description = service.description;
      _price = service.price;
      _categoryId = service.categoryId;
      _categoryName = service.categoryName;
      _tags = List.from(service.tags);
      _isAvailable = service.isAvailable;
      _isActive = service.isActive;
      _imageUrl = service.imageUrl;
      _isEditing = true;
    } else {
      // Reset to defaults for new service
      _reset();
    }

    // Notify listeners of initialization
    _notifyListeners();
  }

  /// Reset form data to defaults
  void _reset() {
    _name = '';
    _description = '';
    _price = 0.0;
    _categoryId = '';
    _categoryName = '';
    _tags = [];
    _isAvailable = true;
    _isActive = true;
    _imageUrl = null;
    _isEditing = false;
  }

  /// Create ServiceModel from current data
  ServiceModel createServiceModel({String? id}) {
    final now = DateTime.now();

    return ServiceModel(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      name: _name,
      description: _description,
      price: _price,
      categoryId: _categoryId,
      categoryName: _categoryName,
      tags: List.from(_tags),
      isAvailable: _isAvailable,
      isActive: _isActive,
      imageUrl: _imageUrl,
      createdAt: now, // Use now for both creation and editing
      updatedAt: now,
      rating: 0.0,
      totalReviews: 0,
      createdBy: 'admin',
    );
  }

  /// Notify listeners of changes
  void _notifyListeners() {
    EventBus.instance.emit(ServiceFormDataUpdated(this));
  }
}

/// Event classes
class ServiceFormDataUpdated {
  final ServiceFormData formData;
  ServiceFormDataUpdated(this.formData);
}
