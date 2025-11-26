import 'package:shared_events/shared_events.dart';

abstract class BaseWebsocketProvider {
  void registerType<T>(TypeAdapter<T> type);
}