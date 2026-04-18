import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class PusherHelper {
  static PusherChannelsClient? pusherClient;
  static StreamSubscription? _lifecycleSubscription;

  static Future<void> initializePusher() async {
    final config = Get.find<SplashController>().configModel;
    final rawUrl = config?.websocketUrl ?? '';
    final host = rawUrl.isNotEmpty ? Uri.parse(rawUrl).host : '';
    final port = config?.webSocketPort ?? 443;
    final key = config?.webSocketKey ?? '6ammart';

    if (host.isEmpty) {
      debugPrint('[PUSHER] skipped: websocket host is empty');
      return;
    }

    PusherChannelsOptions testOptions = PusherChannelsOptions.fromHost(
      host: host,
      scheme: 'wss',
      key: key,
      port: port,
    );

    await _lifecycleSubscription?.cancel();
    pusherClient?.disconnect();
    pusherClient = PusherChannelsClient.websocket(
      options: testOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        debugPrint('[PUSHER] connection error: $exception');
        refresh();
      },
    );

    await pusherClient?.connect();
    debugPrint('[PUSHER] connected host=$host port=$port');

    _lifecycleSubscription = pusherClient?.lifecycleStream.listen((event) {
      debugPrint('[PUSHER] lifecycle: $event');
    });
  }

  PublicChannel? publicChannel;
  StreamSubscription? _driverSubscribedSubscription;
  StreamSubscription? _driverSubscriptionErrorSubscription;
  StreamSubscription? _driverEventSubscription;
  StreamSubscription? _driverDotEventSubscription;

  void pusherDriverStatus({
    required String deliverymanId,
    required Function(RecordLocationBodyModel) onLocationReceived,
  }) {
    String channel = 'dm_location_$deliverymanId';

    debugPrint('[PUSHER] subscribing channel=$channel');

    if (pusherClient == null) {
      debugPrint('[PUSHER] skipped channel=$channel because client is null');
      return;
    }

    _cancelDriverBindings();
    publicChannel?.unsubscribe();
    publicChannel = null;

    publicChannel = pusherClient!.publicChannel(channel);

    publicChannel?.subscribeIfNotUnsubscribed();

    _driverSubscribedSubscription = publicChannel
        ?.bind('pusher:subscription_succeeded')
        .listen((_) {
          debugPrint('[PUSHER] public subscribed channel=$channel');
        });

    _driverSubscriptionErrorSubscription = publicChannel
        ?.bind('pusher:subscription_error')
        .listen((error) {
          debugPrint(
            '[PUSHER] public subscription failed channel=$channel error=${error.data}',
          );
        });

    _driverEventSubscription = publicChannel?.bind(channel).listen((event) {
      _handleDriverLocationEvent(event.data, onLocationReceived);
    });
    _driverDotEventSubscription = publicChannel?.bind('.$channel').listen((
      event,
    ) {
      _handleDriverLocationEvent(event.data, onLocationReceived);
    });
  }

  void pusherDisconnectPusher() {
    _cancelDriverBindings();
    publicChannel?.unsubscribe();
    publicChannel = null;
    pusherClient?.disconnect();
  }

  void _handleDriverLocationEvent(
    dynamic eventData,
    Function(RecordLocationBodyModel) onLocationReceived,
  ) {
    try {
      debugPrint('[PUSHER] driver event data=$eventData');
      final dynamic decoded = eventData is String
          ? jsonDecode(eventData)
          : eventData;
      if (decoded is! Map) {
        debugPrint('[PUSHER] ignored driver event with invalid payload');
        return;
      }

      onLocationReceived(
        RecordLocationBodyModel(
          latitude: decoded['latitude']?.toString(),
          longitude: decoded['longitude']?.toString(),
          location: decoded['location']?.toString(),
        ),
      );
    } catch (error) {
      debugPrint('[PUSHER] failed to parse driver event: $error');
    }
  }

  void _cancelDriverBindings() {
    _driverSubscribedSubscription?.cancel();
    _driverSubscriptionErrorSubscription?.cancel();
    _driverEventSubscription?.cancel();
    _driverDotEventSubscription?.cancel();
    _driverSubscribedSubscription = null;
    _driverSubscriptionErrorSubscription = null;
    _driverEventSubscription = null;
    _driverDotEventSubscription = null;
  }
}

class RecordLocationBodyModel {
  String? latitude;
  String? longitude;
  String? location;

  RecordLocationBodyModel({this.latitude, this.longitude, this.location});
}
