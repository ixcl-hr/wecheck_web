import 'package:flutter/material.dart';
import '../../models/profile.dart';
import '../../models/SwapShiftRequest.dart';
import '../../pages/SwapShift/new_workshift_page.dart';
import '../../services/util_service.dart';

class NewSwapShiftPage extends StatefulWidget {
  final Profile profile;
  final SwapShiftRequest? myRequest;
  const NewSwapShiftPage({Key? key, required this.profile, this.myRequest})
      : super(key: key);

  @override
  NewSwapShiftPageState createState() => NewSwapShiftPageState();
}

class NewSwapShiftPageState extends State<NewSwapShiftPage> {
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
      length: 1, //widget.myRequest == null ? 2 : 1,
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
            tabs: widget.myRequest == null
                ? const [
                    Tab(
                      text: "",
                      //icon: Icon(Icons.mark_chat_read),
                    ),
                    // Tab(
                    //   text: "คำขอหลายวัน",
                    //   //icon: Icon(Icons.mark_chat_unread),
                    // ),
                  ]
                : [
                    Tab(
                      text: UtilService.getTextFromLang(
                          "edit_request", 'แก้ไขคำขอ'),
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
            UtilService.getTextFromLang("shift", 'ขอเปลี่ยนกะ'),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: widget.myRequest == null
              ? TabBarView(
                  children: [
                    NewWorkShiftPage(
                      profile: widget.profile,
                      myRequest: widget.myRequest,
                    ),
                    // NewOTMultiplePage(
                    //   profile: widget.profile,
                    //   myOtRequest: widget.myOtRequest,
                    // ),
                  ],
                )
              : NewWorkShiftPage(
                  profile: widget.profile,
                  myRequest: widget.myRequest,
                ),
        ),
      ),
    )));
  }
}
