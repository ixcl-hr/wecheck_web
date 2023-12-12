import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../models/GetMyAbsentRequestModel.dart';
import '../../models/absentTypeModel.dart';
import '../../models/profile.dart';
import '../../pages/Absent/new_absent_page.dart';
// import '../pages/Absents/new_absent_page.dart';
import '../../services/delete_my_absent_request_service.dart';
import '../../services/get_my_absent_request_service.dart';
import '../../services/get_absent_type_service.dart';
import '../../services/get_attach_file_service.dart';
import 'dart:convert' as convert;

import '../../services/util_service.dart';

class AbsentMyPage extends StatefulWidget {
  final Profile profile;
  final int? lockAbsentType;
  final int? lockAbsentYear;

  const AbsentMyPage(
      {Key? key,
      required this.profile,
      this.lockAbsentType,
      this.lockAbsentYear})
      : super(key: key);

  @override
  AbsentMyPageState createState() =>
      AbsentMyPageState(selectedYear: lockAbsentYear);
}

class AbsentMyPageState extends State<AbsentMyPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool isLoading = false;
  bool isAbsentTypeLoading = false;
  bool isUseAttachFile = true;
  bool isDialogShown = false;

  List<MyAbsentRequest> requestList = [];
  List<MyAbsentRequest> requestListFiltered = [];
  List<int> selectedId = [];

  late int _selectedYear;

  AbsentMyPageState({int? selectedYear}) {
    _selectedYear = selectedYear ?? DateTime.now().year;
  }

  getMyAbsentRequest(selectedYear) async {
    setState(() {
      isLoading = true;
      requestList = [];
    });
    GetMyAbsentRequestService getMyAbsentRequestService =
        GetMyAbsentRequestService(selectedYear);
    requestList =
        await getMyAbsentRequestService.onRequest(profile: widget.profile);

    if (requestList.isNotEmpty) {
      // reversed
      if (mounted) {
        setState(() {
          isLoading = false;
          requestList = requestList.reversed.toList();

          if (widget.lockAbsentType != null) {
            selectAbsentType(widget.lockAbsentType!);
          } else {
            requestListFiltered = requestList;
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    // else {
    //   alertEmpty('ไม่สามารถติดต่อกับเซิร์ฟเวอร์');
    // }
  }

  List<AbsentType> absentTypeList = [
    AbsentType(key: -1, text: UtilService.getTextFromLang("all", 'ทั้งหมด'))
  ];

  getAbsentType() async {
    if (mounted) {
      setState(() {
        isAbsentTypeLoading = true;
      });
    }
    GetAbsentTypeService getAbsentTypeService = GetAbsentTypeService();
    absentTypeList =
        await getAbsentTypeService.getData(profile: widget.profile);
    if (absentTypeList.isNotEmpty) {
      if (mounted) {
        setState(() {
          isAbsentTypeLoading = false;
          absentTypeList = [
            AbsentType(
                key: -1, text: UtilService.getTextFromLang("all", 'ทั้งหมด')),
            ...absentTypeList
          ];
        });
      }
    } else {
      alertEmpty('ไม่สามารถติดต่อกับเซิร์ฟเวอร์');
    }
  }

  @override
  void initState() {
    super.initState();
    // Check flag
    // if (widget.profile.isUseAttachFile != null) {
    //   isUseAttachFile = widget.profile.isUseAttachFile!;
    // }

    getMyAbsentRequest(_selectedYear);
    getAbsentType();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.lockAbsentYear == null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () {
                        setState(() {
                          _selectedYear = _selectedYear - 1;
                          getMyAbsentRequest(_selectedYear);
                        });
                      },
                    )
                  : Container(),
              Center(
                child: TextButton(
                  onPressed: widget.lockAbsentYear == null
                      ? () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Select Year"),
                                content: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: YearPicker(
                                    firstDate:
                                        DateTime(DateTime.now().year - 100, 1),
                                    lastDate:
                                        DateTime(DateTime.now().year + 100, 1),
                                    initialDate: DateTime.now(),
                                    selectedDate: DateTime.now(),
                                    onChanged: (DateTime dateTime) {
                                      Navigator.pop(context);
                                      setState(() {
                                        _selectedYear = dateTime.year;
                                        getMyAbsentRequest(_selectedYear);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                      : null,
                  child: Text(
                    _selectedYear.toString(),
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              widget.lockAbsentYear == null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _selectedYear = _selectedYear + 1;
                          getMyAbsentRequest(_selectedYear);
                        });
                      },
                    )
                  : Container(),
            ],
          ),
          isAbsentTypeLoading
              ? Container()
              : Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: buildTypeAbsent(context),
                ),
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
    List<Widget> normalButtonList = [
      ButtonWidget(
        title: UtilService.getTextFromLang("createrequest", "สร้างคำขอ"),
        onPressed: openNewAbsentPage,
        color: const Color(0xFFFF8101),
        icon: Icons.arrow_circle_up_rounded,
      ),
      const SizedBox(width: 20),
      ButtonWidget(
        title: UtilService.getTextFromLang("cancelrequest", "ยกเลิกคำขอ"),
        onPressed: () {
          if (selectedId.isEmpty) {
            alertEmpty('โปรดเลือกรายการ');
            return;
          }
          onCancelSelected();
        },
        color: Colors.black,
        icon: Icons.arrow_circle_down_rounded,
      ),
    ];

    List<Widget> readOnlyButtonList = [
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFFFF8101),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          child: Text(
            UtilService.getTextFromLang("close", "ปิด"),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.lockAbsentType == null
            ? normalButtonList
            : readOnlyButtonList,
      ),
    );
  }

  Expanded buildTable() {
    bool withCheckBox = widget.lockAbsentType == null;
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
                child: requestList.isEmpty
                    ? Container()
                    : ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                        itemCount: requestListFiltered.length,
                        itemBuilder: (BuildContext context, int index) {
                          MyAbsentRequest itemRow = requestListFiltered[index];
                          bool selected =
                              selectedId.contains(itemRow.absentrequestid);
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
                            child: buildTableTile(
                              itemRow,
                              selected: selected,
                              withCheckBox: withCheckBox,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(itemRow.absenttype ?? ""),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
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
                                                color:
                                                    itemRow.hasRemark ?? false
                                                        ? Colors.orange
                                                        : Colors.grey,
                                              ),
                                            ),
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
                                              onTap: withCheckBox &&
                                                      itemRow.statusid ==
                                                          6100001
                                                  ? () => openNewAbsentPage(
                                                      request: itemRow)
                                                  : null,
                                              child: Icon(
                                                Icons.edit,
                                                color: withCheckBox &&
                                                        itemRow.statusid ==
                                                            6100001
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
                                        child: Text(
                                          UtilService.getTextFromLang(
                                              "start", "เริ่ม"),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                            '${itemRow.getStartdate()} ${itemRow.getStarttime()}'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          UtilService.getTextFromLang(
                                              "end", "สิ้นสุด"),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${itemRow.getEnddate()} ${itemRow.getEndtime()}',
                                        ),
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

  Widget buildTableTile(MyAbsentRequest itemRow,
      {required Widget child,
      bool selected = false,
      bool withCheckBox = true}) {
    if (withCheckBox) {
      return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.all(0),
          value: selected,
          onChanged: withCheckBox && itemRow.statusid == 6100001
              ? (selected) {
                  onSelectedRow(selected!, itemRow);
                }
              : null,
          title: child);
    } else {
      return ListTile(
        title: child,
      );
    }
  }

  Row buildTypeAbsent(BuildContext context) {
    int initialValue = -1;
    if (widget.lockAbsentType != null) {
      AbsentType a = absentTypeList
          .firstWhere((element) => element.key == widget.lockAbsentType);
      // orElse: () => null);
      initialValue = widget.lockAbsentType!;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            UtilService.getTextFromLang("absenttype", "ประเภท"),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: absentTypeList.isEmpty
              ? const Text('')
              : FormBuilderDropdown(
                  name: 'absenttypeid',
                  enabled: widget.lockAbsentType == null,
                  decoration: InputDecoration(
                    // labelText: 'เลือกประเภท',
                    // hintText: 'เลือกประเภท',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _fbKey.currentState!.fields['absenttypeid']?.reset();
                      },
                    ),
                  ),
                  initialValue: initialValue,
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

  void selectAbsentType(int? val) {
    print("select : $val");
    if (val == null || val == -1) {
      // ทั้งหมด
      if (mounted) {
        setState(() {
          requestListFiltered = requestList;
        });
      }
      return;
    }

    AbsentType? selectedType = absentTypeList.firstWhere(
        (type) => type.key == val); //, orElse: () => (null as int?));
    if (mounted) {
      setState(() {
        requestListFiltered = requestList
            .where((MyAbsentRequest req) => req.absenttype == selectedType.text)
            .toList();
      });
    }
  }

  void openNewAbsentPage({MyAbsentRequest? request}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => NewAbsentPage(
                  profile: widget.profile,
                  myAbsentRequest: request,
                  absentTypeList: absentTypeList.sublist(1),
                )))
        .then((value) {
      getMyAbsentRequest(_selectedYear);
    });
  }

  void onSelectedRow(bool selected, MyAbsentRequest itemRow) {
    setState(() {
      if (selected) {
        selectedId.add(itemRow.absentrequestid!);
        print(selectedId);
      } else {
        selectedId.removeWhere((id) => id == itemRow.absentrequestid);
        print(selectedId);
      }
    });
  }

  void onCancelSelected() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "We check",
      desc: "ต้องการยกเลิกรายการลาที่เลือก",
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
    DeleteMyAbsentRequestService deleteMyAbsentRequestService =
        DeleteMyAbsentRequestService();
    await deleteMyAbsentRequestService.deleteRequest(
        profile: widget.profile, listRequest: selectedId);
    Navigator.pop(context);
    selectedId.clear(); // Clear all selected

    setState(() {
      getMyAbsentRequest(_selectedYear);
    });
  }

  alertEmpty(title) {
    if (!isDialogShown) {
      isDialogShown = true;
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
            onPressed: () {
              isDialogShown = false;
              Navigator.pop(context);
            },
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

  // showAlert(GlobalKey locationKey, String title) {

  //   final renderObject = locationKey.currentContext!.findRenderObject();
  //   final translation = renderObject?.getTransformTo(null).getTranslation();
  //   final offset = Offset(translation!.x, translation.y);

  //   //renderObject!.paintBounds.shift(offset);

  //   // RenderBox renderBox = locationKey.currentContext.findRenderObject();
  //   // var offset = renderBox.localToGlobal(Offset.zero);
  //   Rect rect = Rect.fromLTWH(
  //       offset.dx, offset.dy, renderObject!.paintBounds.width, renderObject.paintBounds.height);
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

  downloadAttachFile(MyAbsentRequest request) async {
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
