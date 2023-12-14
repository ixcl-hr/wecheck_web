import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/oTRequest.dart';
import '../../models/profile.dart';
import '../../models/SwapShiftRequest.dart';
import '../../pages/SwapShift/new_workshift_page.dart';
import '../../services/delete_my_swap_shift_request_service.dart';
import '../../services/get_attach_file_service.dart';
import '../../services/get_my_swap_shift_request.dart';
import '../../services/util_service.dart';
import 'dart:convert' as convert;
import '../../widgets/date_range_input_widget.dart';

class RequestSwapShiftMyPage extends StatefulWidget {
  final Profile profile;

  const RequestSwapShiftMyPage({Key? key, required this.profile})
      : super(key: key);
  @override
  RequestSwapShiftMyPageState createState() => RequestSwapShiftMyPageState();
}

class RequestSwapShiftMyPageState extends State<RequestSwapShiftMyPage> {
  DateTime? startdate;
  DateTime? enddate;
  bool isLoading = false;
  bool isUseAttachFile = false;

  List<SwapShiftRequest> wsRequestList = [];
  List<int> selectedId = [];

  var selectedMonths = 1;
  // List months = [
  //   'ม.ค.',
  //   'ก.พ.',
  //   'มี.ค.',
  //   'เม.ย.',
  //   'พ.ค.',
  //   'มิ.ย.',
  //   'ก.ค.',
  //   'ส.ค.',
  //   'ก.ย.',
  //   'ต.ค.',
  //   'พ.ย.',
  //   'ธ.ค.'
  // ];

  // DateTime start = DateTime.now().add(const Duration(days: -30));
  // DateTime end = DateTime.now().add(const Duration(days: 30));
  final filterDate = DateRangeInputWidget(
      name: "selectDate",
      initial_start: DateTime.now().add(const Duration(days: -30)),
      initial_end: DateTime.now().add(const Duration(days: 30)),
      errorText: 'กรอกช่วงวันที่');

  Future<List<SwapShiftRequest>> getMyRequest() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    GetMySwapShiftRequestService getMyRequest = GetMySwapShiftRequestService();
    wsRequestList = (await getMyRequest.GetMySwapShiftRequest(
        profile: widget.profile,
        Viewer: "REQ",
        startdate: filterDate.start,
        enddate: filterDate.end));
    if (mounted) {
      setState(() {
        isLoading = false;
        wsRequestList = wsRequestList.reversed.toList();
      });
    } else {
      alertEmpty('ไม่สามารถติดต่อกับเซิร์ฟเวอร์');
    }

    return wsRequestList;
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
    wsRequestList = await getMyRequest();
    setState(() {
      wsRequestList = wsRequestList;
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
                  onPressed: () => getMyRequest(),
                  icon: const Icon(Icons.search),
                  label: Text(UtilService.getTextFromLang("search", "ค้นหา"))),
            ],
          ),
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
            onPressed: openNewWorkShiftPage,
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
                child: wsRequestList.isEmpty
                    ? Container()
                    : ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                        itemCount: wsRequestList.length,
                        itemBuilder: (BuildContext context, int index) {
                          SwapShiftRequest itemRow = wsRequestList[index];
                          bool selected =
                              selectedId.contains(itemRow.emp_workshift_id);
                          final GlobalKey remarkLocationKey = GlobalKey();

                          Color bgColor = Colors.white;
                          if (itemRow.status_id == 8600001) {
                            bgColor = const Color(0xFFBECFDE).withOpacity(0.5);
                          } else if (itemRow.status_id == 8600001) {
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
                              onChanged: itemRow.status_id == 8600001
                                  ? (bool? selected) {
                                      onSelectedRow(selected ?? false, itemRow);
                                    }
                                  : null,
                              title: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: Text('ผู้อนุมัติ'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child:
                                            Text(itemRow.approver_name ?? ""),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(UtilService.getStatusName(
                                            itemRow.status_id)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: Text('เริ่ม'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(itemRow.getStartdate()),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: itemRow.status_id ==
                                                      8600001
                                                  ? () => openNewWorkShiftPage(
                                                      wsRequest: itemRow)
                                                  : null,
                                              child: Icon(
                                                Icons.edit,
                                                color:
                                                    itemRow.status_id == 8600001
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
                                      const Expanded(
                                        flex: 1,
                                        child: Text('สิ้นสุด'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(itemRow.getEnddate()),
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
    getMyRequest();
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

  openNewWorkShiftPage({SwapShiftRequest? wsRequest}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => NewWorkShiftPage(
                  profile: widget.profile,
                  myRequest: wsRequest,
                )))
        .then((value) {
      getMyRequest();
    });
  }

  void onSelectedRow(bool selected, SwapShiftRequest itemRow) {
    setState(() {
      if (selected) {
        selectedId.add(itemRow.emp_workshift_id!);
        print(selectedId);
      } else {
        selectedId.removeWhere((id) => id == itemRow.emp_workshift_id);
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
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          gradient: const LinearGradient(colors: [
            Colors.black,
            Colors.black,
          ]),
          child: const Text(
            "ปิด",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  deleteSelected() async {
    DeleteMySwapShiftRequestService deleteMyRequestService =
        DeleteMySwapShiftRequestService();
    bool res = await deleteMyRequestService.deleteMyRequest(
        profile: widget.profile, listRequest: selectedId);
    if (res) {
      // Clear IDs
      selectedId = [];
    }
    Navigator.pop(context);
    getMyRequest();
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
