// import 'dart:html';
import 'dart:convert' as convert;
import 'dart:ui';
import 'package:app_install_date/app_install_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler_web/permission_handler_web.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/config.dart';
import '../constants/lang.dart';
import '../models/appInfo.dart';
import '../models/authen.dart';
import '../models/profile.dart';
import '../screens/register_screen.dart';
import '../services/current_location_service.dart';

import 'package:url_launcher/url_launcher.dart';
import '../services/reToken_service.dart';
import '../services/validateSessionId_service.dart';

import 'package:location/location.dart' as loc;

class UtilService {
  static Future<SharedPreferences> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  static Future<void> getLanguageFromFireStore() async {
    var language = await UtilService.getLanguage();
    await FirebaseFirestore.instance
        .collection("language_" + language)
        // .where("lang", isEqualTo: language)
        .get()
        .then(
      (querySnapshot) {
        //print("Successfully completed");
        //lang = querySnapshot.docs;
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
          lang.add(docSnapshot.data());
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  static Future<bool> getCanchangeLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isCan = prefs.getString('isCanchangeLang') == "true";

    return isCan;
  }

  static Future<void> reToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? lang = prefs.getString('lang');

    //var url = window.location.href;

    if (lang == null) {
      setSharedPreferencesWithPrefs(prefs, "lang", language);
    }

    if (token != null && token.isNotEmpty) {
      setSharedPreferencesWithPrefs(prefs, "isLoadingToken", "Y");

      Profile profile = Profile.fromJson(convert.jsonDecode(token));
      ReTokenService reTokenService =
          ReTokenService(profile: profile, language: lang);

      await reTokenService.getNewToken();

      setSharedPreferencesWithPrefs(prefs, "isLoadingToken", "N");
    }
  }

  static Future<String> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lang = prefs.getString('lang');

    if (lang == null) {
      lang = language;
      setSharedPreferencesWithPrefs(prefs, "lang", language);
    }

    return lang;
  }

  static String getTextFromLang(field, text) {
    dynamic filtered = lang.where((e) => e['field'] == field);
    for (dynamic f in filtered) {
      //print(f['text']);
      text = f['text'];
      //print('${docSnapshot.id} => ${docSnapshot.data()}');
      //lang.add(docSnapshot.data());
    }

    return text;
  }

  static Future<bool> setSharedPreferences(key, value) async {
    try {
      SharedPreferences prefs = await getSharedPreferences();
      await prefs.setString(key, value);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setSharedPreferencesWithPrefs(
      SharedPreferences prefs, key, value) async {
    try {
      await prefs.setString(key, value);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> isLoadingToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('isLoadingToken') ?? "N";

    return token;
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return token;
  }

  static Future<AppInfo?> getAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? appversion = prefs.getString('appversion');
    if (appversion != null) {
      return AppInfo.fromJson(convert.jsonDecode(appversion.toString()));
    } else {
      return null;
    }
  }

  static String getStatusName(statusid) {
    List<int> WaitingApprove = [6000001, 6100001, 7000001, 8500001, 8600001];
    List<int> Approved = [6000002, 6100002, 7000002, 8500002, 8600002];
    List<int> Unapproved = [6000003, 6100003, 7000003, 8500003, 8600003];

    if (WaitingApprove.contains(statusid)) {
      return getTextFromLang("WaitingApprove", 'รออนุมัติ');
    } else if (Approved.contains(statusid)) {
      return getTextFromLang("Approved", 'อนุมัติ');
    } else if (Unapproved.contains(statusid)) {
      return getTextFromLang("Unapproved", 'ไม่อนุมัติ');
    }
    return '';
  }

  static Future<DateTime?> getInstallTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString('installTime');

    if (val != null && DateTime.tryParse(val) != null) {
      return DateTime.parse(val);
    } else {
      return null;
    }
  }

  static DateTime? getInstallTimeFromPrefs(SharedPreferences prefs) {
    String? val = prefs.getString('installTime');

    if (val != null && DateTime.tryParse(val) != null) {
      return DateTime.parse(val);
    } else {
      return null;
    }
  }

  static Future<bool> isNewestVersion() async {
    bool valid = true;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppInfo? appInfo = await getAppInfo();

    if (appInfo == null) {
      valid = false;
    } else {
      valid = int.parse(packageInfo.buildNumber) >= appInfo.build_number!;
    }

    return valid;
  }

  static Future<String?> getLineToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('line_token');

    return token;
  }

  static Future<Authen?> getAuthen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authen = prefs.getString('authen');

    return authen == null || authen.isEmpty
        ? null
        : Authen.fromJson(convert.jsonDecode(authen.toString()));
  }

  static Future<Profile?> getProfile() async {
    String? token = await getToken();

    return token == null || token.isEmpty
        ? null
        : Profile.fromJson(convert.jsonDecode(token.toString()));
  }

  static Future<bool> clearToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", "");
      await prefs.setString('line_token', "");
      // await prefs.getString("token");

      return true;
    } catch (e) {
      return false;
    }
  }

  static showAlert(GlobalKey locationKey, BuildContext context, String title) {
    final renderObject = locationKey.currentContext!.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    final offset = Offset(translation!.x, translation.y);

    //renderObject!.paintBounds.shift(offset);

    // RenderBox renderBox = locationKey.currentContext.findRenderObject();
    // var offset = renderBox.localToGlobal(Offset.zero);
    Rect rect = Rect.fromLTWH(offset.dx, offset.dy,
        renderObject!.paintBounds.width, renderObject.paintBounds.height);
    showMenu(
      context: context,
      position:
          RelativeRect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom),
      items: [
        PopupMenuItem(
          value: 1,
          child: Text(title),
        ),
      ],
    );
  }

  static alertEmpty(BuildContext context, title) {
    Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: AlertType.warning,
      title: title,
      buttons: [
        DialogButton(
          color: const Color(0xFFFF8101),
          onPressed: () => Navigator.pop(context, true),
          // onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  static Future<void> launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  static Future<void> launchAppStore() async {
    String appPackageName = "iexcellence.hr.wecheck";
    try {
      await launch("https://itunes.apple.com/th/app/wecheck/id1596275552");
      //("https://apps.apple.com/th/app/wecheck-hrmi/id1596275552");
      //("market://details?id=id1596275552");
      //("https://apps.apple.com/app/id1596275552");
      // //
    } on PlatformException {
      await launch(
          "https://play.google.com/store/apps/details?id=$appPackageName");
    } finally {
      await launch(
          "https://play.google.com/store/apps/details?id=$appPackageName");
    }
  }

  static Future<Position?> getCurrentLocation(Profile? profile) async {
    try {
      if (profile == null || profile.passcode == appstorePasscode) {
        return null;
      } else {
        // if (kIsWeb) {
        //   Coordinates? latlong =
        //       (await navigator.geolocation.getCurrentPosition()).coords;
        //   if (latlong != null) {
        //     Position pos = Position(
        //         longitude: latlong.longitude! + 0.00,
        //         latitude: latlong.latitude! + 0.00,
        //         timestamp: DateTime.now(),
        //         accuracy: latlong.accuracy! + 0.00,
        //         altitude: (latlong.altitude ?? 0) + 0.00,
        //         altitudeAccuracy: (latlong.altitudeAccuracy ?? 0) + 0.00,
        //         heading: (latlong.heading ?? 0) + 0.00,
        //         headingAccuracy: (latlong.heading ?? 0) + 0.00,
        //         speed: (latlong.speed ?? 0) + 0.00,
        //         speedAccuracy: (latlong.speed ?? 0) + 0.00);

        //     return pos;
        //   }
        // } else {
        //   CurrentLocationService currentLocationService =
        //       CurrentLocationService();

        //   Position position = await currentLocationService.determinePosition();
        //   return position;
        // }

        // return null;

        CurrentLocationService currentLocationService =
            CurrentLocationService();

        Position position = await currentLocationService.determinePosition();
        return position;
      }
    } catch (e) {
      print("util service getCurrentLocation function error line 343," +
          e.toString());
      //resultText = e;

      return null;
    }
  }

  static Alert buildAlertError(
      BuildContext context, String title, String message) {
    return Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: AlertType.warning,
      title: title,
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    );
  }

  static Future<bool> onBackPressed(context) async {
    bool result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แน่ใจหรือไม่?'),
        content: const Text('คุณต้องการออกจากแอพนี้'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.check),
            label: const Text('ใช่'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            icon: const Icon(Icons.close_sharp),
            label: const Text('ไม่'),
          ),
        ],
      ),
    );

    return result;
  }

  void validateToken(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String appName = packageInfo.appName;
    // String appVersion = packageInfo.version;
    int buildNumber = int.parse(packageInfo.buildNumber);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token != '') {
      Profile profile = Profile.fromJson(convert.jsonDecode(token));

      if (!kIsWeb && buildNumber < profile.build_number!) {
        Alert a = await UpdateDialog(context, profile.app_version ?? "");
        a.show();
      }
    }
  }

  void validateSession(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String prefAuthen = prefs.getString('authen') ?? '';
    String sessionId = prefs.getString('session_id') ?? '';

    if (prefAuthen.isNotEmpty && sessionId.isNotEmpty) {
      Authen authen = Authen.fromJson(convert.jsonDecode(prefAuthen));
      ValidateSessionIdService validSession =
          ValidateSessionIdService(authen: authen, sessionid: sessionId);

      bool valid = await validSession.validateSessionId() ?? false;
      if (!valid) {
        Navigator.pushNamedAndRemoveUntil(
            context, Register.id, (route) => false);
      }
    } else {
      DateTime newInstallTime =
          !kIsWeb ? await AppInstallDate().installDate : DateTime.now();
      UtilService.setSharedPreferences(
          "installTime", newInstallTime.toString());
      Navigator.pushNamedAndRemoveUntil(context, Register.id, (route) => false);
    }
  }

  // Future<void> _messageHandler(RemoteMessage message) async {
  //   print('background message ${message.notification!.body}');
  // }

  Future<Alert> UpdateDialog(BuildContext context, String toVersion) async {
    return Alert(
      context: context,
      type: AlertType.warning,
      title: 'Updating....', //appName + " v." + appVersion,
      desc: "ต้องการ Update ระบบเป็น v.$toVersion",
      buttons: [
        DialogButton(
          onPressed: () async {
            //LaunchReview.launch();
            launchAppStore();
            SystemNavigator.pop();
          },
          gradient: const LinearGradient(colors: [
            Colors.deepOrangeAccent,
            Colors.deepOrangeAccent,
          ]),
          child: const Text(
            "อัพเดท",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          gradient: const LinearGradient(colors: [
            Colors.black,
            Colors.black,
          ]),
          child: const Text(
            "ปิด",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    );
  }
}
