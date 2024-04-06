import 'dart:async';

import 'fileManager.dart';
import 'appConfig.dart';
import 'package:gps_connectivity/gps_connectivity.dart';

class SubscriptionManager{
  SubscriptionManager._privateConstructor();
  static final SubscriptionManager instance = SubscriptionManager._privateConstructor();

  // All the subscriptions that the app has
  StreamSubscription<bool>? _gpsSubscription;

  // Foreach subscription, the key is the subscription name and the value is the subscription status
  Map<String, bool> subscriptions = {};
  void addSubscription(String subscriptionName){
    subscriptions[subscriptionName] = false;
  }

  void removeSubscription(String subscriptionName){
    subscriptions.remove(subscriptionName);
  }

  void updateSubscription(String subscriptionName, bool status){
    subscriptions[subscriptionName] = status;
  }

  bool isSubscribed(String subscriptionName){
    return subscriptions[subscriptionName] ?? false;
  }

  void clearSubscriptions(){
    subscriptions.clear();
  }

  void subcribeToGpsChanges(){
    try{
      if (_gpsSubscription == null){
        _gpsSubscription = GpsConnectivity().onGpsConnectivityChanged.listen((bool result) async{
          await saveGpsData(AppConfig.gpsDataFileName);
        });
        updateSubscription('gps', _gpsSubscription != null);
      }
    }catch(e){
      FileManager.instance.writeToFile(AppConfig.logFileName, e.toString());
    }
  }

   Future<void> saveGpsData(String fileName) async {
    String gpsData = await GpsConnectivity().checkGpsConnectivity() ? 'GPS_connected' : 'GPS_disconnected';

    DateTime now = DateTime.now();
    String date = '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}';
    String gpsInfo = 'Date: $date:$gpsData\n';

    await FileManager.instance.saveFile(fileName, gpsInfo);
  }

}