import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity/connectivity.dart';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkChecking {
  String connectionStatus = 'Unknown';
  String ipAddress = 'Unknown';
  String typeNetwork = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  NetworkChecking() {
    print('_connectionStatus $connectionStatus');
    initConnectivity();
    _connectivitySubscription = _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(updateConnectionStatus);

    // getIps();
  }

  // Future<String> getRouterIp() {
  //   return ipAddress;
  // }
  //
  Future<dynamic> getRouterSSID() async {
    print('getRouterSSID function');
// Check to see if Android Location permissions are enabled
    // Described in https://github.com/flutter/flutter/issues/51529
    if (!kIsWeb && Platform.isAndroid) {
      print('Checking Android permissions');
      var status = await Permission.location.status;
      // Blocked?
      if (status.isDenied || status.isRestricted) {
        // Ask the user to unblock
        if (await Permission.location.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          print('Location permission granted');
        } else {
          print('Location permission not granted');
        }
      } else {
        print('Permission already granted (previous execution?)');
      }
    }
  }

  netDismiss() {
    _connectivitySubscription.cancel();
  }

  Future getIps() async {
    for (var interface in await NetworkInterface.list()) {
      print('== Interface: ${interface.name} ==');
      for (var addr in interface.addresses) {
        print(
            '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
        return ipAddress = addr.address;
      }
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    // Check to see if Android Location permissions are enabled
    // Described in https://github.com/flutter/flutter/issues/51529
    if (!kIsWeb && Platform.isAndroid) {
      print('Checking Android permissions');
      var status = await Permission.location.status;
      // Blocked?
      if (status.isDenied || status.isRestricted) {
        // Ask the user to unblock
        if (await Permission.location.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          print('Location permission granted');
        } else {
          print('Location permission not granted');
        }
      } else {
        print('Permission already granted (previous execution?)');
      }
    }

    if (result != null) await updateConnectionStatus(result);
  }

  Future<void> updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        print(result.toString());
        connectionStatus = result.toString();
        break;
      default:
        print('Failed to get connectivity.');
        connectionStatus = 'Failed to get connectivity.';
        break;
    }
    typeNetwork = connectionStatus;
  }
}
