import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../pages/OT/request_ot_approve_page.dart';
import '../pages/SwapShift/request_swap_shift_my_page.dart';
import '../services/util_service.dart';
// import '../pages/OT/request_ot_approve_page.dart';

class SwapWorkShiftScreen extends StatefulWidget {
  static String id = 'SW';
  final int initialTabIndex;

  const SwapWorkShiftScreen({Key? key, this.initialTabIndex = 0})
      : super(key: key);

  @override
  SwapWorkShiftScreenState createState() => SwapWorkShiftScreenState();
}

class SwapWorkShiftScreenState extends State<SwapWorkShiftScreen> {
  Profile? profile;

  @override
  void initState() {
    // Check flag
    initPrefs();
    super.initState();
  }

  initPrefs() async {
    profile = (await UtilService.getProfile())!;
    setState(() {
      profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex,
      length: 2,
      child: Scaffold(
        appBar: widget.initialTabIndex == 1
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFFFF8101),
                // title: const Text(
                //   'เปลี่ยน/สลับกะงาน',
                //   style: TextStyle(color: Colors.white, fontSize: 20),
                // ),
                centerTitle: true,
              ),
        body: SafeArea(
          child: profile == null
              ? const CircularProgressIndicator()
              // : RequestOTMyPage(profile: profile!),
              : TabBarView(
                  children: [
                    profile == null
                        ? Container()
                        : RequestSwapShiftMyPage(profile: profile!),
                    profile == null
                        ? Container()
                        : RequestOTApprovePage(profile: profile!),
                  ],
                ),
        ),
      ),
    );
  }
}
