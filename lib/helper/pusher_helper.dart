import 'dart:convert';
import 'dart:developer';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class PusherHelper{

  static PusherChannelsClient?  pusherClient;

  static Future<void> initializePusher() async{
    final config = Get.find<SplashController>().configModel;
    final rawUrl = config?.websocketUrl ?? '';
    final host = rawUrl.isNotEmpty ? Uri.parse(rawUrl).host : '';
    final port = config?.webSocketPort ?? 443;
    final key = config?.webSocketKey ?? '6ammart';

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

    await pusherClient?.connect();

    String? pusherChannelId =  pusherClient?.channelsManager.channelsConnectionDelegate.socketId;
      if(pusherChannelId != null){
        log('=================Pusher Connected');
      }

     pusherClient?.lifecycleStream.listen((event) {
       log('=================Pusher DisConnected');
     });


  }

  // late PrivateChannel pusherDriverLocation;
  late PublicChannel? publicChannel;

  void pusherDriverStatus({required String deliverymanId, required Function(RecordLocationBodyModel) onLocationReceived}){

    String channel = 'dm_location_$deliverymanId';

    log('========channel is: $channel');

    publicChannel = pusherClient!.publicChannel(channel);

    publicChannel?.subscribeIfNotUnsubscribed();

    publicChannel?.bind('pusher:subscription_succeeded').listen((_) {
      log('=======Public Subscribed');
    });

    publicChannel?.bind('pusher:subscription_error').listen((error) {
      log('=======Public Subscription Failed: ${error.data}');
    });

    publicChannel?.bind(channel).listen((event) {
      log('===========pusherDriverStatus bind is: ${event.data}');
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
