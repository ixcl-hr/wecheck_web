// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../screens/absent_screen.dart';
import '../screens/ot_screen.dart';
import '../services/util_service.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../widgets/date_range_input_widget.dart';

class NotificationScreen extends StatefulWidget {
  static String id = 'Notification';

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  Profile? profile;

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
    profile = (await UtilService.getProfile())!;
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
            profile: profile!,
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFF8101),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            onPressed: () {
              // getNotification(interval);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        title: const Text(
          'แจ้งเตือน',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: createModeButton('ทั้งหมด', Icons.all_inbox, 0),
                ),
                const SizedBox(
                  width: 3.0,
                ),
                Expanded(
                  child: createModeButton('โอที', Icons.timer, 1),
                ),
                const SizedBox(
                  width: 3.0,
                ),
                Expanded(
                  child: createModeButton('ลางาน', Icons.calendar_today, 2),
                ),
                const SizedBox(
                  width: 3.0,
                ),
                Expanded(
                  child: createModeButton('ปรับเวลา', Icons.settings, 3),
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
                const Text("ช่วงวันที่ "),
                SizedBox(
                    // color: Colors.grey,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: filterDate),
                ElevatedButton.icon(
                    onPressed: () => getNotification(),
                    icon: const Icon(Icons.search),
                    label: const Text("ค้นหา")),
                // TextButton.icon(
                //     onPressed: () => getNotification(),
                //     icon: Icon(Icons.search),
                //     label: Text("ค้นหา")),

                // Text("ค้นหาตามช่วง "),
                // Container(
                //   width: MediaQuery.of(context).size.width * 0.35,
                //   child: DateInputWidget(
                //     name: "startdate",
                //     initialValue: null,
                //     errorText: 'กรอกวันเริ่ม',
                //   ),
                // ),
                // Text("-"),
                // Container(
                //   width: MediaQuery.of(context).size.width * 0.35,
                //   child: DateInputWidget(
                //     name: "enddate",
                //     initialValue: null,
                //     errorText: 'กรอกวันสิ้นสุด',
                //   ),
                // ),

                // Expanded(
                //   child: createIntervalButton('1 เดือน', 1),
                // ),
                // SizedBox(
                //   width: 5.0,
                // ),
                // Expanded(
                //   child: createIntervalButton('3 เดือน', 3),
                // ),
                // SizedBox(
                //   width: 5.0,
                // ),
                // Expanded(
                //   child: createIntervalButton('6 เดือน', 6),
                // ),
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
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: ElevatedButton(
            //     child: Container(
            //       padding: EdgeInsets.symmetric(
            //         horizontal: 30.0,
            //       ),
            //       child: Text(
            //         'กลับ',
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.w400,
            //         ),
            //       ),
            //     ),
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     style: ElevatedButton.styleFrom(
            //       primary: Color(0xFFFF8101),
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            //       onPrimary: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30.0),
            //       ),
            //     ),
            //   ),
            // ),
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
      child: Container(
        child: Column(
          children: [
            Icon(
              icon,
              size: 40.0,
              color:
                  modeIndex == index ? Colors.white : const Color(0xFFFF8101),
            ),
            const SizedBox(
              height: 2.0,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                color: modeIndex == index ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
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
        String linkPageName;
        if (obj.type == 'AOT' || obj.type == 'AAS' || obj.type == 'AAJ') {
          //return;
          linkPageName = 'อนุมัติคำขอ';
        } else if (obj.type == 'ROT') {
          linkPageName = 'ขอทำโอที';
        } else if (obj.type == 'RAS') {
          linkPageName = 'ขอลางาน';
        } else if (obj.type == 'RAJ') {
          linkPageName = 'ขอปรับเวลา';
        } else {
          return;
        }
        AlertDialog alert = AlertDialog(
          content: Text('ต้องการไปยังหน้า \"$linkPageName\" หรือไม่'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (obj.type == 'AAJ') {
                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestOTPage(profile: widget.profile)));
                } else if (obj.type == 'AOT') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const OTScreen(initialTabIndex: 1)));
                } else if (obj.type == 'AAS') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AbsentScreen(
                            initialTabIndex: 1,
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
              child: const Text('ยืนยัน'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
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
      typeText = 'มีคำขออนุมัติทำโอที';
    } else if (obj.type == 'AAS') {
      typeText = 'มีคำขออนุมัติลาป่วย';
    } else if (obj.type == 'AAJ') {
      typeText = 'มีคำขออนุมัติปรับเวลา';
    } else {
      typeText = 'ไม่สามารถอ่านประเภทคำขออนุมัติได้';
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
      typeText = 'แจ้งผลคำขอทำโอที';
    } else if (obj.type == 'RAS') {
      typeText = 'แจ้งผลคำขอลาป่วย';
    } else {
      typeText = 'อ่านประเภทผลคำขอได้';
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
