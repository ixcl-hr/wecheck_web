import 'package:flutter/material.dart';
import '../../models/oTRequest.dart';
import '../../models/profile.dart';
import '../../pages/OT/new_ot_mutiple_page.dart';
import '../../pages/OT/new_ot_single_page.dart';
import '../../services/util_service.dart';

class NewOTPage extends StatefulWidget {
  final Profile profile;
  final MyOTRequest? myOtRequest;
  const NewOTPage({Key? key, required this.profile, this.myOtRequest})
      : super(key: key);

  @override
  NewOTPageState createState() => NewOTPageState();
}

class NewOTPageState extends State<NewOTPage> {
  @override
  void initState() {
    // Check flag
    initPrefs();
    super.initState();
  }

  initPrefs() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFFFF8101),
        //   leading: IconButton(
        //     icon: const Icon(
        //       Icons.arrow_back_ios,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //   ),
        //   title: const Text(
        //     'ขอทำโอที',
        //     style: TextStyle(color: Colors.white, fontSize: 20),
        //   ),
        // ),
        body: SafeArea(
            child: DefaultTabController(
      length: widget.myOtRequest == null ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          bottom: TabBar(
            indicatorPadding: EdgeInsets.zero,
            indicatorWeight: 5.0,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.black87,
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(color: Colors.black87, fontSize: 16),
            onTap: (index) {
              print("index: $index");
            },
            tabs: widget.myOtRequest == null
                ? [
                    Tab(
                      text: UtilService.getTextFromLang(
                          "request_1_day", "คำขอ 1 วัน"),
                      //icon: Icon(Icons.mark_chat_read),
                    ),
                    Tab(
                      text: UtilService.getTextFromLang(
                          "request_multiple_days", "คำขอหลายวัน"),
                      //icon: Icon(Icons.mark_chat_unread),
                    ),
                  ]
                : [
                    Tab(
                      text: UtilService.getTextFromLang(
                          "edit_request", "แก้ไขคำขอ"),
                      //icon: Icon(Icons.mark_chat_read),
                    ),
                  ],
          ),
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
            UtilService.getTextFromLang("otrequest", "ขอทำโอที"),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: widget.myOtRequest == null
              ? TabBarView(
                  children: [
                    NewOTSinglePage(
                      profile: widget.profile,
                      myOtRequest: widget.myOtRequest,
                    ),
                    NewOTMultiplePage(
                      profile: widget.profile,
                      myOtRequest: widget.myOtRequest,
                    ),
                  ],
                )
              : NewOTSinglePage(
                  profile: widget.profile,
                  myOtRequest: widget.myOtRequest,
                ),
        ),
      ),
    )));
  }
}
