import 'dart:async';
// import 'dart:html';
import 'dart:io';

import 'package:app_install_date/app_install_date.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wecheck/constants/config.dart';
import 'package:wecheck/screens/dashboard_screen.dart';
import 'package:wecheck/screens/register_screen.dart';
import 'package:wecheck/services/util_service.dart';

import 'package:location/location.dart';

import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late String appName;
// late String packageName;
late String version;
// late String buildNumber;

bool startLoad = true;
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
  FirebaseApp? app = null;
  try {
    if (kIsWeb) {
      app = await Firebase.initializeApp(
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
      app = await Firebase.initializeApp();
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    await FirebaseFirestore.instance
        .collection("host")
        .where("app", isEqualTo: "wecheck")
        .get()
        .then(
      (querySnapshot) {
        //print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          //print('${docSnapshot.id} => ${docSnapshot.data()}');
          ApiDomain = querySnapshot.docs[0].data()["url"];
        }
      },
      onError: (e) => ApiDomain =
          "https://hrmobile.iexcellence.cloud", //print("Error completing: $e"),
    );
  } on Exception catch (ex) {
    print(ex.toString());
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await UtilService.reToken();
  await UtilService.getLanguageFromFireStore();

  HttpOverrides.global = MyHttpOverrides();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  appName = packageInfo.appName;
  //packageName = packageInfo.packageName;
  version = packageInfo.version;
  //profile = (await UtilService.getProfile())!;

  InitialNotify();
}

Future<void> InitialNotify() async {
  FlutterAppBadger.removeBadge();

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('app_icon');
  //var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettingsIOS = const IOSInitializationSettings();
  // onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  //,onSelectNotification: onSelectNotification);

  if (Platform.isIOS) {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  } else {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'high_importance_channel', // title
      //'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (message.notification != null) {
        // && android != null) {
        RemoteNotification notification = message.notification!;
        AndroidNotification android = message.notification!.android!;

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                //channel.description,
                icon: android.smallIcon,
                // other properties...
              ),
            ));
      }
    });
  }
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print('Message clicked!');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeCheck',
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container()),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const Dashboard(),
      initialRoute: '/splash',
      routes: <String, WidgetBuilder>{
        '/splash': (context) => const SplashScreen(),
        Register.id: (context) => const Register(),
        Dashboard.id: (context) => const Dashboard(
              tabIndex: 0,
            ),
        // ScanScreen.id: (context) => const Dashboard(
        //       tabIndex: 2,
        //     ),
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences prefs;
  late DateTime newInstallTime;
  var timeout = const Duration(seconds: 5);
  var ms = const Duration(milliseconds: 1);

  String appName = "";
  String appVersion = "";
  int buildNumber = 0;

  startTimeout([int? milliseconds]) async {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return Timer(duration, handleTimeout);
    //handleTimeout();
  }

  void handleTimeout() async {
    bool valid = true;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    appVersion = packageInfo.version;
    buildNumber = int.parse(packageInfo.buildNumber);

    if (mounted) {
      setState(() {
        appVersion = appVersion;
      });

      prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('session_id');
      String? token = prefs.getString('token');

      newInstallTime =
          !kIsWeb ? await AppInstallDate().installDate : DateTime.now();
      DateTime? oldInstallTime =
          !kIsWeb ? UtilService.getInstallTimeFromPrefs(prefs) : newInstallTime;

      if (sessionId == null ||
          oldInstallTime == null ||
          oldInstallTime.compareTo(newInstallTime) < 0 ||
          token == null ||
          token.isEmpty) valid = false;

      if (valid) {
        Navigator.pushNamedAndRemoveUntil(
            context, Dashboard.id, (route) => false);
      } else {
        toNewRegisterScreen();
      }

      Navigator.pushNamedAndRemoveUntil(
          context, Dashboard.id, (route) => false);
    }
  }

  void toNewRegisterScreen() {
    UtilService.setSharedPreferencesWithPrefs(
        prefs, "installTime", newInstallTime.toString());
    Navigator.pushNamedAndRemoveUntil(context, Register.id, (route) => false);
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
    startTimeout();
  }

  initPrefs() async {
    //await document.documentElement!.requestFullscreen();
    //window.history.pushState(null, 'wecheck', '#Register');
  }

  @override
  Widget build(BuildContext context) {
    UtilService().validateSession(context);
    FlutterNativeSplash.remove();

    return Scaffold(
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                alignment: Alignment.center,
                fit: BoxFit.fill),
          ),
          child: Stack(
            children: <Widget>[
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/images/scan1.png",
                          width: 170,
                          height: 170,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "WeCheck",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          (kIsWeb
                              ? "Loading...."
                              : (appVersion.isEmpty
                                  ? "Checking Version...."
                                  : "version $appVersion")),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        const CircularProgressIndicator(),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
