// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:wecheck/screens/scan_screen.dart';
import 'package:wecheck/screens/scan_screen2.dart';
import '../screens/ot_screen.dart';
import '../screens/absent_screen.dart';
import '../screens/home_screen.dart';
import '../screens/swap_shift_screen.dart';
import '../services/util_service.dart';

class Dashboard extends StatefulWidget {
  static const id = '';
  const Dashboard({Key? key, int? tabIndex}) : super(key: key);

  @override
  _DashboarddState createState() => _DashboarddState();
}

class _DashboarddState extends State<Dashboard> with WidgetsBindingObserver {
  int selectedIndex = 0;
  var pages = [
    const HomeScreen(
      notifyParent: null,
    ),
    const OTScreen(),
    const ScanScreen(),
    const AbsentScreen(),
    //const SwapWorkShiftScreen(),
    const ScanScreen2(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initPrefs();
    super.initState();
  }

  initPrefs() async {
    //await document.documentElement!.requestFullscreen();
  }

  @override
  void dispose() {
    //WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  HomeScreen NewHomeScreen() {
    return HomeScreen(notifyParent: Refresh);
  }

  Refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UtilService().validateToken(context);
    UtilService().validateSession(context);
    return WillPopScope(
        onWillPop: onBackPressed,
        child: SafeArea(
          child: Scaffold(
            // backgroundColor: Banking_app_Background,
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: UtilService.getTextFromLang("home", 'หน้าแรก'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timelapse_sharp),
                  label: UtilService.getTextFromLang("ot", 'โอที'), //'โอที',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wifi_tethering),
                  label: UtilService.getTextFromLang(
                      "menu_checkin", 'ลงเวลา'), //'ลงเวลา',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.disabled_by_default),
                  label:
                      UtilService.getTextFromLang("absent", 'ลางาน'), //'ลางาน',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cached_outlined),
                  label: UtilService.getTextFromLang(
                      "changeshift", 'เปลี่ยนกะ'), //'เปลี่ยนกะ',
                ),
              ],
              selectedItemColor: Colors.amber[800],
              currentIndex: selectedIndex,
              // unselectedIconTheme:
              //     IconThemeData(color: colorBlack.withOpacity(0.5), size: 28),
              // selectedIconTheme: IconThemeData(color: colorOrange1, size: 28),
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),

            body: SafeArea(
              child:
                  selectedIndex == 0 ? NewHomeScreen() : pages[selectedIndex],
            ),
          ),
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<bool> onBackPressed() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UtilService.getTextFromLang("confirm", 'แน่ใจหรือไม่?')),
        content: Text(UtilService.getTextFromLang(
            "question_exit_app", 'คุณต้องการออกจากแอพนี้?')),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);

              //MoveToBackground.moveTaskToBack();
            },
            icon: const Icon(Icons.check),
            label: Text(UtilService.getTextFromLang("yes", 'ใช่')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            icon: const Icon(Icons.close_sharp),
            label: Text(UtilService.getTextFromLang("no", 'ไม่')),
          ),
        ],
      ),
    );

    return result;
  }
}
