import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../utils/event_bus.dart';
import 'logic/logic.dart';
import 'widgets/widgets.dart';

class AddEditServiceScreen extends StatefulWidget {
  final ServiceModel? service;

  const AddEditServiceScreen({super.key, this.service});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ServiceEventHandler _eventHandler;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventHandler = ServiceEventHandler();
    _setupEventListeners();
    _initializeFormData();
  }

  void _setupEventListeners() {
    EventBus.instance.on<ServiceSaveStateChanged>().listen((event) {
      if (mounted) {
        setState(() {
          _isLoading = event.isLoading;
        });
      }
    });

    EventBus.instance.on<ServiceSaveCompleted>().listen((event) {
      if (mounted && event.success) {
        Navigator.of(context).pop();
      }
    });
  }

  void _initializeFormData() {
    ServiceFormData.instance.initializeFromService(widget.service);
  }

  @override
  void dispose() {
    _eventHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ServiceAppBar(
        service: widget.service,
        isLoading: _isLoading,
        onSave: () async {
          if (_formKey.currentState!.validate()) {
            await ServiceSaveHandler().saveService();
          }
        },
      ),
      body: ServiceBody(formKey: _formKey),
    );
  }
}
