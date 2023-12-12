import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/AbsentApproverModel.dart';
import '../../models/GetMyAbsentRequestModel.dart';
import '../../models/absentTypeModel.dart';
import '../../models/profile.dart';
import '../../services/get_absent_approver_service.dart';
import '../../services/get_worktime_service.dart';
import '../../services/request_absent_service.dart';
import '../../services/get_absent_type_service.dart';
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;
import '../../services/update_absent_service.dart';
import '../../services/util_service.dart';
import '../../widgets/attach_file_web_widget.dart';

import '../../widgets/attach_file_widget.dart';
import '../../widgets/date_input_widget.dart';

class NewAbsentPage extends StatefulWidget {
  final Profile profile;
  final MyAbsentRequest? myAbsentRequest;
  final List<AbsentType> absentTypeList;
  const NewAbsentPage(
      {Key? key,
      required this.profile,
      this.myAbsentRequest,
      required this.absentTypeList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _NewAbsentState(absentTypeList: absentTypeList);
}

class _NewAbsentState extends State<NewAbsentPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  List<AbsentType> absentTypeList = [];
  List<AbsentApprover> absentApproverList = [];

  bool isUseAttachFile = false;

  bool worktimeLoaded = false;
  DateTime defaultStarttime = DateTime.now();
  DateTime defaultEndtime = DateTime.now();
  double minAbsentHour = 0.0;

  _NewAbsentState({this.absentTypeList = const []});

  dynamic attachedFile;
  dynamic attachFileWidget;
  TextEditingController attachFileController = TextEditingController();

  getAbsentType() async {
    GetAbsentTypeService getAbsentTypeService = GetAbsentTypeService();
    List<AbsentType> absentTypeList =
        await getAbsentTypeService.getData(profile: widget.profile);
    setState(() {
      absentTypeList = absentTypeList;
    });
  }

  getAbsentApprover() async {
    GetAbsentApproverService getAbsentApproverService =
        GetAbsentApproverService();
    absentApproverList =
        await getAbsentApproverService.getDate(profile: widget.profile);

    setState(() {
      absentApproverList = absentApproverList;
    });
  }

  getWorkTime() async {
    setState(() {
      worktimeLoaded = false;
    });
    GetWorkTimeService getWorkTimeService = GetWorkTimeService();
    WorkTime workTime =
        await getWorkTimeService.getTime(profile: widget.profile);
    setState(() {
      defaultStarttime = workTime.startDatetime!;
      defaultEndtime = workTime.endDatetime!;
      worktimeLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // Check flag
    if (widget.profile.isUseAttachFile != null) {
      isUseAttachFile = widget.profile.isUseAttachFile!;
    }
    if (widget.profile.minAbsentHour != null) {
      minAbsentHour = widget.profile.minAbsentHour!;
    }

    if (widget.myAbsentRequest == null) {
      getWorkTime();
    } else {
      worktimeLoaded = true;
    }

    if (absentTypeList.isEmpty) {
      getAbsentType();
    }
    getAbsentApprover();
  }

  void buildAttachFileWidget(BuildContext context) {
    attachFileWidget = !kIsWeb
        ? AttachFileWidget(
            allowLocalImg: true,
            allowCamera: false,
            onSelected: (file) {
              attachedFile = file;
            },
            onError: (title, desc) {
              UtilService.buildAlertError(context, title, desc).show();
            },
            attachFileController: attachFileController,
          )
        : AttachFileWebWidget(
            onSelected: (fileWeb) {
              attachedFile = fileWeb;
            },
            onError: (title, desc) {
              UtilService.buildAlertError(context, title, desc).show();
            },
            withLabel: true,
            allowLocalImg: true,
            attachFileController: attachFileController,
          );

    setState(() {
      attachFileWidget = attachFileWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildAttachFileWidget(context);
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
        title: Text(
          UtilService.getTextFromLang("absentrequest", "ขอลางาน"),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
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
              // SizedBox(height: 6.0),
              // Text(
              //   'ขอลางาน',
              //   style: TextStyle(
              //       fontSize: 20,
              //       color: Colors.black,
              //       fontWeight: FontWeight.bold),
              // ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: FormBuilder(
                      // autovalidateMode: AutovalidateMode
                      //     .onUserInteraction,
                      key: _fbKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              worktimeLoaded
                                  ? buildStart(context)
                                  : Container(),
                              const SizedBox(
                                width: 30,
                              ),
                              worktimeLoaded ? buildEnd(context) : Container(),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          buildTypeAbsent(context),
                          const SizedBox(
                            height: 30,
                          ),
                          absentApproverList.isEmpty
                              ? Container()
                              : buildApprover(context),
                          absentApproverList.isEmpty
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
                          attachFileWidget ?? Container(),
                          // isUseAttachFile ? buildAttachedFile() : Container(),
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
                      onPressed: widget.myAbsentRequest == null
                          ? requestAbsent
                          : updateAbsent,
                      child: Text(
                        widget.myAbsentRequest == null
                            ? UtilService.getTextFromLang(
                                "absentrequest", "ขอลางาน")
                            : UtilService.getTextFromLang("edit", "แก้ไข"),
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
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
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

  Widget buildStart(BuildContext context) {
    DateTime startTime;
    if (widget.myAbsentRequest != null &&
        widget.myAbsentRequest!.startdatetime != null) {
      startTime = widget.myAbsentRequest!.startdatetime!;
    } else {
      startTime = defaultStarttime;
    }
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          UtilService.getTextFromLang("start", "เริ่ม"),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: DateInputWidget(
            name: "startdate",
            initialValue: startTime,
            errorText: 'กรอกวันเริ่ม',
          ),
          // child: FormBuilderDateTimePicker(
          //   initialValue: startTime,
          //   name: "startdate",
          //   inputType: InputType.date,
          //   style: TextStyle(fontSize: 14),
          //   format: DateFormat("dd-MM-yyyy"),
          //   textAlign: TextAlign.center,
          //   decoration: InputDecoration(
          //       contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
          //       labelStyle: TextStyle(color: Colors.black87),
          //       fillColor: Colors.white,
          //       filled: true,
          //       border: OutlineInputBorder(
          //           borderRadius: BorderRadius.all(Radius.circular(20)))),
          //   validator: FormBuilderValidators.required(context,
          //       errorText: 'กรอกวันเริ่ม'),
          // ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: FormBuilderDateTimePicker(
            initialValue: startTime,
            name: "starttime",
            inputType: InputType.time,
            //pickerType: PickerType.cupertino,
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
        ),
      ],
    );
  }

  Widget buildEnd(BuildContext context) {
    DateTime endTime;
    if (widget.myAbsentRequest != null &&
        widget.myAbsentRequest!.enddatetime != null) {
      endTime = widget.myAbsentRequest!.enddatetime!;
    } else {
      endTime = defaultEndtime;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          UtilService.getTextFromLang("end", "สิ้นสุด"),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: DateInputWidget(
            name: "enddate",
            initialValue: endTime,
            errorText: 'กรอกวันสิ้นสุด',
          ),
          // child: FormBuilderDateTimePicker(
          //   initialValue: endTime,
          //   name: "enddate",
          //   inputType: InputType.date,
          //   style: TextStyle(fontSize: 14),
          //   format: DateFormat("dd-MM-yyyy"),
          //   textAlign: TextAlign.center,
          //   decoration: InputDecoration(
          //       contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
          //       labelStyle: TextStyle(color: Colors.black87),
          //       fillColor: Colors.white,
          //       filled: true,
          //       border: OutlineInputBorder(
          //           borderRadius: BorderRadius.all(Radius.circular(20)))),
          //   validator: FormBuilderValidators.required(context,
          //       errorText: 'กรอกวันสิ้นสุด'),
          // ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          width: MediaQuery.of(context)
                  .copyWith(alwaysUse24HourFormat: true)
                  .size
                  .width *
              0.40,
          child: buildTimePicker(context, "endtime", endTime,
              UtilService.getTextFromLang("please_select", 'กรอกเวลาเริ่ม')),
        )
      ],
    );
  }

  Row buildTypeAbsent(BuildContext context) {
    int? val;
    if (widget.myAbsentRequest != null) {
      val = absentTypeList
          .firstWhere(
              (element) => element.text == widget.myAbsentRequest!.absenttype)
          .key;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(UtilService.getTextFromLang("absenttype", "ประเภทลา")),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: absentTypeList.isEmpty
              ? const Text('')
              : FormBuilderDropdown(
                  initialValue: val,
                  decoration: InputDecoration(
                    labelText: UtilService.getTextFromLang(
                        "please_select", 'เลือกประเภท'),
                    hintText: UtilService.getTextFromLang(
                        "please_select", 'เลือกประเภท'),
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _fbKey.currentState!.fields['absenttypeid']?.reset();
                      },
                    ),
                  ),
                  onChanged: (val) => print('select: $val'),
                  items: absentTypeList.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text('${option.text}'),
                    );
                  }).toList(),
                  name: 'absenttypeid',
                  validator: FormBuilderValidators.required(
                      errorText: UtilService.getTextFromLang(
                          "please_select", 'เลือกชื่อ')),
                ),
        ),
      ],
    );
  }

  Widget buildApprover(BuildContext context) {
    int? approverId;
    if (widget.myAbsentRequest != null) {
      // Get approver id from list
      approverId = absentApproverList
          .firstWhere(
              (element) => element.text == widget.myAbsentRequest!.approvername)
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
            items: absentApproverList.map((option) {
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
            initialValue: widget.myAbsentRequest == null
                ? ''
                : widget.myAbsentRequest!.remark,
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

  Widget buildTimePicker(BuildContext context, String name,
      DateTime initialTime, String errrorText) {
    final Widget mediaQueryWrapper = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        alwaysUse24HourFormat: true,
      ),
      child: FormBuilderDateTimePicker(
        initialValue: initialTime,
        name: name,
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
          errorText: errrorText,
        ),
      ),
    );
    return mediaQueryWrapper;
  }

  // Widget buildAttachedFile() {
  //   return AttachFileWidget(
  //     attachFileController: attachFileController,
  //     onSelected: (file) {
  //       attachedFile = file;
  //     },
  //     onError: (title, desc) {
  //       buildAlertError(context, title, desc, [
  //         DialogButton(
  //           child: const Text(
  //             "ตกลง",
  //             style: TextStyle(color: Colors.white, fontSize: 20),
  //           ),
  //           onPressed: () => Navigator.pop(context),
  //           width: 120,
  //         )
  //       ]).show();
  //     },
  //   );
  // }

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

  requestAbsent() async {
    _fbKey.currentState!.save();
    if (_fbKey.currentState!.saveAndValidate()) {
      //print(_fbKey.currentState!.value);
      print('on save');

      var startdate = _fbKey.currentState!.value['startdate'];
      var enddate = _fbKey.currentState!.value['enddate'];
      var absenttypeid = _fbKey.currentState!.value['absenttypeid'];
      var starttime = _fbKey.currentState!.value['starttime'];
      var endtime = _fbKey.currentState!.value['endtime'];
      var approverid = _fbKey.currentState!.value['approverid'];
      var remark = _fbKey.currentState!.value['remark'];

      if (!validateStartAndEndDateTime(
          startdate, starttime, enddate, endtime)) {
        String errorText;
        if (widget.profile.minAbsentHour != null) {
          errorText =
              'จำนวนชั่วโมงลาขั้นต่ำต้องมากกว่า ${minAbsentHour.toStringAsFixed(2)} ชั่วโมง';
        } else {
          errorText = UtilService.getTextFromLang(
              "starttime_must_be_less_than_endtime",
              'เวลาเริ่มต้นต้องน้อยกว่าเวลาสิ้นสุด');
        }
        buildAlertError(context, errorText, '', [
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
                  "question_confirm_request", 'ยืนยันส่งคำขอลางาน'),
              '',
              [
                DialogButton(
                  onPressed: () async {
                    String attachfiletype = '';
                    // if (attachedFile != null &&
                    //     path.extension(attachedFile!.path).isNotEmpty) {
                    //   // Prevent empty extension string
                    //   attachfiletype =
                    //       path.extension(attachedFile!.path).substring(1);
                    // }

                    if (attachedFile != null) {
                      if (kIsWeb) {
                        attachfiletype =
                            lookupMimeType('', headerBytes: attachedFile) ?? "";
                        if (attachfiletype.isNotEmpty) {
                          attachfiletype = attachfiletype.split('/')[1];
                        }
                      } else if (path.extension(attachedFile.path).isNotEmpty) {
                        attachfiletype =
                            path.extension(attachedFile.path).substring(1);
                      }
                    }

                    var payload = convert.jsonEncode({
                      "companyname": widget.profile.companyname,
                      "employeeid": widget.profile.employeeid,
                      "absenttypeid": absenttypeid,
                      "startdate": DateFormat('dd/MM/yyyy').format(startdate),
                      "starttime": DateFormat('HH:mm').format(starttime),
                      "enddate": DateFormat('dd/MM/yyyy').format(enddate),
                      "endtime": DateFormat('HH:mm').format(endtime),
                      "approverid": approverid,
                      "remark": remark,
                      "attachfile": attachedFile != null
                          ? convert.base64Encode(kIsWeb
                              ? attachedFile
                              : (await attachedFile.readAsBytes()))
                          : null,
                      // "attachfile": attachedFile != null
                      //     ? convert
                      //         .base64Encode(await attachedFile!.readAsBytes())
                      //     : null,
                      "attachfiletype": attachfiletype,
                    });
                    //print(payload);
                    showAlertLoading(context);
                    RequestAbsentService requestAbsentService =
                        RequestAbsentService();
                    if (await requestAbsentService.onRequest(
                        widget.profile, payload, context)) {
                      setState(() {
                        attachFileController.text = "";
                        attachedFile = null;
                      });
                    }
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

  updateAbsent() async {
    _fbKey.currentState!.save();
    if (_fbKey.currentState!.saveAndValidate()) {
      print(_fbKey.currentState!.value);
      print('on save');

      var startdate = _fbKey.currentState!.value['startdate'];
      var enddate = _fbKey.currentState!.value['enddate'];
      var absenttypeid = _fbKey.currentState!.value['absenttypeid'];
      var starttime = _fbKey.currentState!.value['starttime'];
      var endtime = _fbKey.currentState!.value['endtime'];
      var approverid = _fbKey.currentState!.value['approverid'];
      var remark = _fbKey.currentState!.value['remark'];

      if (!validateStartAndEndDateTime(
          startdate, starttime, enddate, endtime)) {
        String errorText;
        if (widget.profile.minAbsentHour != null) {
          errorText =
              'จำนวนชั่วโมงลาขั้นต่ำต้องมากกว่า ${minAbsentHour.toStringAsFixed(2)} ชั่วโมง';
        } else {
          errorText = UtilService.getTextFromLang(
              "starttime_must_be_less_than_endtime",
              'เวลาเริ่มต้นต้องน้อยกว่าเวลาสิ้นสุด');
        }
        buildAlertError(context, errorText, '', [
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
              'ยืนยันแก้คำขอลางาน',
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
                      "absentrequestid":
                          widget.myAbsentRequest!.absentrequestid,
                      "absenttypeid": absenttypeid,
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
                    print(payload);
                    showAlertLoading(context);
                    UpdateAbsentService updateAbsentService =
                        UpdateAbsentService();
                    await updateAbsentService.onUpdate(
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
      //print(_fbKey.currentState!.value);
    }
  }

  bool validateStartAndEndDateTime(DateTime startdate, DateTime starttime,
      DateTime enddate, DateTime endtime) {
    DateTime startdatetime = DateTime(startdate.year, startdate.month,
        startdate.day, starttime.hour, starttime.minute);
    DateTime enddatetime = DateTime(
        enddate.year, enddate.month, enddate.day, endtime.hour, endtime.minute);

    try {
      if (startdatetime.compareTo(enddatetime) >= 0) {
        return false;
      }
    } catch (_) {}
    return (enddatetime.difference(startdatetime).inMinutes) / 60 >=
        minAbsentHour;
  }
}
