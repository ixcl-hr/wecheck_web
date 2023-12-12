import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../pages/Absent/absent_approve_page.dart';
import '../services/util_service.dart';

// import '../pages/Absents/AbsentPage2Screen.dart';
import '../pages/Absent/absent_my_page.dart';

class AbsentScreen extends StatefulWidget {
  static String id = 'Absent';
  final int? lockAbsentType;
  final int? lockAbsentYear;
  final int initialTabIndex;
  final bool isShowLeading;

  const AbsentScreen(
      {Key? key,
      this.lockAbsentType,
      this.lockAbsentYear,
      this.initialTabIndex = 0,
      this.isShowLeading = false})
      : super(key: key);

  @override
  AbsentScreenState createState() => AbsentScreenState();
}

class AbsentScreenState extends State<AbsentScreen> {
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
        appBar: widget.initialTabIndex == 1 && !widget.isShowLeading
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
                //     print("index: $index");
                //   },
                //   tabs: const [
                //     Tab(
                //       text: "ขอลางาน",
                //       icon: Icon(Icons.mark_chat_read),
                //     ),
                //     Tab(
                //       text: "คำร้องขอลางาน",
                //       icon: Icon(Icons.mark_chat_unread),
                //     ),
                //   ],
                // ),
                backgroundColor: const Color(0xFFFF8101),
                leading: widget.isShowLeading
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    : null,
                title: Text(
                  UtilService.getTextFromLang("absent", "ลางาน"),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                centerTitle: true,
              ),
        body: SafeArea(
          child: profile == null
              ? const CircularProgressIndicator()
              : TabBarView(
                  children: [
                    AbsentMyPage(
                      profile: profile!,
                      lockAbsentType: widget.lockAbsentType,
                      lockAbsentYear: widget.lockAbsentYear,
                    ),
                    AbsentApprovePage(profile: profile!),
                  ],
                ),
        ),
      ),
    );
  }
}
