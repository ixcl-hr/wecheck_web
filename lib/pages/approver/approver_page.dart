import 'package:flutter/material.dart';
import '../../models/oTRequest.dart';
import '../../models/profile.dart';
import '../../pages/SwapShift/swap_shift_approve_page.dart';
// import '../pages/approver/absent_approve_page.dart';
import '../../screens/absent_screen.dart';
import '../../screens/ot_screen.dart';
import '../../services/util_service.dart';

class ApproverPage extends StatefulWidget {
  final Profile profile;
  final MyOTRequest? myOtRequest;
  const ApproverPage({Key? key, required this.profile, this.myOtRequest})
      : super(key: key);

  @override
  ApproverPageState createState() => ApproverPageState();
}

class ApproverPageState extends State<ApproverPage> {
  int selectedIndex = 0;

  var pages = [
    const OTScreen(initialTabIndex: 1),
    const AbsentScreen(initialTabIndex: 1),
    //AbsentApproverPage(),
    const OTScreen(initialTabIndex: 1),
  ];

  @override
  void initState() {
    initPrefs();
    super.initState();

    pages.add(SwapShiftyApprovePage(
      profile: widget.profile,
    ));
  }

  initPrefs() async {}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          bottom: TabBar(
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
            tabs: [
              Tab(
                text: UtilService.getTextFromLang("ot", 'โอที'),
                icon: const Icon(Icons.timer_outlined),
              ),
              Tab(
                text: UtilService.getTextFromLang("absent", 'ลางาน'),
                icon: const Icon(Icons.calendar_today),
              ),
              // Tab(
              //   text: "ปรับเวลา",
              //   icon: const Icon(Icons.settings),
              // ),
              // Tab(
              //   text: UtilService.getTextFromLang("shift", 'เปลี่ยนกะ'),
              //   icon: const Icon(Icons.cached_outlined),
              // ),
            ],
          ),
          backgroundColor: const Color(0xFFFF8101),
          title: Text(
            UtilService.getTextFromLang("approval", 'อนุมัติคำขอ'),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              pages[0],
              pages[1],
              // pages[2],
              // pages[3],
            ],
          ),
        ),
      ),
    );
    // double width = MediaQuery.of(context).size.width;

    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: const Color(0xFFFF8101),
    //     leading: IconButton(
    //       color: Colors.white,
    //       onPressed: () {
    //         Navigator.pop(context);
    //       },
    //       icon: const Icon(Icons.arrow_back_rounded),
    //     ),
    //     title: const Text(
    //       'อนุมัติคำขอ',
    //       style: TextStyle(color: Colors.white, fontSize: 20),
    //     ),
    //     centerTitle: true,
    //   ),
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //         const SizedBox(
    //           height: 2.0,
    //         ),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           mainAxisSize: MainAxisSize.max,
    //           children: [
    //             Expanded(
    //               child: createModeButton('โอที', Icons.timer_outlined, 0),
    //             ),
    //             const SizedBox(
    //               width: 3.0,
    //             ),
    //             Expanded(
    //               child: createModeButton('ลางาน', Icons.calendar_today, 1),
    //             ),
    //             const SizedBox(
    //               width: 3.0,
    //             ),
    //             Expanded(
    //               child: createModeButton('ปรับเวลา', Icons.settings, 2),
    //             ),
    //           ],
    //         ),
    //         const SizedBox(
    //           height: 10.0,
    //         ),
    //         pages[selectedIndex],
    //       ],
    //     ),
    //   ),
    // );
  }

  TextButton createModeButton(String text, IconData icon, int index) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor:
            selectedIndex == index ? const Color(0xFFFF8101) : Colors.grey[300],
        padding: const EdgeInsets.all(10.0),
      ),
      //onPressed: onPressed,
      onPressed: () {
        if (selectedIndex != index) {
          setState(() {
            selectedIndex = index;
          });
        }
        //filterNotification();
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 35,
            color:
                selectedIndex == index ? Colors.white : const Color(0xFFFF8101),
          ),
          const SizedBox(
            height: 2.0,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: selectedIndex == index ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
