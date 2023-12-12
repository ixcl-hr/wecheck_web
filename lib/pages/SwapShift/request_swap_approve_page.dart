import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../constants/constant.dart';
import '../../models/GetOTRequestModel.dart';
import '../../models/approver.dart';
import '../../models/profile.dart';
import '../../pages/OT/approve_ot_page.dart';
import '../../services/convert_date_service.dart';
import '../../services/convert_status_service.dart';
import '../../services/convert_time_service.dart';
import '../../services/delete_my_ot_request_service.dart';
import '../../services/get_ot_approver_service.dart';
import '../../services/get_ot_request_service.dart';
import '../../services/util_service.dart';

class RequestOTApprovePage extends StatefulWidget {
  final Profile profile;

  const RequestOTApprovePage({Key? key, required this.profile})
      : super(key: key);
  @override
  RequestOTApprovePageState createState() => RequestOTApprovePageState();
}

class RequestOTApprovePageState extends State<RequestOTApprovePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
  var timeNow = DateFormat('hh:mm').format(DateTime.now());

  DateTime selectedDate = DateTime.now();
  String date = "";
  bool isLoading = false;

  List<OTRequest> otRequestList = [];
  List<OTRequest> selectedRecords = [];
  List<Map<String, int>> selectedId = [];
  getAllOTRequest() async {
    setState(() {
      isLoading = true;
    });
    GetOTRequestService getOTRequestService = GetOTRequestService();
    otRequestList =
        await getOTRequestService.getOTRequest(profile: widget.profile);
    print("otRequestList length :  ${otRequestList.length}");
    // reversed
    setState(() {
      isLoading = false;
      otRequestList = otRequestList.reversed.toList();
      selectedRecords = [];
      selectedId = [];
    });
  }

  List<OTApprover> approverList = [];
  getOTApprover() async {
    GetOTApproverService approver = GetOTApproverService();
    approverList = await approver.getOTApprover(profile: widget.profile);

    setState(() {
      approverList = approverList;
    });
  }

  void onUnapproveOTSelected() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "We check",
      desc: "ต้องการไม่อนุมัติรายการที่เลือก",
      buttons: [
        DialogButton(
          onPressed: () async {
            GetOTRequestService getOTRequestService = GetOTRequestService();
            await getOTRequestService.unApproveOT(
                profile: widget.profile, listRequest: selectedId);
            selectedId = [];
            Navigator.pop(context);
            getAllOTRequest();
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

  @override
  void initState() {
    getAllOTRequest();
    getOTApprover();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
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
          Expanded(
            child: ButtonWidget(
              title: 'อนุมัติ',
              onPressed: () async {
                List<OTRequest> selectFull = [];

                print('selectedId $selectedId');

                for (var element in selectedId) {
                  if (element.isNotEmpty) {
                    var select = element['otrequestid'];
                    List<OTRequest> selectFull0 = otRequestList
                        .where((OTRequest e) => e.otrequestid == select)
                        .toList();
                    selectFull.addAll(selectFull0);
                  }
                }
                print("selectFull : $selectFull");
                if (selectFull.isEmpty) {
                  alertEmpty('โปรดเลือกรายการอนุมัติ');
                  return;
                }

                var returnCode = await showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (BuildContext context) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.95, //set this as you want
                      maxChildSize: 0.95, //set this as you want
                      minChildSize: 0.95, //set this as you want
                      expand: true,
                      builder: (context, scrollController) {
                        return ApproveOTScreen(
                          profile: widget.profile,
                          selectedIdList: selectFull,
                        );
                      },
                    );
                  },
                );
                if (returnCode == 200) {
                  print('returnCode $returnCode');
                  getAllOTRequest();
                }
                // var returnCode = await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => ApproveOTScreen(
                //       profile: widget.profile,
                //       selectedIdList: selectFull,
                //     ),
                //   ),
                // );
              },
              color: const Color(0xFFFF8101),
              icon: Icons.arrow_circle_up_rounded,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ButtonWidget(
              title: 'ไม่อนุมัติ',
              onPressed: () {
                List<OTRequest> selectFull = [];

                print('selectedId $selectedId');

                for (var element in selectedId) {
                  if (element.isNotEmpty) {
                    var select = element['otrequestid'];
                    List<OTRequest> selectFull0 = otRequestList
                        .where((OTRequest e) => e.otrequestid == select)
                        .toList();
                    selectFull.addAll(selectFull0);
                  }
                }
                print("selectFull : $selectFull");

                if (selectFull.isEmpty) {
                  alertEmpty('โปรดเลือกรายการ');
                  return;
                }
                onUnapproveOTSelected();
              },
              color: Colors.black,
              icon: Icons.arrow_circle_down_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildTable() {
    return Expanded(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20)),
                child: otRequestList.isEmpty
                    ? Container()
                    : Scrollbar(
                        child: ListView(
                          children: <Widget>[
                            const SizedBox(height: 10),
                            FittedBox(
                              child: DataTable(
                                  showCheckboxColumn: true,
                                  dataRowHeight: 180,
                                  columns: const [
                                    DataColumn(label: Text('', style: kLabel)),
                                    DataColumn(
                                        label: Text('ชื่อ / วันที่',
                                            style: kLabel)),
                                    DataColumn(
                                        label: Text('เวลา', style: kLabel)),
                                    DataColumn(
                                        label: Text('สถานะ', style: kLabel)),
                                  ],
                                  rows: otRequestList
                                      .map(
                                        (itemRow) => DataRow(
                                          color: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.08);
                                            }
                                            // if (itemRow.statusid == 6000001)
                                            //   return Colors.white38.withOpacity(0.1);
                                            if (itemRow.statusid == 6000002) {
                                              return const Color(0xFFBECFDE)
                                                  .withOpacity(0.5);
                                            }
                                            if (itemRow.statusid == 6000003) {
                                              return const Color(0xFFBECFDE)
                                                  .withOpacity(0.5);
                                            }
                                            return Colors.white;
                                          }),
                                          selected:
                                              selectedRecords.contains(itemRow),
                                          // onSelectChanged: (selected) {
                                          //   onSelectedRow(selected, itemRow);
                                          // },
                                          onSelectChanged:
                                              itemRow.statusid == 6000001
                                                  ? (selected) {
                                                      onSelectedRow(
                                                          selected ?? false,
                                                          itemRow);
                                                    }
                                                  : null,
                                          cells: [
                                            DataCell(Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const SizedBox(),
                                                Text(
                                                    itemRow.employeecode
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 28,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const Text('เริ่ม',
                                                    style: kDescription),
                                                const Text('สิ้นสุด',
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
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(
                                                        itemRow.employeename ??
                                                            "",
                                                        style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(
                                                        ConvertDate(itemRow
                                                                    .startdate)
                                                                .getDate() ??
                                                            "",
                                                        style: kDescription),
                                                    Text(
                                                        ConvertDate(itemRow
                                                                    .enddate)
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
                                                const Text('',
                                                    style: TextStyle(
                                                        fontSize: 30)),
                                                Text(
                                                    ConvertTime(itemRow
                                                                .starttime)
                                                            .getTime() ??
                                                        "",
                                                    style: kDescription),
                                                Text(
                                                    ConvertTime(itemRow.endtime)
                                                            .getTime() ??
                                                        "",
                                                    style: kDescription),
                                              ],
                                            )),
                                            DataCell(Row(
                                              children: [
                                                Text(
                                                  ConvertStatus(
                                                              statusid: itemRow
                                                                  .statusid)
                                                          .getStatusid() ??
                                                      "",
                                                  style: kStatus,
                                                )
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
            ),
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
          child: approverList == null
              ? const Text('')
              : FormBuilderDropdown(
                  decoration: InputDecoration(
                    labelText: UtilService.getTextFromLang(
                        "please_select", 'เลือกชื่อ'),
                    hintText: UtilService.getTextFromLang(
                        "please_select", 'เลือกชื่อ'),
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _fbKey.currentState!.fields['approverid']?.reset();
                      },
                    ),
                  ),
                  items: approverList.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text('${option.text}'),
                    );
                  }).toList(),
                  name: 'approverid',
                  validator: FormBuilderValidators.required(
                      errorText: UtilService.getTextFromLang(
                          "please_select", 'เลือกชื่อ')),
                ),
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
            validator:
                FormBuilderValidators.required(errorText: 'กรอกเวลาเริ่ม'),
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
          child: const Flexible(
            child: Text('เริ่ม'),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.40,
          child: FormBuilderDateTimePicker(
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
                    "please_select",
                    UtilService.getTextFromLang(
                        "please_select", 'กรอกเวลาสิ้นสุด'))),
          ),
        ),
      ],
    );
  }

  void onSelectedRow(bool selected, OTRequest itemRow) {
    setState(() {
      if (selected) {
        selectedRecords.add(itemRow);
        final Map<String, int> map = {"otrequestid": itemRow.otrequestid ?? -1};
        selectedId.add(map);
        print(selectedId);
      } else {
        selectedRecords
            .removeWhere((record) => record.otrequestid == itemRow.otrequestid);

        final Map<String, int> map = {"otrequestid": itemRow.otrequestid ?? -1};

        for (var element in selectedId) {
          element.removeWhere((key, value) => value == itemRow.otrequestid);
        }
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
    DeleteMyOTRequestService deleteMyOTRequestService =
        DeleteMyOTRequestService();
    await deleteMyOTRequestService.deleteMyOTRequest(
        profile: widget.profile, listRequest: selectedId);
    Navigator.pop(context);
    getAllOTRequest();
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
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
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
    );
  }
}
