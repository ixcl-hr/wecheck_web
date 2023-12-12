import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../pages/OT/request_ot_approve_page.dart';
import '../services/util_service.dart';
import '../pages/OT/request_ot_my_page.dart';
// import '../pages/OT/request_ot_approve_page.dart';

class OTScreen extends StatefulWidget {
  static String id = 'OT';
  final int initialTabIndex;

  const OTScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  OTScreenState createState() => OTScreenState();
}

class OTScreenState extends State<OTScreen> {
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
                // bottom: TabBar(
                //   indicatorWeight: 5.0,
                //   indicatorColor: Colors.white,
                //   unselectedLabelColor: Colors.black87,
                //   labelColor: Colors.white,
                //   labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                //   unselectedLabelStyle:
                //       const TextStyle(color: Colors.black87, fontSize: 16),
                //   onTap: (index) {
                //     print("index: ${index}");
                //   },
                //   tabs: const [
                //     Tab(
                //       text: "ขอทำโอที",
                //       icon: Icon(Icons.mark_chat_read),
                //     ),
                //     Tab(
                //       text: "คำร้องขอโอที",
                //       icon: Icon(Icons.mark_chat_unread),
                //     ),
                //   ],
                // ),
                backgroundColor: const Color(0xFFFF8101),
                // leading: IconButton(
                //   icon: Icon(
                //     Icons.arrow_back_ios,
                //     color: Colors.white,
                //   ),
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                // ),
                title: Text(
                  UtilService.getTextFromLang("ot", "โอที"),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
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
                        : RequestOTMyPage(profile: profile!),
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
