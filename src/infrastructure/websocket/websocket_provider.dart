import 'package:shared_events/shared_events.dart';

typedef OnClientConnect = void Function(
  WebsocketClient client,
  WebsocketProvider server,
);

typedef OnClientDisconnect = void Function(
  WebsocketClient client,
);

abstract class WebsocketProvider extends BaseWebsocketProvider {
  Future<WebsocketProvider> init({
    required OnClientConnect onClientConnect,
    required OnClientDisconnect onClientDisconnect,
  });

  void sendToClient<T>(WebsocketClient client, String event, T data);
  void sendToRoom<T>(String room, String event, T data);
  void broadcast<T>(String event, T data);
  void registerType<T>(TypeAdapter<T> type);
}

abstract class WebsocketClient {
  String get id;
  void on<T>(String event, void Function(T event) callback);
  void send<T>(String event, T data);
  void cleanListener(String event);
}
