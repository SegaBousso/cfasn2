import 'dart:async';

/// EventBus simple pour la communication entre widgets dans l'architecture clean
class EventBus {
  static final EventBus _instance = EventBus._internal();
  static EventBus get instance => _instance;

  EventBus._internal();

  final Map<Type, StreamController<dynamic>> _controllers = {};
  final Map<Type, dynamic> _latestValues = {};

  /// Émettre un événement/état
  void emit<T>(T data) {
    _latestValues[T] = data;

    if (!_controllers.containsKey(T)) {
      _controllers[T] = StreamController<T>.broadcast();
    }

    _controllers[T]!.add(data);
  }

  /// S'abonner aux événements d'un type donné
  Stream<T> on<T>() {
    if (!_controllers.containsKey(T)) {
      _controllers[T] = StreamController<T>.broadcast();
    }

    // Si nous avons une valeur précédente, créer un stream qui commence par cette valeur
    if (_latestValues.containsKey(T)) {
      return Stream.value(
        _latestValues[T] as T,
      ).mergeWith([_controllers[T]!.stream.cast<T>()]);
    }

    return _controllers[T]!.stream.cast<T>();
  }

  /// Obtenir la dernière valeur émise pour un type donné
  T? getLatest<T>() {
    return _latestValues[T] as T?;
  }

  /// Nettoyer les ressources
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _latestValues.clear();
  }
}

extension StreamExtension<T> on Stream<T> {
  Stream<T> mergeWith(List<Stream<T>> others) {
    final controller = StreamController<T>();

    final subscriptions = <StreamSubscription>[];

    // S'abonner à ce stream
    subscriptions.add(listen(controller.add, onError: controller.addError));

    // S'abonner aux autres streams
    for (final other in others) {
      subscriptions.add(
        other.listen(controller.add, onError: controller.addError),
      );
    }

    controller.onCancel = () {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    };

    return controller.stream;
  }
}
