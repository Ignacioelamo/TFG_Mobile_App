import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'file_manager.dart';
import 'app_config.dart';
import 'package:gps_connectivity/gps_connectivity.dart';

class SubscriptionManager {
  SubscriptionManager._privateConstructor();
  static final SubscriptionManager instance =
      SubscriptionManager._privateConstructor();

  //Global variables
  String? _lastGpsTime;
  String? _lastGpsData;

  // All the subscriptions that the app has
  StreamSubscription<bool>? gpsSubscription;

  // Foreach subscription, the key is the subscription name and the value is the subscription status
  Map<String, bool> subscriptions = {};
  void addSubscription(String subscriptionName) {
    subscriptions[subscriptionName] = false;
  }

  void removeSubscription(String subscriptionName) {
    subscriptions.remove(subscriptionName);
  }

  void updateSubscription(String subscriptionName, bool status) {
    subscriptions[subscriptionName] = status;
  }

  bool isSubscribed(String subscriptionName) {
    return subscriptions[subscriptionName] ?? false;
  }

  void clearSubscriptions() {
    subscriptions.clear();
  }

  void subscribeToGpsChanges() {
    try {
      if (gpsSubscription == null) {
        gpsSubscription = GpsConnectivity()
            .onGpsConnectivityChanged
            .listen((bool result) async {
          print("Entro aquí");
          await saveGpsData(AppConfig.gpsDataFileName);
        });
        updateSubscription('gps', gpsSubscription != null);
      }
    } catch (e) {
      FileManager.instance.writeToFile(AppConfig.logFileName, e.toString());
    }
  }

  Future<void> saveGpsData(String fileName) async {
    bool gpsConnected = await GpsConnectivity().checkGpsConnectivity();
    DateTime now = DateTime.now();

    String gpsData = gpsConnected ? 'enabled' : 'disabled';
    String formattedDate = '${now.year}-${now.month}-${now.day}';
    String formattedTime = '${now.hour}:${now.minute}:${now.second}';

    String gpsInfo = '$formattedDate,$formattedTime,$gpsData\n';

    if (_lastGpsTime != formattedTime && _lastGpsData != gpsData ||
        _lastGpsTime == null) {
      _lastGpsTime = formattedTime;
      _lastGpsData = gpsData;
      await FileManager.instance.saveFile(fileName, gpsInfo);
    } else {
      return;
    }
  }
}
