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
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;
import '../../services/util_service.dart';

import '../../widgets/attach_file_widget.dart';

class NewOTMultiplePage extends StatefulWidget {
  final Profile profile;
  final MyOTRequest? myOtRequest;

  const NewOTMultiplePage({
    Key? key,
    required this.profile,
    this.myOtRequest,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewOTMultiplePageState();
}

class NewOTMultiplePageState extends State<NewOTMultiplePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  TextEditingController attachFileController = TextEditingController();

  List<OTApprover> approverList = [];
  List<OTPreview> otRequestList = [];

  bool isUseAttachFile = false;
  bool isLoadingPreviewList = false;
  File? attachedFile;
  DateTime ot_startdate = DateTime.now();
  DateTime ot_enddate = DateTime.now().add(const Duration(days: 1));
  DateTime ot_starttime = DateTime.now();
  DateTime ot_endtime = DateTime.now(); //.add(Duration(hours: 1));
  int? approveId;
  String remark = '';

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
              Text(
                UtilService.getTextFromLang("request_ot_sametime_multipledays",
                    'ขอทำโอที(เวลาเดียวกัน หลายๆวัน)'),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Expanded(
              //   child: SingleChildScrollView(
              // child: Container(
              Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                child: FormBuilder(
                  // autovalidateMode:
                  //     AutovalidateMode.always,
                  //key: _fbKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              UtilService.getTextFromLang(
                                  "duringdate", 'วันที่ขอทำโอที'),
                              textAlign: TextAlign.start),
                          const SizedBox(
                            width: 30,
                          ),
                          buildStartDate(context),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              UtilService.getTextFromLang(
                                  "start", 'เวลาเริ่มต้น'),
                              textAlign: TextAlign.start),
                          const SizedBox(
                            width: 30,
                          ),
                          buildStartTime(context),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              UtilService.getTextFromLang("end", 'เวลาสิ้นสุด'),
                              textAlign: TextAlign.start),
                          const SizedBox(
                            width: 30,
                          ),
                          buildEndTime(context),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      approverList.isEmpty
                          ? Container()
                          : buildApprover(context),
                      approverList.isEmpty
                          ? Container()
                          : const SizedBox(
                              height: 10,
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
              //   ),
              // ),
              buildListPreview(),
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
                      onPressed: requestOT,
                      child: Text(
                        UtilService.getTextFromLang("okotrequest", 'ขอทำโอที'),
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

  Widget buildStartDate(BuildContext context) {
    //DateTime now = DateTime.now();
    // if (widget.myOtRequest != null &&
    //     widget.myOtRequest!.startdatetime != null) {
    //   now = widget.myOtRequest!.startdatetime!;
    // }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.60,
      child: FormBuilderDateRangePicker(
        name: "OTDate",
        initialValue: DateTimeRange(start: ot_startdate, end: ot_enddate),
        firstDate: DateTime(1970),
        lastDate: DateTime(2500),
        style: const TextStyle(fontSize: 14),
        format: DateFormat("dd/MM/yyyy"),
        textAlign: TextAlign.center,
        saveText: UtilService.getTextFromLang("ok", 'OK'),
        //onSaved: generateList(),
        onChanged: (value) {
          ot_startdate = value!.start;
          ot_enddate = value.end;

          generateList();
        },
        validator: FormBuilderValidators.required(errorText: "กรอกช่วงวันที่"),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
          labelStyle: TextStyle(color: Colors.black87),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
      ),
    );
  }

  Widget buildStartTime(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.60,
      child: FormBuilderDateTimePicker(
        initialValue: ot_starttime,
        name: "starttime",
        // pickerType: PickerType.cupertino,
        inputType: InputType.time,
        timePickerInitialEntryMode: TimePickerEntryMode.input,
        format: DateFormat("HH:mm"),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
        onChanged: (value) {
          ot_starttime = value!;
          generateList();
        },
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
            labelStyle: TextStyle(color: Colors.black87),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        validator: FormBuilderValidators.required(
            errorText: UtilService.getTextFromLang(
                "please_select",
                UtilService.getTextFromLang(
                    "please_select", 'กรอกเวลาสิ้นสุด'))),
      ),
    );
  }

  Widget buildEndTime(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.60,
      child: FormBuilderDateTimePicker(
        initialValue: ot_endtime, //.add(const Duration(hours: 1)),
        name: "endtime",
        inputType: InputType.time,
        // pickerType: PickerType.cupertino,
        timePickerInitialEntryMode: TimePickerEntryMode.input,
        format: DateFormat("HH:mm"),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
        onChanged: (value) {
          ot_endtime = value!;
          generateList();
        },
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
            labelStyle: TextStyle(color: Colors.black87),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        validator: FormBuilderValidators.required(
            errorText: UtilService.getTextFromLang(
                "please_select",
                UtilService.getTextFromLang(
                    "please_select", 'กรอกเวลาสิ้นสุด'))),
      ),
    );
  }

  Widget buildApprover(BuildContext context) {
    int? approverId;
    if (widget.myOtRequest != null) {
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
            onChanged: (int? value) {
              approveId = value;
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
            top: 5.0,
          ),
          child: Text(UtilService.getTextFromLang("remark", 'หมายเหตุ')),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: FormBuilderTextField(
            initialValue:
                widget.myOtRequest == null ? '' : widget.myOtRequest!.remark,
            minLines: 1,
            maxLength: 250,
            maxLines: 1,
            onChanged: (value) {
              remark = value ?? "";
            },
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
              UtilService.getTextFromLang("ok", 'ตกลง'),
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

  requestOT() async {
    // _fbKey.currentState!.save();
    // if (_fbKey.currentState!.saveAndValidate()) {
    //   //print(_fbKey.currentState!.value);
    print('on save');
    var startdate = ot_startdate;
    var enddate = ot_enddate;
    var starttime = ot_starttime; // _fbKey.currentState!.value['starttime'];
    var endtime = ot_endtime; // _fbKey.currentState!.value['endtime'];
    var approverid = approveId; //_fbKey.currentState!.value['approverid'];
    var remark = this.remark; //_fbKey.currentState!.value['remark'];

    if (!validateStartAndEndDateTime(startdate, starttime, enddate, endtime)) {
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
                    "enddate": DateFormat('dd/MM/yyyy').format(enddate),
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
    // } else {
    //   print('on invalide');
    //   print(_fbKey.currentState!.value);
    // }
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

  Expanded buildListPreview() {
    return Expanded(
      child: Container(
        //padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          //color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.4),
          //     spreadRadius: 2,
          //     blurRadius: 2,
          //     offset: const Offset(1, 1), // changes position of shadow
          //   ),
          // ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Column(
            children: <Widget>[
              //const SizedBox(height: 5.0),
              Center(
                  child: Text(
                UtilService.getTextFromLang(
                    "ot_request_list", 'รายการคำขอทำโอที'),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
              const SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      UtilService.getTextFromLang("start", 'เริ่ม'),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      UtilService.getTextFromLang("end", 'สิ้นสุด'),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Expanded(
                // child: Scrollbar(
                child: isLoadingPreviewList
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        // reverse: true,
                        separatorBuilder: (BuildContext bContext, int index) {
                          return const SizedBox(height: 3.0);
                        },
                        itemCount: otRequestList.length,
                        itemBuilder: (BuildContext bContext, int index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    otRequestList[index].otStartDate,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    otRequestList[index].otEndDate,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
              ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  generateList() {
    setState(() {
      isLoadingPreviewList = true;
    });

    DateTime startdate = ot_startdate;
    DateTime enddate = ot_enddate;
    DateTime starttime =
        ot_starttime; //_fbKey.currentState!.value['starttime'];
    DateTime endtime = ot_endtime; //_fbKey.currentState!.value['endtime'];

    otRequestList = [];

    if (starttime.compareTo(endtime) != 0) {
      DateTime currDate = startdate;
      while (currDate.compareTo(enddate) <= 0) {
        DateTime currEndDate = DateFormat('HH:mm')
                    .format(starttime)
                    .compareTo(DateFormat('HH:mm').format(endtime)) <
                0
            ? currDate
            : currDate.add(const Duration(days: 1));

        otRequestList.add(OTPreview(
            otStartDate:
                '${DateFormat('dd/MM/yyyy').format(currDate)} ${DateFormat('HH:mm').format(starttime)}',
            otEndDate:
                '${DateFormat('dd/MM/yyyy').format(currEndDate)} ${DateFormat('HH:mm').format(endtime)}'));
        currDate = currDate.add(const Duration(days: 1));
      }
    }

    setState(() {
      isLoadingPreviewList = false;
    });
  }
}

class OTPreview {
  late String otStartDate;
  late String otEndDate;

  OTPreview({required this.otStartDate, required this.otEndDate});
}
