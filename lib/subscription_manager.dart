import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'file_manager.dart';
import 'app_config.dart';
import 'package:gps_connectivity/gps_connectivity.dart';

class SubscriptionManager{
  SubscriptionManager._privateConstructor();
  static final SubscriptionManager instance = SubscriptionManager._privateConstructor();

  //Global variables
  String? _lastGpsDate;
  String? _lastGpsData;

  // All the subscriptions that the app has
  StreamSubscription<bool>? gpsSubscription;

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

  void subscribeToGpsChanges(){
    try{
      if (gpsSubscription == null){
        gpsSubscription = GpsConnectivity().onGpsConnectivityChanged.listen((bool result) async{
          await saveGpsData(AppConfig.gpsDataFileName);
        });
        updateSubscription('gps', gpsSubscription != null);
      }
    }catch(e){
      FileManager.instance.writeToFile(AppConfig.logFileName, e.toString());
    }
  }

   Future<void> saveGpsData(String fileName) async {
    String gpsData = await GpsConnectivity().checkGpsConnectivity() ? 'GPS_connected' : 'GPS_disconnected';

    DateTime now = DateTime.now();
    String date = '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}-${now.millisecond}';
    String gpsInfo = 'Date: $date:$gpsData\n';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serialNumber = prefs.getString('serialNumber');
    if (_lastGpsDate != date && _lastGpsData != gpsData || _lastGpsDate == null){
      _lastGpsDate = date;
      _lastGpsData = gpsData;
      await FileManager.instance.saveFile(fileName, gpsInfo);
      await FileManager.instance.saveFile(fileName, 'id: $serialNumber\n');
    }else{
      return;
    }


  }

}