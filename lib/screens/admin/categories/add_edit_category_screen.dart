import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import '../../../utils/event_bus.dart';
import '../../../widgets/overflow_safe_widgets.dart';
import 'logic/logic.dart';
import 'widgets/widgets.dart';

/// Écran d'ajout/modification de catégorie - Version Clean Architecture
///
/// Cette version est refactorisée selon le pattern Clean Architecture :
/// - UI pure sans logique métier
/// - Toute la logique déplacée dans les handlers
/// - Communication via EventBus
/// - Widgets modulaires et réutilisables
class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Handlers de logique métier
  late final CategoryFormData _formData;
  late final CategoryImageHandler _imageHandler;
  late final CategorySaveHandler _saveHandler;
  late final CategoryEventHandler _eventHandler;
  late final CategorySnackBarManager _snackBarManager;

  @override
  void initState() {
    super.initState();
    _initializeHandlers();
    _setupInitialData();
  }

  /// Initialiser tous les handlers de logique
  void _initializeHandlers() {
    _formData = CategoryFormData();
    _imageHandler = CategoryImageHandler();
    _saveHandler = CategorySaveHandler();
    _snackBarManager = CategorySnackBarManager();

    _eventHandler = CategoryEventHandler(
      formData: _formData,
      imageHandler: _imageHandler,
      saveHandler: _saveHandler,
      onStateChanged: _handleStateChanged,
    );
  }

  /// Configurer les données initiales
  void _setupInitialData() {
    _eventHandler.initializeCategory(widget.category);
    _emitInitialState();
  }

  /// Gérer les changements d'état et propager via EventBus
  void _handleStateChanged() {
    _emitState();
  }

  /// Émettre l'état initial
  void _emitInitialState() {
    EventBus.instance.emit(_formData);
    EventBus.instance.emit(_imageHandler);
    EventBus.instance.emit(_saveHandler);
    EventBus.instance.emit(_eventHandler);
    EventBus.instance.emit(_snackBarManager);
  }

  /// Émettre l'état actuel
  void _emitState() {
    if (mounted) {
      setState(() {
        EventBus.instance.emit(_formData);
        EventBus.instance.emit(_imageHandler);
        EventBus.instance.emit(_saveHandler);
        EventBus.instance.emit(_eventHandler);
      });
    }
  }

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CategoryAppBar(category: widget.category),
      body: OverflowSafeArea(child: CategoryBody(formKey: _formKey)),
      bottomNavigationBar: CategoryBottomBar(
        category: widget.category,
        formKey: _formKey,
      ),
    );
  }
}
