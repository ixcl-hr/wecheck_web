import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/approver.dart';
import '../../models/oTRequest.dart';
import '../../models/profile.dart';
import '../../services/get_ot_approver_service.dart';
import '../../services/request_ot_service.dart';
import '../../services/update_ot_service.dart';
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;

import '../../widgets/attach_file_widget.dart';
import '../../services/util_service.dart';

class NewOTSinglePage extends StatefulWidget {
  final Profile profile;
  final MyOTRequest? myOtRequest;

  const NewOTSinglePage({
    Key? key,
    required this.profile,
    this.myOtRequest,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewOTSinglePageState();
}

class NewOTSinglePageState extends State<NewOTSinglePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  TextEditingController attachFileController = TextEditingController();
  List<OTApprover> approverList = [];

  bool isUseAttachFile = false;
  File? attachedFile;

  getOTApprover() async {
    GetOTApproverService approver = GetOTApproverService();
    approverList = await approver.getOTApprover(profile: widget.profile);
    setState(() {
      approverList = approverList;
    });
  }

  @override
  void initState() {
    // Check flag

    if (widget.profile.isUseAttachFile != null) {
      isUseAttachFile = widget.profile.isUseAttachFile!;
    }
    getOTApprover();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.myOtRequest != null &&
        widget.myOtRequest!.startdatetime != null) {
      now = widget.myOtRequest!.startdatetime!;
    }

    return Scaffold(
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
              // const Text(
              //   'ขอทำโอที(1 วัน)',
              //   style: TextStyle(
              //     fontSize: 20,
              //     color: Colors.black,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
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
                                      "date", "วันที่ขอทำโอที"),
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
                                      "start", "เวลาเริ่มต้น"),
                                  textAlign: TextAlign.start),
                              const SizedBox(
                                width: 30,
                              ),
                              buildStartTime(context),
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
                                      "end", "เวลาสิ้นสุด"),
                                  textAlign: TextAlign.start),
                              const SizedBox(
                                width: 30,
                              ),
                              buildEndTime(context),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
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
                          isUseAttachFile
                              ? const SizedBox(
                                  height: 10,
                                )
                              : Container(),
                          isUseAttachFile ? buildAttachedFile() : Container(),
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
                          widget.myOtRequest == null ? requestOT : updateOT,
                      child: Text(
                        widget.myOtRequest == null
                            ? UtilService.getTextFromLang(
                                "okotrequest", "ขอทำโอที")
                            : 'แก้ไข',
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
                        UtilService.getTextFromLang("cancel", "ยกเลิก"),
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

  Widget buildStartDate(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.myOtRequest != null &&
        widget.myOtRequest!.startdatetime != null) {
      now = widget.myOtRequest!.startdatetime!;
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
        validator: FormBuilderValidators.required(errorText: 'กรอกวันเริ่ม'),
      ),
    );
  }

  Widget buildStartTime(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.myOtRequest != null &&
        widget.myOtRequest!.startdatetime != null) {
      now = widget.myOtRequest!.startdatetime!;
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.40,
      child: FormBuilderDateTimePicker(
        initialValue: now,
        name: "starttime",
        // pickerType: PickerType.cupertino,
        inputType: InputType.time,
        timePickerInitialEntryMode: TimePickerEntryMode.input,
        format: DateFormat("HH:mm"),
        textAlign: TextAlign.center,
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
    );
  }

  Widget buildEndTime(BuildContext context) {
    DateTime now = DateTime.now();
    if (widget.myOtRequest != null && widget.myOtRequest!.enddatetime != null) {
      now = widget.myOtRequest!.enddatetime!;
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.40,
      child: FormBuilderDateTimePicker(
        initialValue: now,
        name: "endtime",
        inputType: InputType.time,
        // pickerType: PickerType.cupertino,
        timePickerInitialEntryMode: TimePickerEntryMode.input,
        format: DateFormat("HH:mm"),
        textAlign: TextAlign.center,
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
    );
  }

  Widget buildApprover(BuildContext context) {
    int? approverId;
    if (widget.myOtRequest != null &&
        widget.myOtRequest!.approvername != null) {
      // Get approver id from list
      approverId = approverList
          .firstWhere(
              (element) => element.text == widget.myOtRequest!.approvername)
          // orElse: () => null)
          .key;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(UtilService.getTextFromLang("approver", "ผู้อนุมัติ")),
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
          child: Text(UtilService.getTextFromLang("remark", "หมายเหตุ")),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: FormBuilderTextField(
            initialValue:
                widget.myOtRequest == null ? '' : widget.myOtRequest!.remark,
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

  Widget buildAttachedFile() {
    return AttachFileWidget(
      attachFileController: attachFileController,
      onSelected: (file) {
        attachedFile = file;
      },
      onError: (title, desc) {
        buildAlertError(context, title, desc, [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: Text(
              UtilService.getTextFromLang("ok", "ตกลง"),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
      },
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

  requestOT() async {
    _fbKey.currentState!.save();
    if (_fbKey.currentState!.saveAndValidate()) {
      print(_fbKey.currentState!.value);
      print('on save');
      var startdate = _fbKey.currentState!.value['startdate'];
      // var enddate = _fbKey.currentState!.value['enddate'];
      var enddate = _fbKey.currentState!.value['startdate']; //ใช้วันที่เดียว
      var starttime = _fbKey.currentState!.value['starttime'];
      var endtime = _fbKey.currentState!.value['endtime'];
      var approverid = _fbKey.currentState!.value['approverid'];
      var remark = _fbKey.currentState!.value['remark'];

      if (!validateStartAndEndDateTime(
          startdate, starttime, enddate, endtime)) {
        buildAlertError(
            context,
            UtilService.getTextFromLang("starttime_must_be_less_than_endtime",
                'เวลาเริ่มต้นต้องน้อยกว่าเวลาสิ้นสุด'),
            '',
            [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                width: 120,
                child: const Text(
                  "ตกลง",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ]).show();
        return;
      }

      buildAlertError(
              context,
              UtilService.getTextFromLang(
                  "question_confirm_request", 'ยืนยันส่งคำขอทำโอที'),
              '',
              [
                DialogButton(
                  onPressed: () async {
                    String attachfiletype = '';
                    if (attachedFile != null &&
                        path.extension(attachedFile!.path).isNotEmpty) {
                      // Prevent empty extension string
                      attachfiletype =
                          path.extension(attachedFile!.path).substring(1);
                    }

                    var payload = convert.jsonEncode({
                      "companyname": widget.profile.companyname,
                      "employeeid": widget.profile.employeeid,
                      "startdate": DateFormat('dd/MM/yyyy').format(startdate),
                      "starttime": DateFormat('HH:mm').format(starttime),
                      "enddate": DateFormat('dd/MM/yyyy').format(
                          startdate), //DateFormat('dd/MM/yyyy').format(enddate),
                      "endtime": DateFormat('HH:mm').format(endtime),
                      "approverid": approverid,
                      "remark": remark,
                      "attachfile": attachedFile != null
                          ? convert
                              .base64Encode(await attachedFile!.readAsBytes())
                          : null,
                      "attachfiletype": attachfiletype,
                    });
                    print(payload);
                    showAlertLoading(context);
                    RequestOTService requestOTService = RequestOTService();
                    await requestOTService.requestOT(
                        widget.profile, payload, context);
                  },
                  width: 120,
                  child: Text(
                    UtilService.getTextFromLang("ok", "ยืนยัน"),
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

  updateOT() async {
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

      if (!validateStartAndEndDateTime(
          startdate, starttime, enddate, endtime)) {
        buildAlertError(
            context,
            UtilService.getTextFromLang("starttime_must_be_less_than_endtime",
                'เวลาเริ่มต้นต้องน้อยกว่าเวลาสิ้นสุด'),
            '',
            [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                width: 120,
                child: const Text(
                  "ตกลง",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ]).show();
        return;
      }

      if (!isStartTimeLessThanEndTime(startdate, starttime, endtime)) {
        enddate = (startdate as DateTime).add(const Duration(days: 1));
      }

      buildAlertError(
              context,
              UtilService.getTextFromLang(
                  "question_confirm_request", 'ยืนยันส่งคำขอแก้ไขโอที'),
              '',
              [
                DialogButton(
                  onPressed: () async {
                    String attachfiletype = '';
                    if (attachedFile != null &&
                        path.extension(attachedFile!.path).isNotEmpty) {
                      // Prevent empty extension string
                      attachfiletype =
                          path.extension(attachedFile!.path).substring(1);
                    }

                    var payload = convert.jsonEncode({
                      "companyname": widget.profile.companyname,
                      "employeeid": widget.profile.employeeid,
                      "otrequestid": widget.myOtRequest!.otrequestid,
                      "startdate": DateFormat('dd/MM/yyyy').format(startdate),
                      "starttime": DateFormat('HH:mm').format(starttime),
                      "enddate": DateFormat('dd/MM/yyyy').format(enddate),
                      "endtime": DateFormat('HH:mm').format(endtime),
                      "approverid": approverid,
                      "remark": remark,
                      "isupdateattachfile": attachedFile != null ? 'Y' : 'N',
                      "attachfile": attachedFile != null
                          ? convert
                              .base64Encode(await attachedFile!.readAsBytes())
                          : null,
                      "attachfiletype": attachfiletype,
                    });
                    //print("UPDATE OT:" + payload);
                    showAlertLoading(context);
                    UpdateOTService updateOTService = UpdateOTService();
                    await updateOTService.updateOT(
                        widget.profile, payload, context);
                  },
                  width: 120,
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                DialogButton(
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                  color: Colors.black,
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.white, fontSize: 20),
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

  bool validateStartAndEndDateTime(DateTime startdate, DateTime starttime,
      DateTime enddate, DateTime endtime) {
    // DateTime startdatetime = DateTime(startdate.year, startdate.month,
    //     startdate.day, starttime.hour, starttime.minute);
    // DateTime enddatetime = DateTime(
    //     enddate.year, enddate.month, enddate.day, endtime.hour, endtime.minute);
    // return startdatetime.compareTo(enddatetime) < 0;
    return true; //ขอน้อยกว่าได้ คือ ข้ามวัน
  }

  bool isStartTimeLessThanEndTime(
      DateTime startdate, DateTime starttime, DateTime endtime) {
    DateTime startdatetime = DateTime(startdate.year, startdate.month,
        startdate.day, starttime.hour, starttime.minute);
    DateTime enddatetime = DateTime(startdate.year, startdate.month,
        startdate.day, endtime.hour, endtime.minute);
    return startdatetime.compareTo(enddatetime) < 0;
  }
}
