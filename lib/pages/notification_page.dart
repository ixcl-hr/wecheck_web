// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../screens/absent_screen.dart';
import '../screens/ot_screen.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/util_service.dart';
import '../widgets/date_range_input_widget.dart';

class NotificationPage extends StatefulWidget {
  final Profile profile;
  const NotificationPage({Key? key, required this.profile}) : super(key: key);

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  int modeIndex = 0;
  int interval = 1;
  NotificationService notificationService = NotificationService();
  List<NotificationObject> notificationList = [];
  List<NotificationObject> originalNotificationList = [];
  bool loading = false;

  List<String> otNotificationTypeList = ['AOT', 'ROT'];
  List<String> leaveNotificationTypeList = ['AAS', 'RAS'];
  List<String> changeTimeNotificationTypeList = ['AAJ', 'RAJ'];

  @override
  void initState() {
    // Check flag
    initPrefs();

    super.initState();
  }

  initPrefs() async {
    getNotification();
  }

  final filterDate =
      DateRangeInputWidget(name: "selectDate", errorText: 'กรอกช่วงวันที่');

  getNotification() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    DateTime today = DateTime.now();
    List<NotificationObject> notificationList =
        await notificationService.getAllNotification(
            profile: widget.profile,
            startdate: filterDate.start ??
                filterDate
                    .initial_start, //DateTime(today.year, today.month - month, 1),
            enddate: filterDate.end ??
                filterDate
                    .initial_end //DateTime(today.year, today.month + month + 1, 0),
            );
    if (mounted) {
      setState(() {
        loading = false;
        originalNotificationList = notificationList;
      });
      filterNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8101),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          UtilService.getTextFromLang("notify", "แจ้งเตือน"),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 2.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: createModeButton(
                      UtilService.getTextFromLang("all", 'ทั้งหมด'),
                      Icons.all_inbox,
                      0),
                ),
                const SizedBox(
                  width: 3.0,
                ),
                Expanded(
                  child: createModeButton(
                      UtilService.getTextFromLang("ot", 'โอที'),
                      Icons.timer_outlined,
                      1),
                ),
                const SizedBox(
                  width: 3.0,
                ),
                Expanded(
                  child: createModeButton(
                      UtilService.getTextFromLang("absent", 'ลางาน'),
                      Icons.calendar_today,
                      2),
                ),
                const SizedBox(
                  width: 3.0,
                ),
                Expanded(
                  child: createModeButton(
                      UtilService.getTextFromLang("timeadjust", 'ปรับเวลา'),
                      Icons.settings,
                      3),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                // SizedBox(
                //   width: 10,
                // ),
                Text(UtilService.getTextFromLang("duringdate", 'ช่วงวันที่')),
                SizedBox(
                    // color: Colors.grey,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: filterDate),
                ElevatedButton.icon(
                    onPressed: () => getNotification(),
                    icon: const Icon(Icons.search),
                    label:
                        Text(UtilService.getTextFromLang("search", 'ค้นหา'))),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            loading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.grey,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  )
                : buildNotification(),
          ],
        ),
      ),
    );
  }

  TextButton createModeButton(String text, IconData icon, int index) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor:
            modeIndex == index ? const Color(0xFFFF8101) : Colors.grey[300],
        padding: const EdgeInsets.all(10.0),
      ),
      onPressed: () {
        if (modeIndex != index) {
          setState(() {
            modeIndex = index;
          });
        }
        filterNotification();
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 35,
            color: modeIndex == index ? Colors.white : const Color(0xFFFF8101),
          ),
          const SizedBox(
            height: 2.0,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: modeIndex == index ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  TextButton createIntervalButton(String text, int itv) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor:
            interval == itv ? const Color(0xFFFF8101) : Colors.grey[300],
      ),
      onPressed: () {
        if (interval != itv) {
          setState(() {
            interval = itv;
          });
          //getNotification(itv);
        }
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17.0,
          color: interval == itv ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget buildNotification() {
    return Expanded(
      child: Container(
        color: Colors.grey[200],
        child: Scrollbar(
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              height: 1,
              color: Colors.grey,
            ),
            scrollDirection: Axis.vertical,
            itemCount: notificationList.length,
            itemBuilder: (context, index) {
              return buildNotificationItem(notificationList[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget buildNotificationItem(NotificationObject obj) {
    TextStyle style = const TextStyle();
    Widget item = const Center();
    if (obj.type == 'AOT' || obj.type == 'AAS' || obj.type == 'AAJ') {
      item = buildRequestItem(obj, style);
    } else if (obj.type == 'ROT' || obj.type == 'RAS') {
      item = buildResultOTOrLeaveItem(obj, style);
    } else if (obj.type == 'RAJ') {
      item = buildResultTimeChangeItem(obj, style);
    }
    return InkWell(
      child: ListTile(
        leading: Icon(
          Icons.warning_rounded,
          size: 40.0,
          color: Colors.amber[500],
        ),
        title: item,
      ),
      onTap: () {
        // String linkPageName;
        // if (obj.type == 'AOT' || obj.type == 'AAS' || obj.type == 'AAJ') {
        //   //return;
        //   linkPageName = 'อนุมัติคำขอ';
        // } else if (obj.type == 'ROT') {
        //   linkPageName = 'ขอทำโอที';
        // } else if (obj.type == 'RAS') {
        //   linkPageName = 'ขอลางาน';
        // } else if (obj.type == 'RAJ') {
        //   linkPageName = 'ขอปรับเวลา';
        // } else {
        //   return;
        // }
        AlertDialog alert = AlertDialog(
          content: Text(UtilService.getTextFromLang(
              "question_open_approve_page",
              "ต้องการไปยังหน้าอนุมัติคำขอหรือไม่?")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (obj.type == 'AAJ') {
                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestOTPage(profile: widget.profile)));
                } else if (obj.type == 'AOT') {
                  Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => ApproverPage(
                      //           profile: widget.profile,
                      //         )));
                      builder: (context) =>
                          const OTScreen(initialTabIndex: 1)));
                } else if (obj.type == 'AAS') {
                  Navigator.of(context).push(MaterialPageRoute(
                      // builder: (context) => ApproverPage(
                      //       profile: widget.profile,
                      //     )));
                      builder: (context) => const AbsentScreen(
                            initialTabIndex: 1,
                            isShowLeading: true,
                          )));
                } else if (obj.type == 'ROT') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const OTScreen()));
                } else if (obj.type == 'RAS') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AbsentScreen()));
                } else if (obj.type == 'RAJ') {
                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestOTPage(profile: widget.profile)));
                }
              },
              child: Text(UtilService.getTextFromLang("confirm", "ยืนยัน")),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(UtilService.getTextFromLang("cancel", "ยกเลิก")),
            ),
          ],
        );
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            });
      },
    );
  }

  Widget buildRequestItem(NotificationObject obj, TextStyle style) {
    String typeText;
    if (obj.type == 'AOT') {
      typeText = UtilService.getTextFromLang(
          "ot_approval_request", "มีคำขออนุมัติทำโอที");
      ;
    } else if (obj.type == 'AAS') {
      typeText = UtilService.getTextFromLang(
          "absent_approval_request", "มีคำขออนุมัติลา");
    } else if (obj.type == 'AAJ') {
      typeText = UtilService.getTextFromLang(
          "adjust_approval_request", "มีคำขออนุมัติปรับเวลา");
    } else {
      typeText = UtilService.getTextFromLang("data_isnot_valid",
          "ข้อมูลไม่ถูกต้อง"); //'ไม่สามารถอ่านประเภทคำขออนุมัติได้';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Text(
          typeText,
          style: style,
        ),
        // Row(
        //   textBaseline: TextBaseline.alphabetic,
        //   crossAxisAlignment: CrossAxisAlignment.baseline,
        //   children: [
        //     Expanded(
        //       child: Text(
        //         'เวลา',
        //         style: style,
        //       ),
        //       flex: 1,
        //     ),
        //     Expanded(
        //       child: Text(
        //         obj.dateTime ?? "",
        //         style: style,
        //       ),
        //       flex: 3,
        //     ),
        //   ],
        // ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                UtilService.getTextFromLang("start", "เริ่ม"),
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${obj.startdate ?? ''} ${obj.starttime ?? ''}',
                style: style,
              ),
            ),
          ],
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                UtilService.getTextFromLang("end", "สิ้นสุด"),
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${obj.enddate ?? ''} ${obj.endtime ?? ''}',
                style: style,
              ),
            ),
          ],
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                obj.employeeCode ?? "",
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                obj.employeeName ?? "",
                style: style,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildResultOTOrLeaveItem(NotificationObject obj, TextStyle style) {
    String typeText;
    if (obj.type == 'ROT') {
      typeText = 'แจ้งผลคำขอทำโอที : ${obj.statusName ?? ""}';
    } else if (obj.type == 'RAS') {
      typeText = 'แจ้งผลคำขอลาป่วย : ${obj.statusName ?? ""}';
    } else {
      typeText = 'อ่านประเภทผลคำขอได้ : ${obj.statusName ?? ""}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Text(
          typeText,
          style: style,
        ),
        // Row(
        //   textBaseline: TextBaseline.alphabetic,
        //   crossAxisAlignment: CrossAxisAlignment.baseline,
        //   children: [
        //     Expanded(
        //       child: Text(
        //         'เวลา',
        //         style: style,
        //       ),
        //       flex: 1,
        //     ),
        //     Expanded(
        //       child: Text(
        //         obj.dateTime ?? "",
        //         style: style,
        //       ),
        //       flex: 3,
        //     ),
        //   ],
        // ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'เริ่ม',
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${obj.startdate ?? ''} ${obj.starttime ?? ''}',
                style: style,
              ),
            ),
          ],
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'สิ้นสุด',
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${obj.enddate ?? ''} ${obj.endtime ?? ''}',
                style: style,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildResultTimeChangeItem(NotificationObject obj, TextStyle style) {
    String typeText;
    if (obj.type == 'RAJ') {
      typeText = 'แจ้งผลคำขอปรับเวลา';
    } else {
      typeText = 'ไม่สามารถอ่านประเภทคำขออนุมัติได้';
    }
    String oldStatus = 'ไม่สามารถอ่านสถานะได้';
    if (obj.oldIsactive == 'Y') {
      oldStatus = 'ใช้งาน';
    } else if (obj.oldIsactive == 'N') {
      oldStatus = 'ไม่ใช้งาน';
    }
    String newStatus = 'ไม่สามารถอ่านสถานะได้';
    if (obj.newIsactive == 'Y') {
      oldStatus = 'ใช้งาน';
    } else if (obj.newIsactive == 'N') {
      oldStatus = 'ไม่ใช้งาน';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Text(
          typeText,
          style: style,
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'เวลา',
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                obj.dateTime ?? "",
                style: style,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Text(
          'ข้อมูลเก่า',
          style: style,
        ),
        Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'สถานที่',
                  style: style,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  obj.oldLocationName ?? "",
                  style: style,
                ),
              ),
            ]),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'วัน-เวลา',
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${obj.startdate ?? ""} ${obj.starttime ?? ""}',
                style: style,
              ),
            ),
          ],
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'สถานะ',
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                oldStatus,
                style: style,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Text(
          'ข้อมูลใหม่',
          style: style,
        ),
        Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'สถานที่',
                  style: style,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  obj.newLocationName ?? "",
                  style: style,
                ),
              ),
            ]),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'วัน-เวลา',
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${obj.enddate ?? ""} ${obj.endtime ?? ""}',
                style: style,
              ),
            ),
          ],
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'สถานะ',
                style: style,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                newStatus,
                style: style,
              ),
            ),
          ],
        ),
      ],
    );
  }

  filterNotification() {
    if (mounted) {
      setState(() {
        if (modeIndex == 1) {
          notificationList = originalNotificationList
              .where((obj) => otNotificationTypeList.contains(obj.type))
              .toList();
        } else if (modeIndex == 2) {
          notificationList = originalNotificationList
              .where((obj) => leaveNotificationTypeList.contains(obj.type))
              .toList();
        } else if (modeIndex == 3) {
          notificationList = originalNotificationList
              .where((obj) => changeTimeNotificationTypeList.contains(obj.type))
              .toList();
        } else {
          notificationList = [...originalNotificationList];
        }
      });
    }
  }
}
