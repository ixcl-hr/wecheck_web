import 'dart:convert' as convert;
import 'dart:async';
// import 'dart:html';
// import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geocoding/geocoding.dart';
import '../constants/config.dart';
import '../constants/lang.dart';
import '../pages/Profile/profile_page.dart';
import '../pages/approver/approver_page.dart';
import '../pages/map_view_page.dart';
import 'package:geolocator/geolocator.dart';
import '../models/profile.dart';
import '../pages/Calendars/calendar2_page.dart';
import '../pages/absents_quota_page.dart';
import '../pages/notification_page.dart';
import '../screens/register_screen.dart';
import '../screens/setting_screen.dart';
import '../services/util_service.dart';
import '../pages/report_page.dart';
import '../services/update_language_servide.dart';

class HomeScreen extends StatefulWidget {
  final String id = 'Home';
  final Function()? notifyParent;
  const HomeScreen({Key? key, required this.notifyParent}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Color colorIcon = Colors.orange[500] as Color;

  int currentIndexPage = 0;
  Profile? profile;
  bool isCanchangeLang = false;
  Uint8List? bytesImage;
  bool isHasImage = false;
  String currentLocationName = "";

  @override
  void initState() {
    super.initState();
    initPrefs();

    currentIndexPage = 0;
  }

  initPrefs() async {
    await getProfile();
    //await document.documentElement!.requestFullscreen();
    await getUserLocation();
  }

  getProfile() async {
    profile = await UtilService.getProfile();
    isCanchangeLang = await UtilService.getCanchangeLang();

    if (profile != null) {
      setState(() {
        profile = profile;
        String? imgString = (profile as Profile).employeepicture;
        //['employeepicture'];
        if (imgString != null) {
          isHasImage = true;
          bytesImage = const convert.Base64Decoder().convert(imgString);
        } else {
          isHasImage = false;
        }
      });
    }
  }

  getUserLocation() async {
    Position? position = await UtilService.getCurrentLocation(profile);

    if (position != null) {
      if (!kIsWeb) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];
        //print(place);
        currentLocationName = place.street ??
            ("Lat: ${position.latitude}, Lng: ${position.longitude}");
      } else {
        currentLocationName =
            "Lat: ${position.latitude}, Lng: ${position.longitude}";
      }
    } else {
      currentLocationName =
          UtilService.getTextFromLang("notfound_location", "ไม่พบพิกัด");
    }

    if (mounted) {
      setState(() {
        currentLocationName = currentLocationName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //   onWillPop: onBackPressed,
    //   child:

    return Scaffold(
      body: profile == null
          ? const CircularProgressIndicator()
          : Stack(
              children: <Widget>[
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/S30092002.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    top: 20,
                    left: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // kDebugMode || kIsWeb
                        //     ?
                        IconButton(
                          color: Colors.white,
                          onPressed: () async {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => ProfileEditPage(
                            //           title: "test url",
                            //         )));
                            // getToken();
                            Alert a = await logoutDialog(context);
                            a.show();
                            // Navigator.pushNamedAndRemoveUntil(
                            //     context, WelcomeScreen.id, (route) => false);
                          },
                          icon: const Icon(Icons.lock_open_outlined),
                        ),
                        // : const SizedBox(
                        //     width: 10,
                        //   ),
                        // Icon(Icons.lock_open_outlined),
                        Text(
                            (profile == null
                                ? ""
                                : (profile as Profile).companycaption ?? ""),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                      ],
                    )),
                Positioned(
                  top: 20,
                  right: 20,
                  child: !isCanchangeLang
                      ? SizedBox()
                      : PopupMenuButton(
                          color: Colors.white,
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text("English(en)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                  onTap: () async {
                                    await UtilService.setSharedPreferences(
                                        "lang", "en");
                                    await UtilService
                                        .getLanguageFromFireStore();
                                    UpdateLanguageService langservice =
                                        UpdateLanguageService(
                                            profile: profile!, language: "en");
                                    await langservice.updateLanguageToServer();

                                    (context as Element).reassemble();
                                    widget.notifyParent!();
                                    setState(() {});
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("ไทย(th)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                  onTap: () async {
                                    await UtilService.setSharedPreferences(
                                        "lang", "th");
                                    await UtilService
                                        .getLanguageFromFireStore();
                                    UpdateLanguageService langservice =
                                        UpdateLanguageService(
                                            profile: profile!, language: "th");
                                    await langservice.updateLanguageToServer();
                                    (context as Element).reassemble();
                                    widget.notifyParent!();
                                    setState(() {});
                                  },
                                ),
                              ]),
                ),
                Positioned(
                    top: 65,
                    left: 30,
                    // right: 30,
                    child: Column(children: [
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          GestureDetector(
                            child: !isHasImage || bytesImage == null
                                ? const CircleAvatar(
                                    minRadius: 25,
                                    maxRadius: 40,
                                    backgroundImage: AssetImage(
                                        'assets/images/unknown.jpeg'),
                                    // backgroundImage: !isHasImage || bytesImage == null
                                    //     ? AssetImage('assets/images/unknown.jpeg')
                                    //     : MemoryImage(bytesImage!),
                                    backgroundColor: Colors.transparent,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: MemoryImage(bytesImage!)),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 15),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                Text(
                                  profile == null
                                      ? ""
                                      : (profile as Profile).employeecode ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  // profile['employeeprefix'].toString() +
                                  profile == null
                                      ? ""
                                      : ("${(profile as Profile).employeename} ${(profile as Profile).employeesurname}"),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ])),
                Column(
                  children: [
                    const SizedBox(height: 200),
                    buildMain(),
                    const SizedBox(height: 15),
                  ],
                )
              ],
            ),
      //),
    );
  }

  Expanded buildMain() {
    List<Widget> homeMenu = [];

    homeMenu.add(createIconMenu(
        caption: UtilService.getTextFromLang("timehistory", "ประวัติลงเวลา"),
        icon: Icons.history,
        ontab: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Calendar2Page(
                    profile: profile,
                  )));
        }));

    homeMenu.add(createIconMenu(
        caption: UtilService.getTextFromLang("absentquota", "สิทธิ์ลางาน"),
        icon: Icons.airplane_ticket_outlined,
        ontab: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AbsentsQuotaPage(
                    profile: (profile as Profile),
                  )));
        }));
    if (profile!.isApprover ?? false) {
      homeMenu.add(createIconMenu(
          caption: UtilService.getTextFromLang("approval", 'อนุมัติคำขอ'),
          icon: Icons.check,
          ontab: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ApproverPage(
                      profile: profile!,
                    )));
          }));
    }

    homeMenu.add(createIconMenu(
        caption: UtilService.getTextFromLang("document", "เอกสาร"),
        icon: Icons.receipt_long,
        ontab: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ReportPage(
                    profile: profile!,
                  )));
        }));

    homeMenu.add(createIconMenu(
        caption: UtilService.getTextFromLang("notify", "แจ้งเตือน"),
        // icon: Badge(
        //   badgeColor: Colors.blue,
        //   badgeContent: Text(
        //     '3',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   child: Icon(Icons.account_balance_wallet, color: Colors.grey),
        // ),
        icon: Icons.notifications_none_outlined,
        ontab: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NotificationPage(
                    profile: profile!,
                  )));
        }));

    homeMenu.add(createIconMenu(
        caption: UtilService.getTextFromLang("profile", 'ข้อมูลส่วนตัว'),
        icon: Icons.account_circle,
        ontab: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfilePage(
                    profile: profile!,
                  )));
        }));

    homeMenu.add(createIconMenu(
        caption: UtilService.getTextFromLang("setting", "ตั้งค่า"),
        icon: Icons.settings, //cached,
        ontab: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SettingScreen(
                    profile: profile!,
                  )));
        }));

    return Expanded(
        child: Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white, // Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Column(
            children: <Widget>[
              kIsWeb || profile!.passcode == appstorePasscode
                  ? Container()
                  : TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          // onPressed: () => {getCurrentLocation()},
                          onPressed: () async {
                            Position? position =
                                await UtilService.getCurrentLocation(profile);

                            if (position != null) {
                              // Navigator.of(context)
                              //     .push(MaterialPageRoute(
                              //         builder: (context) => MapViewPage(
                              //             lat: position.latitude,
                              //             lng: position.longitude)))
                              //     .then((value) {});
                            }
                          },
                          icon: const Icon(Icons.pin_drop),
                          padding: const EdgeInsets.only(left: 15),
                        ),
                        // const SizedBox(width: 5),
                        border: InputBorder.none,
                        hintText: currentLocationName.isEmpty
                            ? ' Loading...'
                            : ' $currentLocationName',
                        hintStyle:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
              const SizedBox(height: 10),
              Expanded(
                  child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(5),
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                crossAxisCount: 3,
                children: homeMenu,
              )),
              // ),
            ],
          ),
        ),
      ),
    ));
  }

  // Widget notificationBadge() {
  //   return Badge(
  //     position: BadgePosition.topEnd(top: 0, end: 3),
  //     animationDuration: Duration(milliseconds: 300),
  //     animationType: BadgeAnimationType.slide,
  //     badgeContent: Text(
  //       _counter.toString(),
  //       style: TextStyle(color: Colors.white),
  //     ),
  //     child: IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
  //   );
  // }

  GestureDetector createIconMenu(
      {String? caption, IconData? icon, void Function()? ontab}) {
    return GestureDetector(
      onTap: ontab,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.2),
          //     spreadRadius: 2,
          //     blurRadius: 2,
          //     offset: const Offset(1, 1), // changes position of shadow
          //   ),
          // ],
        ),
        padding: const EdgeInsets.all(1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.orange[500],
              size: 40,
            ), // icon

            Text(
              caption ?? "",
              style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ), // text
          ],
        ),
      ),
    );
  }

  Future<Alert> logoutDialog(BuildContext context) async {
    return Alert(
      context: context,
      type: AlertType.warning,
      title: "We check",
      desc: "ต้องการออกจากระบบ",
      buttons: [
        DialogButton(
          onPressed: () async {
            if (await UtilService.clearToken()) {
              Navigator.pushNamedAndRemoveUntil(
                  context, Register.id, (route) => false);
            }
          },
          gradient: const LinearGradient(colors: [
            Colors.deepOrangeAccent,
            Colors.deepOrangeAccent,
          ]),
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          gradient: const LinearGradient(colors: [
            Colors.black,
            Colors.black,
          ]),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    );
  }

  Future<bool> onBackPressed() async {
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
}
