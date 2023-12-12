import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/oTRequest.dart';
import '../../models/profile.dart';
import '../../services/delete_my_ot_request_service.dart';
import '../../pages/OT/new_ot_page.dart';
import '../../services/get_my_ot_request.dart';
import '../../services/get_attach_file_service.dart';
import '../../services/util_service.dart';
import 'dart:convert' as convert;
import '../../widgets/date_range_input_widget.dart';

class RequestOTMyPage extends StatefulWidget {
  final Profile profile;

  const RequestOTMyPage({Key? key, required this.profile}) : super(key: key);
  @override
  RequestOTMyPageState createState() => RequestOTMyPageState();
}

class RequestOTMyPageState extends State<RequestOTMyPage> {
  DateTime? startdate;
  DateTime? enddate;
  bool isLoading = false;
  bool isUseAttachFile = false;

  List<MyOTRequest> otRequestList = [];
  List<int> selectedId = [];

  var selectedMonths = 1;
  List months = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.'
  ];

  // DateTime start = DateTime.now().add(const Duration(days: -30));
  // DateTime end = DateTime.now().add(const Duration(days: 30));
  final filterDate = DateRangeInputWidget(
      name: "selectDate",
      initial_start: DateTime.now().add(const Duration(days: -30)),
      initial_end: DateTime.now().add(const Duration(days: 30)),
      errorText: 'กรอกช่วงวันที่');

  Future<List<MyOTRequest>> getMyOTRequest() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    GetMyOTRequest getMyOTRequest = GetMyOTRequest();
    otRequestList = await getMyOTRequest.getMyOTRequest(
        profile: widget.profile,
        startdate: filterDate.start,
        enddate: filterDate.end);
    if (mounted) {
      setState(() {
        isLoading = false;
        otRequestList = otRequestList.reversed.toList();
      });
    } else {
      alertEmpty('ไม่สามารถติดต่อกับเซิร์ฟเวอร์');
    }

    return otRequestList;
  }

  calculateDateRange() {
    DateTime today = DateTime.now();
    startdate = DateTime(today.year, today.month - selectedMonths, 1);
    enddate = DateTime(today.year, today.month + selectedMonths + 1, 0);
  }

  @override
  void initState() {
    super.initState();
    // Check flag

    if (widget.profile.isUseAttachFile != null) {
      isUseAttachFile = widget.profile.isUseAttachFile ?? false;
    }

    initPrefs();

    // calculateDateRange();
  }

  initPrefs() async {
    otRequestList = await getMyOTRequest();
    setState(() {
      otRequestList = otRequestList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(UtilService.getTextFromLang("duringdate", "ช่วงวันที่")),
              SizedBox(
                  // color: Colors.grey,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: filterDate),
              ElevatedButton.icon(
                  onPressed: () => getMyOTRequest(),
                  icon: const Icon(Icons.search),
                  label: Text(UtilService.getTextFromLang("search", "ค้นหา"))),
              // Expanded(
              //   child: createIntervalButton('1 เดือน', 1),
              // ),
              // SizedBox(width: 5.0,),
              // Expanded(
              //   child: createIntervalButton('3 เดือน', 3),
              // ),
              // SizedBox(width: 5.0,),
              // Expanded(
              //   child: createIntervalButton('6 เดือน', 6),
              // ),
            ],
          ),
          // Text(
          //   months[startdate.month - 1] +
          //       ' ' +
          //       startdate.year.toString() +
          //       " - " +
          //       months[enddate.month - 1] +
          //       ' ' +
          //       enddate.year.toString(),
          //   style: TextStyle(
          //     fontSize: 17.0,
          //   ),
          // ),
          buildTable(),
          buildBottomButton(context),
        ],
      ),
    );
  }

  Container buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWidget(
            title: UtilService.getTextFromLang("createrequest", "สร้างคำขอ"),
            onPressed: openNewOtPage,
            color: const Color(0xFFFF8101),
            icon: Icons.arrow_circle_up_rounded,
          ),
          const SizedBox(width: 20),
          ButtonWidget(
            title: UtilService.getTextFromLang("cancelrequest", "ยกเลิกคำขอ"),
            onPressed: () {
              if (selectedId.isEmpty) {
                alertEmpty(UtilService.getTextFromLang(
                    "please_select_list", "โปรดเลือกรายการ"));
                return;
              }
              onCancelSelected();
            },
            color: Colors.black,
            icon: Icons.arrow_circle_down_rounded,
          ),
        ],
      ),
    );
  }

  Expanded buildTable() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  // borderRadius: BorderRadius.circular(20),
                ),
                child: otRequestList.isEmpty
                    ? Container()
                    : ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                        itemCount: otRequestList.length,
                        itemBuilder: (BuildContext context, int index) {
                          MyOTRequest itemRow = otRequestList[index];
                          bool selected =
                              selectedId.contains(itemRow.otrequestid);
                          final GlobalKey remarkLocationKey = GlobalKey();

                          Color bgColor = Colors.white;
                          if (itemRow.statusid == 6000002) {
                            bgColor = const Color(0xFFBECFDE).withOpacity(0.5);
                          } else if (itemRow.statusid == 6000003) {
                            bgColor = const Color(0xFFBECFDE).withOpacity(0.5);
                          } else if (selected) {
                            bgColor = Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.08);
                          }
                          return Container(
                            color: bgColor,
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.all(0),
                              value: selected,
                              onChanged: itemRow.statusid == 6000001
                                  ? (bool? selected) {
                                      onSelectedRow(selected ?? false, itemRow);
                                    }
                                  : null,
                              title: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(UtilService.getTextFromLang(
                                            "approver", "ผู้อนุมัติ")),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(itemRow.approvername ?? ""),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(UtilService.getStatusName(
                                            itemRow.statusid)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(UtilService.getTextFromLang(
                                            "start", "เริ่ม")),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            '${itemRow.getStartdate()} ${itemRow.getStarttime()}'),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            // InkWell(
                                            //   key: _remarkLocationKey,
                                            //   onTap: itemRow.hasRemark ?? false
                                            //       ? () => showAlert(
                                            //           _remarkLocationKey,
                                            //           itemRow.remark ?? "")
                                            //       : null,
                                            //   child: Icon(
                                            //     Icons.comment,
                                            //     color:
                                            //         itemRow.hasRemark ?? false
                                            //             ? Colors.orange
                                            //             : Colors.grey,
                                            //   ),
                                            // ),
                                            InkWell(
                                              onTap: isUseAttachFile &&
                                                      (itemRow.hasAttachFile ??
                                                          false)
                                                  ? () => downloadAttachFile(
                                                      itemRow)
                                                  : null,
                                              child: Icon(
                                                Icons.attach_email,
                                                color: isUseAttachFile &&
                                                        (itemRow.hasAttachFile ??
                                                            false)
                                                    ? Colors.orange
                                                    : Colors.grey,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: itemRow.statusid == 6000001
                                                  ? () => openNewOtPage(
                                                      otRequest: itemRow)
                                                  : null,
                                              child: Icon(
                                                Icons.edit,
                                                color:
                                                    itemRow.statusid == 6000001
                                                        ? Colors.orange
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(UtilService.getTextFromLang(
                                            "end", "สิ้นสุด")),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                            '${itemRow.getEnddate()} ${itemRow.getEndtime()}'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
    );
  }

  changeDateRange(int month) {
    setState(() {
      selectedMonths = month;
      calculateDateRange();
    });
    getMyOTRequest();
  }

  TextButton createIntervalButton(String text, int month) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: selectedMonths == month
            ? const Color(0xFFFF8101)
            : Colors.grey[300],
      ),
      onPressed: () {
        if (selectedMonths != month) {
          changeDateRange(month);
        }
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17.0,
          color: selectedMonths == month ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  openNewOtPage({MyOTRequest? otRequest}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => NewOTPage(
                  profile: widget.profile,
                  myOtRequest: otRequest,
                )))
        .then((value) {
      getMyOTRequest();
    });
  }

  void onSelectedRow(bool selected, MyOTRequest itemRow) {
    setState(() {
      if (selected) {
        selectedId.add(itemRow.otrequestid!);
        print(selectedId);
      } else {
        selectedId.removeWhere((id) => id == itemRow.otrequestid);
        print(selectedId);
      }
    });
  }

  void onCancelSelected() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "We check",
      desc: "ต้องการยกเลิกรายการที่เลือก",
      buttons: [
        DialogButton(
          onPressed: () {
            deleteSelected();
          },
          gradient: const LinearGradient(colors: [
            Colors.deepOrangeAccent,
            Colors.deepOrangeAccent,
          ]),
          child: Text(
            UtilService.getTextFromLang("ok", "ตกลง"),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          gradient: const LinearGradient(colors: [
            Colors.black,
            Colors.black,
          ]),
          child: Text(
            UtilService.getTextFromLang("close", "ปิด"),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  deleteSelected() async {
    DeleteMyOTRequestService deleteMyOTRequestService =
        DeleteMyOTRequestService();
    bool res = await deleteMyOTRequestService.deleteMyOTRequest(
        profile: widget.profile, listRequest: selectedId);
    if (res) {
      // Clear IDs
      selectedId = [];
    }
    Navigator.pop(context);
    getMyOTRequest();
  }

  alertEmpty(title) {
    Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: AlertType.warning,
      title: title,
      buttons: [
        DialogButton(
          color: const Color(0xFFFF8101),
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  // showAlert(GlobalKey locationKey, String title) {
  //   RenderBox renderBox = locationKey.currentContext.findRenderObject();
  //   var offset = renderBox.localToGlobal(Offset.zero);
  //   Rect rect = Rect.fromLTWH(
  //       offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  //   showMenu(
  //     context: context,
  //     position:
  //         RelativeRect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom),
  //     items: [
  //       PopupMenuItem(
  //         child: Text(title),
  //         value: 1,
  //       ),
  //     ],
  //   );
  // }

  downloadAttachFile(MyOTRequest otRequest) async {
    var payload = convert.jsonEncode({
      "companyname": widget.profile.companyname,
      "employeeid": widget.profile.employeeid,
      "requesttype": "OT",
      "requestid": otRequest.otrequestid,
    });
    print(payload);
    showAlertLoading(context);
    GetAttachFileService getAttachFileService = GetAttachFileService();
    await getAttachFileService.getAttachFile(widget.profile, payload, context);
  }

  showAlertLoading(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            width: 10,
          ),
          Container(
              margin: const EdgeInsets.only(left: 5),
              child: const Text("กำลังส่งคำขอ")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.icon,
    required this.color,
  }) : super(key: key);
  final String title;
  final void Function()? onPressed;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon) : const Text(''),
        label: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }
}
