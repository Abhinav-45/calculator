import 'dart:io' as io;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceId;
  String brand;
  String product;
  String model;
  String id;

  try {
    if (io.Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown';
    } else if (io.Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
      brand = androidInfo.brand;
      product = androidInfo.product;
      model = androidInfo.model;
      deviceId = id + brand + product + model;
    } else {
      deviceId = 'unknown'; 
    }
  } catch (e) {
    deviceId = 'unknown';
    if (kDebugMode) {
      print('Error retrieving device ID: $e');
    }
  }

  return deviceId;
}
