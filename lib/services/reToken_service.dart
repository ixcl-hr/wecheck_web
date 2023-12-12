import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import '../constants/config.dart';
import '../models/authen.dart';
import '../models/feedback.dart';
import '../models/profile.dart';

class ReTokenService {
  final Profile profile;
  final String? sessionid;
  final String? appName;
  final String? appVersion;
  final String? language;
  ReTokenService(
      {required this.profile,
      this.sessionid,
      this.appName,
      this.appVersion,
      this.language});
  Future<bool?> getNewToken() async {
    //FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (kIsWeb) {
      await Firebase.initializeApp(
          //     name: "wecheck",
          options: const FirebaseOptions(
        apiKey: "AIzaSyD63WPeA769dOREvYuzbnzNNna1YF6_l4w",
        authDomain: "coastal-stone-341712.firebaseapp.com",
        projectId: "coastal-stone-341712",
        storageBucket: "coastal-stone-341712.appspot.com",
        messagingSenderId: "492430545955",
        appId: "1:492430545955:web:22d09a2331598e57978d96",
        measurementId: "G-3YTEFH8H0R",
      ));
    } else {
      //await Firebase.initializeApp(name: "wecheck");
      await Firebase.initializeApp();
    }

    String? fcmToken = null;

    await FirebaseMessaging.instance
        .getToken(
            vapidKey:
                "BCHx8nL7rBVPu1qbF-X5QJR5L59EFvbAj8HfF8vFiTc4Fy-Pa2Z4sUATOuP2S85q3GTuYyTEX08SEAdUS-ro4AE")
        .then((value) {
      fcmToken = value;
    }, onError: (e) {
      print("Error completing: $e");
    });
    print("firebase token: " + (fcmToken ?? ""));
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "passcode": profile.passcode,
      "sessionid": sessionid,
      "appName": appName,
      "platform": kIsWeb ? "web" : Platform.operatingSystem,
      "appVersion": (await PackageInfo.fromPlatform()).buildNumber,
      "fcmtoken": fcmToken,
      "language": language
    });
    print('---payload--');
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };

    var url = '${ApiMaster}AuthenticateEmployee';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);

    if (response.statusCode == 200) {
      Feedback feedback = Feedback.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        var result = convert.jsonDecode(response.body)['objectresult'];
        var valueJson = Profile.fromJson(result);
        var AuthenJson = Authen.fromJson(result);

        await _initPrefs();
        await prefs.setString('token', convert.jsonEncode(valueJson));
        await prefs.setString('authen', convert.jsonEncode(AuthenJson));
        await prefs.setString(
            'isCanchangeLang', convert.jsonEncode(result["isCanchangeLang"]));

        // await saveProfile(result['token'], result, profile);

        return true;
      } else if (feedback.flag == false) {
        print('Re-token failure');
        return false;
      }
    } else {
      print('Request status : ${response.statusCode}');
      return false;
    }

    return null;
  }

  late SharedPreferences prefs;
  _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}
