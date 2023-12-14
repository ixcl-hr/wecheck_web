import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../constants/constant.dart';
import '../../models/AbsentApproverModel.dart';
import '../../models/GetAbsentRequestModel.dart';
import '../../models/absentTypeModel.dart';
import '../../models/profile.dart';
import '../../services/convert_date_service.dart';
import '../../services/convert_status_service.dart';
import '../../services/convert_time_service.dart';
import '../../services/get_absent_approver_service.dart';
import '../../services/get_absent_request_service.dart';
import '../../services/get_absent_type_service.dart';
import '../../services/get_attach_file_service.dart';
import 'dart:convert' as convert;

import '../../services/util_service.dart';

class AbsentApprovePage extends StatefulWidget {
  final Profile profile;

  const AbsentApprovePage({Key? key, required this.profile}) : super(key: key);
  @override
  AbsentApprovePageState createState() => AbsentApprovePageState();
}

class AbsentApprovePageState extends State<AbsentApprovePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
  var timeNow = DateFormat('hh:mm').format(DateTime.now());

  DateTime selectedDate = DateTime.now();
  String date = "";
  bool isLoading = false;

  List<AbsentRequest> requestList = [];
  List<AbsentRequest> selectedRecords = [];
  List<int> selectedId = [];
  getAbsentRequest() async {
    setState(() {
      isLoading = true;
      requestList = [];
      selectedRecords = [];
    });
    GetAbsentRequestService getAbsentRequestService = GetAbsentRequestService();
    requestList =
        await getAbsentRequestService.getRequest(profile: widget.profile);

    // reversed
    if (mounted) {
      setState(() {
        isLoading = false;
        requestList = requestList.reversed.toList();
      });
    }
  }

  List<AbsentType> absentTypeList = [];
  getOTAbsentType() async {
    GetAbsentTypeService getAbsentTypeService = GetAbsentTypeService();
    absentTypeList =
        await getAbsentTypeService.getData(profile: widget.profile);
    if (mounted) {
      setState(() {
        absentTypeList = absentTypeList;
      });
    }
  }

  List<AbsentApprover> absentApproverList = [];
  getAbsentApprover() async {
    GetAbsentApproverService getAbsentApproverService =
        GetAbsentApproverService();
    absentApproverList =
        await getAbsentApproverService.getDate(profile: widget.profile);

    if (mounted) {
      setState(() {
        absentApproverList = absentApproverList;
      });
    }
  }

  @override
  void initState() {
    getAbsentRequest();
    getOTAbsentType();
    getAbsentApprover();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          buildTable(),
          buildBottomButton(context),
          const SizedBox(
            height: 10,
          )
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
            title: UtilService.getTextFromLang('Approved', 'อนุมัติ'),
            onPressed: () {
              if (selectedId.isEmpty) {
                alertEmpty(UtilService.getTextFromLang(
                    'please_select_list', 'โปรดเลือกรายการ'));
                return;
              }
              onConfirmApproveSelected();
            },
            color: const Color(0xFFFF8101),
            icon: Icons.arrow_circle_up_rounded,
          ),
          const SizedBox(width: 20),
          ButtonWidget(
            title: UtilService.getTextFromLang('unapprove', 'ไม่อนุมัติ'),
            onPressed: () {
              if (selectedId.isEmpty) {
                alertEmpty(UtilService.getTextFromLang(
                    'please_select_list', 'โปรดเลือกรายการ'));
                return;
              }
              onConfirmCancelSelected();
            },
            color: Colors.black,
            icon: Icons.arrow_circle_down_rounded,
          ),
        ],
      ),
    );
  }

  Expanded buildTable() {
    //final GlobalKey _remarkLocationKey = GlobalKey();
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20)),
                child: requestList.isEmpty
                    ? Container()
                    : Scrollbar(
                        child: ListView(
                          children: <Widget>[
                            const SizedBox(height: 10),
                            FittedBox(
                              child: DataTable(
                                showCheckboxColumn: true,
                                dataRowHeight: 200,
                                columns: const [
                                  DataColumn(label: Text('', style: kLabel)),
                                  DataColumn(
                                      label: Text('วันที่', style: kLabel)),
                                  DataColumn(
                                      label: Text('เวลา', style: kLabel)),
                                  DataColumn(
                                      label: Text('สถานะ', style: kLabel)),
                                ],
                                rows: requestList.map((itemRow) {
                                  final GlobalKey remarkLocationKey =
                                      GlobalKey();

                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<
                                        Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.08);
                                      }

                                      // if (itemRow.statusid == 6000001)
                                      //   return Colors.white38.withOpacity(0.1);
                                      if (itemRow.statusid == 6100002) {
                                        return const Color(0xFFBECFDE)
                                            .withOpacity(0.5);
                                      }
                                      if (itemRow.statusid == 6100003) {
                                        return const Color(0xFFBECFDE)
                                            .withOpacity(0.5);
                                      }
                                      return Colors.white;
                                    }),
                                    selected: selectedRecords.contains(itemRow),
                                    onSelectChanged: itemRow.statusid == 6100001
                                        ? (selected) {
                                            onSelectedRow(
                                                selected ?? false, itemRow);
                                          }
                                        : null,
                                    cells: [
                                      DataCell(Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('ประเภท',
                                              style: kDescription.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                          Text('${itemRow.employeecode}',
                                              style: kDescription.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              UtilService.getTextFromLang(
                                                  "start", "เริ่ม"),
                                              style: kDescription),
                                          Text(
                                              UtilService.getTextFromLang(
                                                  "end", "สิ้นสุด"),
                                              style: kDescription)
                                        ],
                                      )),
                                      DataCell(
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(itemRow.absenttype ?? "",
                                                  style: kDescription.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text('${itemRow.employeename}',
                                                  style: kDescription.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  ConvertDate(itemRow
                                                                  .startdate ??
                                                              "")
                                                          .getDate() ??
                                                      "",
                                                  style: kDescription),
                                              Text(
                                                  ConvertDate(itemRow.enddate ??
                                                              "")
                                                          .getDate() ??
                                                      "",
                                                  style: kDescription),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Text('', style: kDescription),
                                          const Text('', style: kDescription),
                                          Text(
                                              ConvertTime(itemRow.starttime ??
                                                          "")
                                                      .getTime() ??
                                                  "",
                                              style: kDescription),
                                          Text(
                                              ConvertTime(itemRow.endtime ?? "")
                                                      .getTime() ??
                                                  "",
                                              style: kDescription),
                                        ],
                                      )),
                                      DataCell(Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            key: remarkLocationKey,
                                            onTap: itemRow.hasRemark ?? false
                                                ? () => UtilService.showAlert(
                                                    remarkLocationKey,
                                                    context,
                                                    itemRow.remark ?? "")
                                                : null,
                                            child: Icon(
                                              Icons.comment,
                                              size: 50,
                                              color: itemRow.hasRemark ?? false
                                                  ? Colors.orange
                                                  : Colors.grey,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: itemRow.hasAttachFile ??
                                                    false
                                                ? () =>
                                                    downloadAttachFile(itemRow)
                                                : null,
                                            child: Icon(
                                              Icons.attach_email,
                                              size: 50,
                                              color:
                                                  itemRow.hasAttachFile ?? false
                                                      ? Colors.orange
                                                      : Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            ConvertAbsentStatus(
                                                        statusid:
                                                            itemRow.statusid)
                                                    .getStatusid() ??
                                                "",
                                            style: kStatus,
                                          )
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
    );
  }

  downloadAttachFile(AbsentRequest request) async {
    var payload = convert.jsonEncode({
      "companyname": widget.profile.companyname,
      "employeeid": widget.profile.employeeid,
      "requesttype": "AS",
      "requestid": request.absentrequestid,
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

  Row buildTypeAbsent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text('ประเภทลา'),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: absentTypeList == null
              ? const Text('')
              : FormBuilderDropdown(
                  name: 'absenttypeid',
                  decoration: InputDecoration(
                    labelText: 'เลือกประเภท',
                    hintText: 'เลือกประเภท',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _fbKey.currentState!.fields['absenttypeid']?.reset();
                      },
                    ),
                  ),
                  // initialValue: initialLocationKey,
                  onChanged: (value) {
                    print("select : $value");
                  },
                  items: absentTypeList.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text('${option.text}'),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "เลือกประเภท"),
                  ])),
        ),
      ],
    );
  }

  Row buildApprover(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: const Flexible(
            child: Text('ผู้อนุมัติ'),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: absentApproverList == null
              ? const Text('')
              : FormBuilderDropdown(
                  name: 'approverid',
                  decoration: InputDecoration(
                    labelText: UtilService.getTextFromLang(
                      "please_select",
                      UtilService.getTextFromLang("please_select", 'เลือกชื่อ'),
                    ),
                    hintText: UtilService.getTextFromLang(
                      "please_select",
                      UtilService.getTextFromLang("please_select", 'เลือกชื่อ'),
                    ),
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _fbKey.currentState!.fields['approverid']?.reset();
                      },
                    ),
                  ),
                  // initialValue: initialLocationKey,
                  onChanged: (value) {
                    print("select : $value");
                  },
                  items: absentApproverList.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text('${option.text}'),
                    );
                  }).toList(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: UtilService.getTextFromLang(
                          "please_select", 'เลือกชื่อ'),
                    ),
                  ])),
        ),
      ],
    );
  }

  Row buildEnd(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: const Flexible(
            child: Text('สิ้นสุด'),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: FormBuilderDateTimePicker(
            name: "enddate",
            inputType: InputType.date,
            style: const TextStyle(fontSize: 14),
            format: DateFormat("yyyy-MM-dd"),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                labelStyle: TextStyle(color: Colors.black87),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
            validator:
                FormBuilderValidators.required(errorText: 'กรอกวันสิ้นสุด'),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.30,
          child: FormBuilderDateTimePicker(
            name: "endtime",
            inputType: InputType.time,
            format: DateFormat("hh:mm"),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                labelStyle: TextStyle(color: Colors.black87),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
            validator: FormBuilderValidators.required(
                errorText: UtilService.getTextFromLang(
                    "please_select", 'กรอกเวลาเริ่ม')),
          ),
        ),
      ],
    );
  }

  Row buildStart(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Flexible(
            child: SizedBox(
              width: 40,
              child: Text(UtilService.getTextFromLang("start", "เริ่ม")),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: FormBuilderDateTimePicker(
            name: "startdate",
            inputType: InputType.date,
            style: const TextStyle(fontSize: 14),
            format: DateFormat("yyyy-MM-dd"),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                labelStyle: TextStyle(color: Colors.black87),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
            validator: FormBuilderValidators.required(
                errorText: UtilService.getTextFromLang(
                    "please_select", 'กรอกวันเริ่ม')),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.30,
          child: FormBuilderDateTimePicker(
            name: "starttime",
            inputType: InputType.time,
            format: DateFormat("hh:mm"),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                labelStyle: TextStyle(color: Colors.black87),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
            validator: FormBuilderValidators.required(
                errorText: UtilService.getTextFromLang(
                    "please_select", 'กรอกเวลาสิ้นสุด')),
          ),
        ),
      ],
    );
  }

  void onSelectedRow(bool selected, AbsentRequest itemRow) {
    setState(() {
      if (selected) {
        selectedRecords.add(itemRow);
        selectedId.add(itemRow.absentrequestid ?? -1);
        print(selectedId);
      } else {
        selectedRecords.removeWhere((record) => record == itemRow);
        selectedId.removeWhere((id) => id == itemRow.absentrequestid);
        print(selectedId);
      }
    });
  }

  void onConfirmApproveSelected() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "We check",
      desc: UtilService.getTextFromLang(
          "confirm", "ยืนยันอนุมัติลางานรายการที่เลือก"),
      buttons: [
        DialogButton(
          onPressed: () {
            onApproveSelected();
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

  onApproveSelected() async {
    GetAbsentRequestService getAbsentRequestService = GetAbsentRequestService();
    await getAbsentRequestService.onApprove(
        profile: widget.profile, listRequest: selectedId);
    Navigator.pop(context);

    getAbsentRequest();
  }

  void onConfirmCancelSelected() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "We check",
      desc: "ต้องการยกเลิกรายการลาที่เลือก",
      buttons: [
        DialogButton(
          onPressed: () {
            unApproveSelected();
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

  unApproveSelected() async {
    GetAbsentRequestService getAbsentRequestService = GetAbsentRequestService();
    await getAbsentRequestService.unApprove(
        profile: widget.profile, listRequest: selectedId);
    Navigator.pop(context);

    getAbsentRequest();
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
  final IconData? icon;
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
