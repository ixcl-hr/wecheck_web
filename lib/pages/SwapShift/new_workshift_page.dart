import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/GetWorkShiftModel.dart';
import '../../models/approver.dart';
import '../../models/profile.dart';
import '../../models/SwapShiftRequest.dart';
import '../../services/get_ot_approver_service.dart';
import '../../services/get_workshift_service.dart';
import '../../services/request_ws_service.dart';
import 'dart:convert' as convert;
import '../../services/update_swap_shift_service%20copy.dart';
import '../../services/util_service.dart';

class NewWorkShiftPage extends StatefulWidget {
  final Profile profile;
  final SwapShiftRequest? myRequest;

  const NewWorkShiftPage({
    Key? key,
    required this.profile,
    this.myRequest,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewWorkShiftPageState();
}

class NewWorkShiftPageState extends State<NewWorkShiftPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  TextEditingController attachFileController = TextEditingController();
  List<WorkShift> workShiftList = [];
  List<OTApprover> approverList = [];

  getOTApprover() async {
    GetOTApproverService approver = GetOTApproverService();
    approverList = await approver.getOTApprover(profile: widget.profile);
    setState(() {
      approverList = approverList;
    });
  }

  getWorkShiftList() async {
    GetWorkShiftService ws = GetWorkShiftService();
    workShiftList = await ws.getWorkShift(profile: widget.profile);
    setState(() {
      if (mounted) {
        workShiftList = workShiftList;
      }
    });
  }

  @override
  void initState() {
    // Check flag

    getOTApprover();
    getWorkShiftList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.myRequest != null && widget.myRequest!.start_date != null) {
      now = widget.myRequest!.startdate!;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8101),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        // title: const Text(
        //   'ขอเปลี่ยนกะ',
        //   style: TextStyle(color: Colors.white, fontSize: 20),
        // ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: FormBuilder(
                      // autovalidateMode:
                      //     AutovalidateMode.always,
                      key: _fbKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  UtilService.getTextFromLang(
                                      "start", 'วันที่เริ่ม'),
                                  textAlign: TextAlign.start),
                              const SizedBox(
                                width: 30,
                              ),
                              buildStartDate(context),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  UtilService.getTextFromLang(
                                      "end", 'วันที่สิ้นสุด'),
                                  textAlign: TextAlign.start),
                              const SizedBox(
                                width: 30,
                              ),
                              buildEndDate(context),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          workShiftList.isEmpty
                              ? Container()
                              : buildWorkShiftList(context),
                          const SizedBox(
                            height: 30,
                          ),
                          approverList.isEmpty
                              ? Container()
                              : buildApprover(context),
                          approverList.isEmpty
                              ? Container()
                              : const SizedBox(
                                  height: 30,
                                ),
                          buildRemark(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8101),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed:
                          widget.myRequest == null ? requestSwap : updateSwap,
                      child: Text(
                        widget.myRequest == null
                            ? UtilService.getTextFromLang(
                                "send_request", 'ส่งคำขอ')
                            : UtilService.getTextFromLang(
                                "edit_request", 'แก้ไข'),
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        UtilService.getTextFromLang("cancel", 'ยกเลิก'),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWorkShiftList(BuildContext context) {
    int? workshiftId;
    if (widget.myRequest != null && widget.myRequest!.workshift_id != null) {
      // Get approver id from list
      workshiftId = workShiftList
          .firstWhere((element) =>
              element.workshift_id == widget.myRequest!.workshift_id)
          // orElse: () => null)
          .workshift_id;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(UtilService.getTextFromLang("shift", 'กะงาน')),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: FormBuilderDropdown(
            initialValue: workshiftId,
            decoration: InputDecoration(
              labelText:
                  UtilService.getTextFromLang("please_select", 'กรุณาระบุ'),
              hintText:
                  UtilService.getTextFromLang("please_select", 'กรุณาระบุ'),
              suffix: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _fbKey.currentState!.fields['workshiftid']?.reset();
                },
              ),
            ),
            onChanged: (value) {
              print("select : $value");
            },
            items: workShiftList.map((option) {
              return DropdownMenuItem(
                value: option.workshift_id,
                child: Text('${option.name_th}'),
              );
            }).toList(),
            name: 'workshiftid',
            validator: FormBuilderValidators.required(
                errorText:
                    UtilService.getTextFromLang("please_select", 'เลือกชื่อ')),
          ),
        ),
      ],
    );
  }

  Widget buildStartDate(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.myRequest != null && widget.myRequest!.start_date != null) {
      now = widget.myRequest!.startdate!;
    }
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.40,
        child: FormBuilderDateTimePicker(
          initialValue: now,
          name: "startdate",
          inputType: InputType.date,
          style: const TextStyle(fontSize: 14),
          format: DateFormat("dd/MM/yyyy"),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
              labelStyle: TextStyle(color: Colors.black87),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)))),
          validator: FormBuilderValidators.required(
              errorText:
                  UtilService.getTextFromLang("please_select", 'กรุณาระบุ')),
        ));
  }

  Widget buildEndDate(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.myRequest != null && widget.myRequest!.start_date != null) {
      now = widget.myRequest!.startdate!;
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.40,
      child: FormBuilderDateTimePicker(
        initialValue: now,
        name: "enddate",
        inputType: InputType.date,
        style: const TextStyle(fontSize: 14),
        format: DateFormat("dd/MM/yyyy"),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
            labelStyle: TextStyle(color: Colors.black87),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        validator: FormBuilderValidators.required(
            errorText:
                UtilService.getTextFromLang("please_select", 'กรุณาระบุ')),
      ),
    );
  }

  Widget buildApprover(BuildContext context) {
    int? approverId;
    if (widget.myRequest != null && widget.myRequest!.approver_name != null) {
      approverId = widget.myRequest!.approve_id;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(UtilService.getTextFromLang("approver", 'ผู้อนุมัติ')),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: FormBuilderDropdown(
            initialValue: approverId,
            decoration: InputDecoration(
              labelText:
                  UtilService.getTextFromLang("please_select", 'เลือกชื่อ'),
              hintText:
                  UtilService.getTextFromLang("please_select", 'เลือกชื่อ'),
              suffix: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _fbKey.currentState!.fields['approverid']?.reset();
                },
              ),
            ),
            onChanged: (value) {
              print("select : $value");
            },
            items: approverList.map((option) {
              return DropdownMenuItem(
                value: option.key,
                child: Text('${option.text}'),
              );
            }).toList(),
            name: 'approverid',
            validator: FormBuilderValidators.required(
                errorText:
                    UtilService.getTextFromLang("please_select", 'เลือกชื่อ')),
          ),
        ),
      ],
    );
  }

  Widget buildRemark(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Text(UtilService.getTextFromLang("remark", 'หมายเหตุ')),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: FormBuilderTextField(
            initialValue:
                widget.myRequest == null ? '' : widget.myRequest!.remark,
            minLines: 1,
            maxLength: 250,
            maxLines: 2,
            name: 'remark',
            validator: FormBuilderValidators.maxLength(250),
          ),
        ),
      ],
    );
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
              child: Text(UtilService.getTextFromLang(
                  "sending_request", 'กำลังส่งคำขอ'))),
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

  Alert buildAlertError(BuildContext context, String title, String message,
      List<DialogButton> dialogButtonList,
      {AlertType alertType = AlertType.warning}) {
    return Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: alertType,
      title: title,
      desc: message,
      buttons: dialogButtonList,
    );
  }

  requestSwap() async {
    _fbKey.currentState!.save();
    if (_fbKey.currentState!.saveAndValidate()) {
      print(_fbKey.currentState!.value);
      print('on save');
      var startdate = _fbKey.currentState!.value['startdate'];
      var enddate = _fbKey.currentState!.value['enddate'];
      var workshiftid = _fbKey.currentState!.value['workshiftid'];
      var approverid = _fbKey.currentState!.value['approverid'];
      var remark = _fbKey.currentState!.value['remark'];

      if (!validateStartAndEndDateTime(startdate, enddate)) {
        buildAlertError(
            context,
            UtilService.getTextFromLang("starttime_must_be_less_than_endtime",
                'เวลาเริ่มต้นต้องน้อยกว่าเวลาสิ้นสุด'),
            '',
            [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                width: 120,
                child: Text(
                  UtilService.getTextFromLang("ok", 'ตกลง'),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ]).show();
        return;
      }

      buildAlertError(
              context,
              UtilService.getTextFromLang(
                  "question_confirm_request", 'ยืนยันส่งคำขอ'),
              '',
              [
                DialogButton(
                  onPressed: () async {
                    var payload = convert.jsonEncode({
                      "companyname": widget.profile.companyname,
                      "employeeid": widget.profile.employeeid,
                      "workshiftid": workshiftid,
                      "statusId": 8600001,
                      "startdate": DateFormat('dd/MM/yyyy').format(startdate),
                      "enddate": DateFormat('dd/MM/yyyy').format(
                          startdate), //DateFormat('dd/MM/yyyy').format(enddate),
                      "approverid": approverid,
                      "remark": remark,
                    });
                    print(payload);
                    showAlertLoading(context);
                    RequestWsService requestService = RequestWsService();
                    await requestService.RequestWs(
                        widget.profile, payload, context);
                  },
                  width: 120,
                  child: Text(
                    UtilService.getTextFromLang("confirm", "ยืนยัน"),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                DialogButton(
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                  color: Colors.black,
                  child: Text(
                    UtilService.getTextFromLang("cancel", "ยกเลิก"),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
              alertType: AlertType.none)
          .show();
    } else {
      print('on invalide');
      print(_fbKey.currentState!.value);
    }
  }

  updateSwap() async {
    _fbKey.currentState!.save();
    if (_fbKey.currentState!.saveAndValidate()) {
      print(_fbKey.currentState!.value);
      print('on update');
      var startdate = _fbKey.currentState!.value['startdate'];
      // var enddate = _fbKey.currentState!.value['enddate'];
      var enddate = _fbKey.currentState!.value['startdate'];
      var starttime = _fbKey.currentState!.value['starttime'];
      var endtime = _fbKey.currentState!.value['endtime'];
      var approverid = _fbKey.currentState!.value['approverid'];
      var remark = _fbKey.currentState!.value['remark'];

      if (!validateStartAndEndDateTime(startdate, enddate)) {
        buildAlertError(
            context,
            UtilService.getTextFromLang("starttime_must_be_less_than_endtime",
                'เวลาเริ่มต้นต้องน้อยกว่าเวลาสิ้นสุด'),
            '',
            [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                width: 120,
                child: Text(
                  UtilService.getTextFromLang("ok", 'ตกลง'),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ]).show();
        return;
      }

      buildAlertError(
              context,
              UtilService.getTextFromLang(
                  "question_confirm_request", 'ยืนยันส่งคำขอแก้ไข'),
              '',
              [
                DialogButton(
                  onPressed: () async {
                    var payload = convert.jsonEncode({
                      "companyname": widget.profile.companyname,
                      "employeeid": widget.profile.employeeid,
                      "empworkshiftid": widget.myRequest!.emp_workshift_id,
                      "startdate": DateFormat('dd/MM/yyyy').format(startdate),
                      "enddate": DateFormat('dd/MM/yyyy').format(enddate),
                      "approverid": approverid,
                      "remark": remark
                    });
                    //print("UPDATE OT:" + payload);
                    showAlertLoading(context);
                    UpdateSwapShiftService updateOTService =
                        UpdateSwapShiftService();
                    await updateOTService.UpdateSwapShift(
                        widget.profile, payload, context);
                  },
                  width: 120,
                  child: Text(
                    UtilService.getTextFromLang("confirm", 'ยืนยัน'),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                DialogButton(
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                  color: Colors.black,
                  child: Text(
                    UtilService.getTextFromLang("cancel", 'ยกเลิก'),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
              alertType: AlertType.none)
          .show();
    } else {
      print('on invalide');
      print(_fbKey.currentState!.value);
    }
  }

  bool validateStartAndEndDateTime(DateTime startdate, DateTime enddatee) {
    // DateTime startdatetime = DateTime(startdate.year, startdate.month,
    //     startdate.day, starttime.hour, starttime.minute);
    // DateTime enddatetime = DateTime(
    //     enddate.year, enddate.month, enddate.day, endtime.hour, endtime.minute);
    // return startdatetime.compareTo(enddatetime) < 0;
    return true; //ขอน้อยกว่าได้ คือ ข้ามวัน
  }
}
