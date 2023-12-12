// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wecheck/main.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:wecheck/models/profile.dart';
import 'package:wecheck/services/util_service.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
//     BehaviorSubject<ReceivedNotification>();

// final BehaviorSubject<String?> selectNotificationSubject =
//     BehaviorSubject<String?>();

// String? selectedNotificationPayload;

class SettingScreen extends StatefulWidget {
  static String id = 'Setting';

  const SettingScreen({Key? key, required this.profile}) : super(key: key);

  final Profile profile;

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  //Profile? profile;

  bool loading = false;

  @override
  void initState() {
    // Check flag

    //buildNumber = packageInfo.buildNumber;

    initPrefs();

    super.initState();
  }

  initPrefs() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFF8101),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ตั้งค่า',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            // Text("$appName $version",
            //     style: const TextStyle(
            //       fontWeight: FontWeight.bold,
            //     )),
            const SizedBox(
              height: 20,
            ),
            // ListTile(
            //     title: const Text(
            //       "แจ้งเตือนลงเวลา",
            //       style: TextStyle(
            //         fontSize: 20,
            //       ),
            //     ),
            //     onTap: () {
            //       // Navigator.of(context).push(MaterialPageRoute(
            //       //     builder: (context) => LocalNotificationPage(
            //       //         notificationAppLaunchDetails:
            //       //             globals.notificationAppLaunchDetails,
            //       //         flutterLocalNotificationsPlugin:
            //       //             globals.flutterLocalNotificationsPlugin,
            //       //         didReceiveLocalNotificationSubject:
            //       //             globals.didReceiveLocalNotificationSubject,
            //       //         selectNotificationSubject:
            //       //             globals.selectNotificationSubject)));
            //     },
            //     leading: const Icon(
            //       Icons.notification_important,
            //       color: Colors.black,
            //     )),
            // drawDivider(),
            // ListTile(
            //     title: const Text(
            //       "เปลี่ยนภาษา",
            //       style: TextStyle(
            //         fontSize: 20,
            //       ),
            //     ),
            //     onTap: () {},
            //     leading: const Icon(
            //       Icons.language,
            //       color: Colors.black,
            //     )),
            // drawDivider(),
            ListTile(
                title: Text(
                  UtilService.getTextFromLang(
                      "privacy_policy", 'นโยบายความเป็นส่วนตัว'),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () async {
                  UtilService.launchInBrowser(
                      'https://hrmobile.iexcellence.cloud/policy/privacy-policy-' +
                          (await UtilService.getLanguage()) +
                          '.html');
                },
                leading: const Icon(
                  Icons.receipt_long,
                  color: Colors.black,
                )),
            drawDivider(),
          ],
        ),
      ),
    );
  }

  Divider drawDivider() {
    return const Divider(
      height: 20,
      thickness: 1,
      indent: 0,
      endIndent: 0,
      color: Colors.grey,
    );
  }
}
