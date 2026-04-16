import 'dart:convert';
import 'dart:developer';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class PusherHelper{

  static PusherChannelsClient?  pusherClient;

  static Future<void> initializePusher() async{
    final config = Get.find<SplashController>().configModel;
    final rawUrl = config?.websocketUrl ?? '';
    final host = rawUrl.isNotEmpty ? Uri.parse(rawUrl).host : '';
    final port = config?.websocketPort ?? 443;
    final key = config?.websocketKey ?? '6ammart';

    PusherChannelsOptions testOptions = PusherChannelsOptions.fromHost(
      host: host,
      scheme: 'wss',
      key: key,
      port: port,
    );

    pusherClient = PusherChannelsClient.websocket(
      options: testOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        log('=================$exception');
        refresh();
      },
    );

    debugPrint('[PUSHER] connecting to host=$host port=$port key=$key scheme=wss');
    await pusherClient?.connect();

    String? pusherChannelId =  pusherClient?.channelsManager.channelsConnectionDelegate.socketId;
      if(pusherChannelId != null){
        debugPrint('[PUSHER] connected socketId=$pusherChannelId');
      } else {
        debugPrint('[PUSHER] connected but socketId is null');
      }

     pusherClient?.lifecycleStream.listen((event) {
       debugPrint('[PUSHER] lifecycle event: $event');
     });


  }

  // late PrivateChannel pusherDriverLocation;
  late PublicChannel? publicChannel;

  void pusherDriverStatus({required String deliverymanId, required Function(RecordLocationBodyModel) onLocationReceived}){

    String channel = 'dm_location_$deliverymanId';

    debugPrint('[PUSHER] subscribing to channel=$channel (pusherClient=${pusherClient != null ? "ok" : "NULL"})');

    publicChannel = pusherClient!.publicChannel(channel);
    publicChannel?.subscribeIfNotUnsubscribed();

    publicChannel?.bind('pusher:subscription_succeeded').listen((_) {
      debugPrint('[PUSHER] subscription_succeeded on channel=$channel');
    });

    publicChannel?.bind('pusher:subscription_error').listen((error) {
      debugPrint('[PUSHER] subscription_error on channel=$channel: ${error.data}');
    });

    publicChannel?.bind(channel).listen((event) {
      debugPrint('[PUSHER] event received on $channel: ${event.data}');
      final data = jsonDecode(event.data);
      onLocationReceived(RecordLocationBodyModel(
        latitude: data['latitude']?.toString(),
        longitude: data['longitude']?.toString(),
        location: data['location'],
      ));
    });


  }


  void pusherDisconnectPusher(){
    publicChannel?.unsubscribe();
    pusherClient?.disconnect();
  }


}

class RecordLocationBodyModel {
  String? latitude;
  String? longitude;
  String? location;

  RecordLocationBodyModel({this.latitude, this.longitude, this.location});
}