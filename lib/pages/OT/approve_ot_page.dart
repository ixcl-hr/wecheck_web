import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:wecheck/services/util_service.dart';
import '../../constants/constant.dart';
import '../../models/GetOTRequestModel.dart';
import '../../models/profile.dart';
import '../../services/approve_ot_service.dart';
import '../../services/convert_status_service.dart';
import 'dart:convert' as convert;
import '../../services/convert_date_service.dart';
import '../../services/convert_time_service.dart';

class ApproveOTScreen extends StatefulWidget {
  final Profile profile;
  final List<OTRequest> selectedIdList;

  const ApproveOTScreen({
    Key? key,
    required this.profile,
    required this.selectedIdList,
  }) : super(key: key);
  @override
  _ApproveOTScreenState createState() => _ApproveOTScreenState();
}

class _ApproveOTScreenState extends State<ApproveOTScreen> {
  List<OTRequest> selectedRecords = [];
  @override
  void initState() {
    getListCheck();
    super.initState();
  }

  List<CheckList> otRequestList = [];
  getListCheck() {
    for (var element in widget.selectedIdList) {
      otRequestList.add(
        CheckList(
          otrequestid: element.otrequestid.toString(),
          checkIn: false,
          checkOut: false,
        ),
      );
    }
    for (var element in otRequestList) {
      print("${element.otrequestid} ${element.checkIn} ${element.checkOut}");
    }
  }

  checkInValue(int otrequestid) {
    print(otrequestid);
    List<CheckList> otQuery = otRequestList
        .where((element) => element.otrequestid == otrequestid.toString())
        .toList();
    return otQuery[0].checkIn;
  }

  checkOutValue(int otrequestid) {
    print(otrequestid);
    List<CheckList> otQuery = otRequestList
        .where((element) => element.otrequestid == otrequestid.toString())
        .toList();
    return otQuery[0].checkOut;
  }

  void onApproveOT() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "We check",
      desc: "ต้องการอนุมัติรายการที่เลือก",
      buttons: [
        DialogButton(
          onPressed: () async {
            print(otRequestList);
            for (var element in otRequestList) {
              print(
                  "${element.otrequestid} ${element.checkIn} ${element.checkOut}");
            }

            var jsonEncode = convert.jsonEncode(otRequestList);
            //print(jsonEncode);
            var jsonDecode = convert.jsonDecode(jsonEncode);
            //print(jsonDecode);
            ApproveOTService approveOTService = ApproveOTService();
            await approveOTService.onApproveOT(
                profile: widget.profile, listOT: jsonDecode);
            await alertCheckSuccess();
            Navigator.pop(context);
            Navigator.pop(context, 200);
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

  alertCheckSuccess() {
    return Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: AlertType.success,
      title: UtilService.getTextFromLang(
          'approve_success', 'ยืนยันการอนุมัติสำเร็จ'),
      buttons: [
        DialogButton(
          color: const Color(0xFFFF8101),
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: Text(
            UtilService.getTextFromLang('ok', "ตกลง"),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  bool checkedInAll = false;
  bool checkedOutAll = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        title: Text(
          UtilService.getTextFromLang('otrequest', 'คำร้องขอทำโอที') +
              ('${otRequestList.length}'),
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, 200);
          },
        ),
        backgroundColor: const Color(0xFFF45201),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Scrollbar(
          child: ListView(
            children: <Widget>[
              FittedBox(
                child: DataTable(
                    showCheckboxColumn: true,
                    dataRowHeight: 210,
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                UtilService.getTextFromLang(
                                    'please_select_list', 'เลือกรายการ'),
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    rows: widget.selectedIdList
                        .map(
                          (itemRow) => DataRow(
                            selected: selectedRecords.contains(itemRow),
                            // onSelectChanged: (selected) {
                            //   onSelectedRow(selected, itemRow);
                            // },
                            cells: [
                              DataCell(Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 20, 10, 10),
                                              child: Text(
                                                itemRow.otrequestid.toString(),
                                                style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          Text(
                                              UtilService.getTextFromLang(
                                                  "start", "เริ่ม"),
                                              style: kDescription),
                                          Text(
                                              UtilService.getTextFromLang(
                                                  "end", 'สิ้นสุด'),
                                              style: kDescription)
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(18.0),
                                            child: Text(
                                                itemRow.employeename ?? "",
                                                style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Text(
                                              ConvertDate(itemRow.startdate)
                                                      .getDate() ??
                                                  "",
                                              style: kDescription),
                                          Text(
                                              ConvertDate(itemRow.enddate)
                                                      .getDate() ??
                                                  "",
                                              style: kDescription),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(18.0),
                                            child:
                                                Text('', style: kDescription),
                                          ),
                                          Text(
                                              ConvertTime(itemRow.starttime)
                                                      .getTime() ??
                                                  "",
                                              style: kDescription),
                                          Text(
                                              ConvertTime(itemRow.endtime)
                                                      .getTime() ??
                                                  "",
                                              style: kDescription),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 50, 20, 0),
                                            child: Text(
                                              ConvertStatus(
                                                          statusid:
                                                              itemRow.statusid)
                                                      .getStatusid() ??
                                                  "",
                                              style: kStatus,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Flexible(
                                        child: CheckboxListTile(
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 10, 10, 10),
                                          title: Text(
                                            UtilService.getTextFromLang(
                                                'checkin_in', 'ต้องสแกนเข้า'),
                                            style:
                                                const TextStyle(fontSize: 26),
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          value: checkInValue(
                                              itemRow.otrequestid ?? -1),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              var index = otRequestList
                                                  .indexWhere((element) =>
                                                      element.otrequestid ==
                                                      itemRow.otrequestid
                                                          .toString());
                                              print('index : $index');

                                              otRequestList[index].checkIn =
                                                  value ?? false;
                                              print(itemRow.otrequestid);
                                            });
                                          },
                                          activeColor: Colors.deepOrange,
                                          checkColor: Colors.white,
                                        ),
                                      ),
                                      Flexible(
                                        child: CheckboxListTile(
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 10, 10, 10),
                                          title: Text(
                                            UtilService.getTextFromLang(
                                                'checkin_out', 'ต้องสแกนออก'),
                                            style:
                                                const TextStyle(fontSize: 26),
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          value: checkOutValue(
                                              itemRow.otrequestid ?? -1),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              var index = otRequestList
                                                  .indexWhere((element) =>
                                                      element.otrequestid ==
                                                      itemRow.otrequestid
                                                          .toString());
                                              print('index : $index');

                                              otRequestList[index].checkOut =
                                                  value ?? false;
                                              print(itemRow.otrequestid);
                                            });
                                          },
                                          activeColor: Colors.deepOrange,
                                          checkColor: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        )
                        .toList()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[300],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Flexible(
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text(
                        UtilService.getTextFromLang(
                            'checkin_in', 'ต้องสแกนเข้า\nทั้งหมด'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: checkedInAll,
                      onChanged: (bool? value) {
                        setState(() {
                          checkedInAll = value ?? false;
                          for (var element in otRequestList) {
                            element.checkIn = value ?? false;
                          }
                        });
                      },
                      activeColor: Colors.deepOrange,
                      checkColor: Colors.white,
                    ),
                  ),
                ),
                Flexible(
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(
                      UtilService.getTextFromLang(
                          'checkin_out', 'ต้องสแกนออก\nทั้งหมด'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checkedOutAll,
                    onChanged: (bool? value) {
                      setState(() {
                        checkedOutAll = value ?? false;
                        for (var element in otRequestList) {
                          element.checkOut = value ?? false;
                        }
                      });
                    },
                    activeColor: Colors.deepOrange,
                    checkColor: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                    0xFFFF8101), // Set the button's background color
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                onApproveOT();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_box_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    UtilService.getTextFromLang("confirm", "ยืนยันอนุมัติ"),
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    ); //xxxxx
  }

  Widget _buildTable(OTRequest selectedItem) {
    return Table(
      children: [
        TableRow(children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 5),
                  Text(selectedItem.otrequestid.toString(),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(UtilService.getTextFromLang("start", "เริ่ม"),
                      style: kDescription),
                  const Text('สิ้นสุด', style: kDescription)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 5),
                  Text(selectedItem.otrequestid.toString(),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(UtilService.getTextFromLang("start", 'เริ่ม'),
                      style: kDescription),
                  Text(UtilService.getTextFromLang("end", 'สิ้นสุด'),
                      style: kDescription)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 5),
                  Text(selectedItem.otrequestid.toString(),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(UtilService.getTextFromLang("start", 'เริ่ม'),
                      style: kDescription),
                  Text(UtilService.getTextFromLang("end", 'สิ้นสุด'),
                      style: kDescription)
                ],
              ),
            ],
          )
        ]),
      ],
      border: TableBorder.all(),
    );
  }
}

class CheckList {
  String otrequestid;
  bool checkIn, checkOut;

  CheckList({
    required this.otrequestid,
    required this.checkIn,
    required this.checkOut,
  });

  String convert(check) {
    if (check) return 'N';
    return 'Y';
  }

  Map toJson() => {
        'otrequestid': otrequestid,
        'isentryscan': convert(checkIn),
        'isleavescan': convert(checkOut)
      };
}
