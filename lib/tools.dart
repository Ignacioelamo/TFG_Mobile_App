import 'package:flutter/services.dart';

class Tools {

  Tools._privateConstructor();
  static final Tools instance = Tools._privateConstructor();

  final List<String> permissionGroups = [
    "ACTIVITY_RECOGNITION",
    "CALENDAR",
    "CALL_LOG",
    "CAMERA",
    "CONTACTS",
    "LOCATION",
    "MICROPHONE",
    "NEARBY_DEVICES",
    "NOTIFICATIONS",
    "PHONE",
    "READ_MEDIA_AURAL",
    "READ_MEDIA_VISUAL",
    "SENSORS",
    "SMS",
    "STORAGE"
  ];


}
