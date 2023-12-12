import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
// import 'dart:io';
//import 'package:universal_io/io.dart';
import 'package:open_filex/open_filex.dart';
//import 'package:path_provider/path_provider.dart';
import '../../models/GetReportAbsentModel.dart';
import '../../models/GetEmployeeListModel.dart';
import '../../models/profile.dart';
import '../../services/get_report_absent_service.dart';

// import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:share/share.dart';
import 'dart:convert' as convert;
// import 'package:smart_select/smart_select.dart';
// import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';

import 'package:share_plus/share_plus.dart';
import 'dart:developer';
import 'package:file_saver/file_saver.dart';
import '../../services/util_service.dart';
import '../../widgets/dropdown_widget.dart';

class ReportAbsentPage extends StatefulWidget {
  final Profile profile;

  const ReportAbsentPage({Key? key, required this.profile}) : super(key: key);
  @override
  _ReportAbsentPageState createState() => _ReportAbsentPageState();
}

enum SelectedFilterEmpType { dep, emp }

class _ReportAbsentPageState extends State<ReportAbsentPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  SelectedFilterEmpType _character = SelectedFilterEmpType.dep;
  String _timeUnit = "D";
  bool isCheckedMissing = true;
  bool isCheckedAbsent = true;
  bool isCheckedLate = true;
  bool isAdmin = false;
  bool isLoading = false;
  double fontSize = 16;

  // List<DepartmentList> departmentList = []; //Get from api
  // List<S2Choice<int>> _itemsDepList = []; //By with modal multiselect
  List<dynamic> departmentList = []; //Get from api
  List<dynamic> _selectedDepList = []; //state for selected

  List<EmployeeList> employeeList = [];
  int? _selectedEmpId = 0;

  String text = '';
  String subject = '';
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();

    getDepartment();
    // getEmployeeList();
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
        title: Text(
          UtilService.getTextFromLang(
              "rpt_missing_absent_late", 'รายงาน ขาด/ลา/สาย'),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: buildBottomButton(context),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildStart(context),
                        buildEnd(context),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    (isAdmin ? buildFilterEmpType(context) : Container()),
                    const SizedBox(
                      height: 25,
                    ),
                    (isAdmin
                        ? (_character == SelectedFilterEmpType.dep
                            ? (departmentList.isEmpty
                                ? Container()
                                : buildSelectDep(context))
                            : (employeeList.isEmpty
                                ? Container()
                                : buildSelectEmp(context)))
                        : Container()),
                    const Divider(
                      color: Colors.black54,
                    ),
                    buildSelectRptType(context),
                    const Divider(
                      color: Colors.black54,
                    ),
                    buildSelectTimeUnit(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildStart(BuildContext context) {
    DateTime now = DateTime.now();
    // if (widget.myOtRequest != null && widget.myOtRequest.startdatetime != null) {
    //   now = widget.myOtRequest.startdatetime;
    // }
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          UtilService.getTextFromLang("start", 'เริ่ม'),
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
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
            validator:
                FormBuilderValidators.required(errorText: 'กรอกวันเริ่ม'),
            onChanged: (value) {
              setState(() {
                if (value != null) start = value;
              });
            },
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Widget buildEnd(BuildContext context) {
    DateTime now = DateTime.now();
    // if (widget.myOtRequest != null && widget.myOtRequest.enddatetime != null) {
    //   now = widget.myOtRequest.enddatetime;
    // }
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          UtilService.getTextFromLang("end", 'สิ้นสุด'),
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
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
            validator:
                FormBuilderValidators.required(errorText: 'กรอกวันสิ้นสุด'),
            onChanged: (value) {
              setState(() {
                if (value != null) end = value;
              });
            },
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Row buildFilterEmpType(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'ค้นหาจาก',
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Radio(
                  value: SelectedFilterEmpType.dep,
                  groupValue: _character,
                  onChanged: (SelectedFilterEmpType? value) {
                    setState(() {
                      if (value != null) _character = value;
                      if (_character == SelectedFilterEmpType.dep) {
                        _selectedEmpId = null;
                      } else {
                        _selectedDepList = [];
                      }
                    });
                  },
                ),
                Text(
                  'แผนก',
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Radio(
                  value: SelectedFilterEmpType.emp,
                  groupValue: _character,
                  onChanged: (SelectedFilterEmpType? value) {
                    setState(() {
                      if (value != null) _character = value;
                    });
                  },
                ),
                Text(
                  'พนักงาน',
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            )),
      ],
    );
  }

  Row buildSelectEmp(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'พนักงาน',
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.60,
              child: FormBuilderDropdown<int?>(
                initialValue: null,
                decoration: InputDecoration(
                  labelText: 'เลือกพนักงาน',
                  hintText: 'เลือกพนักงาน',
                  suffix: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _fbKey.currentState!.fields['employeeid']?.reset();
                    },
                  ),
                ),
                onChanged: (int? val) {
                  print('select: $val');
                  setState(() {
                    _selectedEmpId = val;
                  });
                },
                items: employeeList.map((option) {
                  return DropdownMenuItem(
                    value: option.employeeId,
                    child: Text('${option.employeeName}'),
                  );
                }).toList(),
                name: 'employeeid',
                validator:
                    FormBuilderValidators.required(errorText: 'เลือกพนักงาน'),
              ),
            ),
          ]),
        )
      ],
    );
  }

  Row buildSelectDep(BuildContext context) {
    //List<int?> initialVal = departmentList.map((dep) => dep.masterId).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                // color: Colors.red,
                child: Text(
                  "แผนก",
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              )),
        ),
        Expanded(
          flex: 3,
          child: DropDownWidget(
            initialValue: departmentList,
            //departmentList.map((dep) => dep.masterNameTH).toList(),
            items: departmentList,
            keyfield: "master_id",
            label: 'เลือกแผนก',
            multiSelectTag: 'masterNameTH',
            multiSelectValuesAsWidget: true,
            decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
            multiSelect: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.all(0.0),
              child: Icon(Icons.search),
            ),
            dropDownMenuItems: departmentList.map((item) {
              return item["master_name_th"];
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                var tmpSelecteddeplist = jsonDecode(value);

                _selectedDepList =
                    tmpSelecteddeplist.map((dep) => dep["master_id"]).toList();
              } else {
                _selectedDepList.clear();
              }
            },
          ),
        ),
      ],
    );
  }

  Row buildSelectRptType(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            //child: Center(
            child: Text(
              UtilService.getTextFromLang("type", 'ประเภท'),
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
            //),
          ),
        ),
        Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    //width: MediaQuery.of(context).size.width * 0.60,
                    children: [
                      Checkbox(
                        checkColor: Colors.white,

                        // fillColor: MaterialStateProperty.resolveWith(Colors.orange),
                        value: isCheckedMissing,
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckedMissing = value ?? false;
                          });
                        },
                      ),
                      Text(
                        UtilService.getTextFromLang("missing", 'ขาด'),
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                        ),
                      ),
                    ]),
                Row(
                    //width: MediaQuery.of(context).size.width * 0.60,
                    children: [
                      Checkbox(
                        checkColor: Colors.white,

                        // fillColor: MaterialStateProperty.resolveWith(Colors.orange),
                        value: isCheckedAbsent,
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckedAbsent = value ?? false;
                          });
                        },
                      ),
                      Text(
                        UtilService.getTextFromLang("absent", 'ลา'),
                        style: TextStyle(
                          fontSize: fontSize,
                        ),
                      ),
                    ]),
                Row(
                    //width: MediaQuery.of(context).size.width * 0.60,
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        // fillColor: MaterialStateProperty.resolveWith(Colors.orange),
                        value: isCheckedLate,
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckedLate = value ?? false;
                          });
                        },
                      ),
                      Text(
                        UtilService.getTextFromLang("late", 'สาย'),
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                        ),
                      ),
                    ]),
              ],
            )),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Row buildSelectTimeUnit(BuildContext context) {
    List<TimeUnit> timeUnitItems = [];
    timeUnitItems
        .add(TimeUnit("D", UtilService.getTextFromLang("days", 'วัน')));
    timeUnitItems.add(
        TimeUnit("H", UtilService.getTextFromLang("hour_short_type", 'ชม.')));
    timeUnitItems
        .add(TimeUnit("M", UtilService.getTextFromLang("minutes", 'นาที')));

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            //child: Center(
            child: Text(
              UtilService.getTextFromLang("timeunit", 'หน่วยเวลา'),
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
            //),
          ),
        ),
        Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: "D",
                      groupValue: _timeUnit,
                      onChanged: (String? value) {
                        setState(() {
                          _timeUnit = value ?? "D";
                        });
                      },
                    ),
                    Text(
                      UtilService.getTextFromLang("days", 'วัน'),
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: "H",
                      groupValue: _timeUnit,
                      onChanged: (String? value) {
                        setState(() {
                          _timeUnit = value ?? "D";
                        });
                      },
                    ),
                    Text(
                      UtilService.getTextFromLang("hour_short_type", 'ชม.'),
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                    // SizedBox(
                    //   width: 20,
                    // ),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: "M",
                      groupValue: _timeUnit,
                      onChanged: (String? value) {
                        setState(() {
                          if (value != null) _timeUnit = value;
                        });
                      },
                    ),
                    Text(
                      UtilService.getTextFromLang("minute", 'นาที'),
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ],
    );
  }

  Container buildBottomButton(BuildContext context) {
    List<Widget> normalButtonList = [
      ButtonWidget(
        title: UtilService.getTextFromLang("download", "ดาวน์โหลด"),
        onPressed: () {
          getData(false);
        },
        color: const Color(0xFFFF8101),
        icon: Icons.arrow_circle_down_rounded,
      ),
      const SizedBox(width: 10),
      ButtonWidget(
        title: UtilService.getTextFromLang("share", 'share'),
        onPressed: () {
          getData(true);
          // if (selectedId.length == 0) {
          //   alertEmpty('โปรดเลือกรายการ');
          //   return;
          // }
          // onCancelSelected();
        },
        color: Colors.black,
        icon: Icons.share,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: normalButtonList),
    );
  }

  getDepartment() async {
    setState(() {
      isLoading = true;
    });

    GetReportAbsentService initialdata = GetReportAbsentService();
    var feedback = await initialdata.getInitialData(profile: widget.profile);

    dynamic initialjson = convert.jsonDecode(feedback);
    dynamic departmentList = initialjson['dep']['objectresult'];
    // List<DepartmentList> _departmentList =
    //     GetDepartmentListModel.fromJson(initialjson['dep']).objectresult;
    List<EmployeeList> employeeList =
        GetEmployeeListModel.fromJson(initialjson['emp']).objectresult;

    if ((initialjson['permit']['objectresult'] as List).isNotEmpty) {
      isAdmin = initialjson['permit']['objectresult'][0]['group_id'] == 1;
    }

    // GetDepartmentListService getDepartmentListService =
    //     GetDepartmentListService();
    // List<DepartmentList> _departmentList =
    //     await getDepartmentListService.getData(profile: widget.profile);

    // GetEmployeeListService getEmployeeListService = GetEmployeeListService();
    // List<EmployeeList> _employeeList =
    //     await getEmployeeListService.getData(profile: widget.profile);

    setState(() {
      isLoading = false;
      departmentList = departmentList;
      employeeList = employeeList;

      if (!isAdmin) {
        _character = SelectedFilterEmpType.emp;
        _selectedEmpId = employeeList[0].employeeId;
      }

      _selectedDepList = departmentList.isEmpty
          ? []
          : departmentList.map((dep) => dep["master_id"]).toList();
    });
  }

  // getEmployeeList() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  getData(bool isShare) async {
    showAlertLoading(context);
    GetReportAbsentService getRptService = GetReportAbsentService();
    ReportAbsentModel rptAbsent = await getRptService.getData(
        profile: widget.profile,
        start: start,
        end: end,
        depIds: _selectedDepList,
        empId: _selectedEmpId,
        isCheckMissing: isCheckedMissing,
        isCheckLeave: isCheckedAbsent,
        isCheckLate: isCheckedLate,
        timeUnit: _timeUnit);
    print('Open rpt absent: ${rptAbsent.filename}');

    // Get temporary directory and write file
    // Directory directory = await getTemporaryDirectory();
    // String savePath = '${directory.path}/${rptAbsent.filename}';
    // File file = File(savePath);
    Uint8List data = convert.base64Decode(rptAbsent.attachfile ?? '');
    //await file.writeAsBytes(data);

    MimeType type = MimeType.PDF;
    String path = await FileSaver.instance
        .saveFile(rptAbsent.filename ?? "absent", data, "pdf", mimeType: type);
    log(path);

    // Dismiss alert dialog
    Navigator.of(context).pop();

    if (isShare) {
      imagePaths = [];
      imagePaths.add(path);
      _onShare(context);
    } else {
      // Open file
      if (!kIsWeb) OpenFilex.open(path);
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
              child: Text(UtilService.getTextFromLang(
                  "downloading", "กำลังดาวน์โหลด"))),
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

  _onDeleteImage(int position) {
    setState(() {
      imagePaths.removeAt(position);
    });
  }

  _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final RenderBox box = context.findRenderObject() as RenderBox;

    if (imagePaths.isNotEmpty) {
      await Share.shareFiles(imagePaths,
          text: text,
          subject: subject,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(text,
          subject: subject,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  _onShareWithEmptyOrigin(BuildContext context) async {
    await Share.share("text");
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: ElevatedButton.icon(
          icon: icon != null ? Icon(icon) : const Text(''),
          label: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
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
      ),
    );
  }
}

class TimeUnit {
  TimeUnit(key, text) {
    this.key = key;
    this.text = text;
  }

  late String key;
  late String text;
}
