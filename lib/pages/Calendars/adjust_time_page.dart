import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/AdjustApproverModel.dart';
import '../../models/history.dart';
import '../../models/locationAll.dart';
import '../../models/profile.dart';
import '../../services/get_adjust_approver_service.dart';
import '../../services/get_adjust_request_service.dart';
import '../../services/location_all_service.dart';
import '../../services/request_adjust_service.dart';
import '../../services/util_service.dart';
import '../../widgets/attach_file_widget.dart';
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;

class AdjustTimePage extends StatefulWidget {
  final Profile profile;
  final int adjustRequestId;
  final History? history;

  const AdjustTimePage({
    super.key,
    required this.profile,
    required this.adjustRequestId,
    required this.history,
  });

  @override
  _AdjustTimePageState createState() => _AdjustTimePageState(history: history);
}

class _AdjustTimePageState extends State<AdjustTimePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  TextEditingController attachFileController = TextEditingController();
  List<AdjustApprover> adjustApproverList = [];
  AdjustRequest? adjustRequest;
  bool isUseAttachFile = false;
  File? attachedFile;
  History? history;

  bool isLocationLoaded = false;
  List<LocationAll> locationList = [];

  _AdjustTimePageState({this.history});

  getAdjustApprover() async {
    GetAdjustApproverService adjustApproverService = GetAdjustApproverService();
    adjustApproverList =
        await adjustApproverService.getApprover(profile: widget.profile);
    if (mounted) {
      setState(() {
        adjustApproverList = adjustApproverList;
      });
    }
  }

  getAdjustLocation() async {
    LocationAllService locationAllService = LocationAllService();
    locationList =
        await locationAllService.getLocationAll(profile: widget.profile);
    if (mounted) {
      setState(() {
        locationList = locationList;
        isLocationLoaded = true;
      });
    }
  }

  getAdjustRequest() async {
    GetAdjustRequestService adjustRequestService = GetAdjustRequestService();
    adjustRequest = await adjustRequestService.getRequest(
        profile: widget.profile, adjustRequestId: widget.adjustRequestId);
    if (mounted) {
      setState(() {
        adjustRequest = adjustRequest;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Check flag

    if (widget.profile.isUseAttachFile != null) {
      isUseAttachFile = widget.profile.isUseAttachFile ?? false;
    }

    getAdjustApprover();
    getAdjustLocation();

    if (widget.adjustRequestId != 0) {
      getAdjustRequest();
    } else {
      // setState(() {

      // });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'HR Mobile',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Center(
                      child: Text(
                        'ขอปรับเวลาเข้าออกงาน',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    //buildOldData(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    buildNewData(),
                  ],
                ),
              ),
              //Spacer(),
              buildBottomButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOldData() {
    String scanLocationString =
        UtilService.getTextFromLang("not_specified", "ไม่ระบุ");
    String scanDatetimeString = '';
    String scanTypeString =
        UtilService.getTextFromLang("not_specified", "ไม่ระบุ");
    List<Widget> scanMethodWidgetList = [];
    String scanStatus = UtilService.getTextFromLang("not_specified", "ไม่ระบุ");

    if (history != null) {
      scanLocationString =
          history!.locationcaption == null || history!.locationcaption!.isEmpty
              ? UtilService.getTextFromLang("not_specified", "ไม่ระบุ")
              : history!.locationcaption!;
      scanDatetimeString = history!.dateTimeToString();
      if (history!.scantype == 'I') {
        scanTypeString = UtilService.getTextFromLang("in", "เข้า");
      } else if (history!.scantype == 'O') {
        scanTypeString = UtilService.getTextFromLang("out", "ออก");
      }
      if (history!.isNeedGps()) {
        scanMethodWidgetList.add(const Icon(
          Icons.location_pin,
          color: Color(0xFFFF8101),
        ));
      }
      if (history!.isNeedWifi()) {
        scanMethodWidgetList.add(const Icon(
          Icons.wifi,
          color: Color(0xFFFF8101),
        ));
      }
      if (history!.isNeedQrCode()) {
        scanMethodWidgetList.add(const Icon(
          Icons.qr_code,
          color: Color(0xFFFF8101),
        ));
      }
      scanStatus = UtilService.getTextFromLang("not_in_use", "ไม่ใช้งาน");
      // } else {
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(1, 1), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'สถานที่แสกน:',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    scanLocationString,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'วัน-เวลา:',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    scanDatetimeString,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'เข้า/ออก:',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    scanTypeString,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'วิธีแสกน:',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: scanMethodWidgetList,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'สถานะ:',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    scanStatus,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNewData() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: FormBuilder(
          key: _fbKey,
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'ผู้อนุมัติ:',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: buildApprover(context),
                  ),
                ],
              ),
              isLocationLoaded
                  ? const SizedBox(
                      height: 10.0,
                    )
                  : Container(),
              isLocationLoaded
                  ? Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text(
                            'สถานที่ใหม่:',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: buildNewLocation(context),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'วัน-เวลาใหม่:',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: buildNewDatetime(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'สถานะใหม่:',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: buildNewStatus(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'หมายเหตุ:',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: buildRemark(context),
                  ),
                ],
              ),
              isUseAttachFile
                  ? const SizedBox(
                      height: 10.0,
                    )
                  : Container(),
              isUseAttachFile
                  ? Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text(
                            'ไฟล์แนบ:',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: buildAttachedFile(),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildApprover(BuildContext context) {
    return FormBuilderDropdown(
      name: 'approverid',
      decoration: InputDecoration(
        labelText: UtilService.getTextFromLang("please_select", 'เลือกชื่อ'),
        hintText: UtilService.getTextFromLang("please_select", 'เลือกชื่อ'),
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
      items: adjustApproverList.map((option) {
        return DropdownMenuItem(
          value: option.key,
          child: Text('${option.text}'),
        );
      }).toList(),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
            errorText:
                UtilService.getTextFromLang("please_select", 'เลือกชื่อ')),
      ]),
    );
  }

  Widget buildNewLocation(BuildContext context) {
    int? initialLocationKey;
    for (LocationAll l in locationList) {
      if (l.text == history!.locationcaption) {
        initialLocationKey = l.key;
        break;
      }
    }
    return FormBuilderDropdown(
      name: 'locationid',
      decoration: InputDecoration(
        labelText: 'เลือกสถานที่',
        suffix: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _fbKey.currentState!.fields['locationid']?.reset();
          },
        ),
        hintText: 'เลือกสถานที่',
      ),
      initialValue: initialLocationKey,
      //allowClear: true,
      onChanged: (value) {
        print("select : $value");
      },
      items: locationList.map((option) {
        return DropdownMenuItem(
          value: option.key,
          child: Text('${option.text}'),
        );
      }).toList(),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: "เลือกสถานที่"),
      ]),
    );
  }

  Widget buildNewDatetime(BuildContext context) {
    DateTime initialDatetime =
        history == null ? DateTime.now() : history!.toDateTime();
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: FormBuilderDateTimePicker(
            initialValue: initialDatetime,
            name: 'newdate',
            inputType: InputType.date,
            style: const TextStyle(fontSize: 14),
            format: DateFormat('dd/MM/yyyy'),
            textAlign: TextAlign.center,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "เลือกวันใหม่"),
            ]),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          flex: 1,
          child: FormBuilderDateTimePicker(
            initialValue: initialDatetime,
            name: 'newtime',
            inputType: InputType.time,
            style: const TextStyle(fontSize: 14),
            format: DateFormat('HH:mm'),
            textAlign: TextAlign.center,
            // alwaysUse24HourFormat: true,
            timePickerInitialEntryMode: TimePickerEntryMode.input,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "เลือกเวลาใหม่"),
            ]),
          ),
        ),
      ],
    );
  }

  Widget buildNewStatus(BuildContext context) {
    return FormBuilderDropdown(
      name: 'newstatus',
      decoration: InputDecoration(
        labelText: 'เลือกสถานะ',
        hintText: 'เลือกสถานะ',
        suffix: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _fbKey.currentState!.fields['newstatus']?.reset();
          },
        ),
      ),
      initialValue: 'Y',
      onChanged: (value) {
        print("select : $value");
      },
      items: const [
        DropdownMenuItem(
          value: 'Y',
          child: Text('ใช้งาน'),
        ),
        DropdownMenuItem(
          value: 'N',
          child: Text('ไม่ใช้งาน'),
        ),
      ],
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: "เลือกสถานะ"),
      ]),
    );
  }

  Widget buildRemark(BuildContext context) {
    return FormBuilderTextField(
      initialValue: history == null ? '' : (history!.remark ?? ''),
      minLines: 1,
      maxLength: 250,
      maxLines: 2,
      name: 'remark',
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.maxLength(250, errorText: ""),
      ]),
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
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
      },
      withLabel: false,
    );
  }

  Widget buildBottomButton(BuildContext context) {
    String buttonText = 'สร้างคำขอ';
    if (widget.adjustRequestId > 0) {
      buttonText = 'แก้ไขคำขอ';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            if (widget.adjustRequestId == 0) {
              requestAdjust();
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFFF8101),
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text(
            'ยกเลิก',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
        ),
      ],
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

  requestAdjust() async {
    _fbKey.currentState!.save();
    if (_fbKey.currentState!.saveAndValidate()) {
      //print(_fbKey.currentState!.value);
      //print('on save');
      int approverid = _fbKey.currentState!.value['approverid'];
      int locationid = _fbKey.currentState!.value['locationid'];
      DateTime newDate = _fbKey.currentState!.value['newdate'];
      DateTime newTime = _fbKey.currentState!.value['newdate'];
      String isActive = _fbKey.currentState!.value['newstatus'];
      String remark = _fbKey.currentState!.value['remark'];

      buildAlertError(
              context,
              UtilService.getTextFromLang("question_confirm_request",
                  'ยืนยันส่งคำขอปรับเวลาเข้าออกงาน'),
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
                      "scanid": history!.scanid,
                      "approverid": approverid,
                      "locationid": locationid,
                      "scandate": DateFormat("dd/MM/yyyy").format(newDate),
                      "scantime": DateFormat("HH:mm").format(newTime),
                      "isactive": isActive,
                      "remark": remark,
                      "attachfile": attachedFile != null
                          ? convert
                              .base64Encode(await attachedFile!.readAsBytes())
                          : null,
                      "attachfiletype": attachfiletype,
                    });
                    //print(payload);
                    showAlertLoading(context);
                    RequestAdjustService requestAdjustService =
                        RequestAdjustService();
                    await requestAdjustService.requestAdjust(
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
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
              alertType: AlertType.none)
          .show();
    }
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
