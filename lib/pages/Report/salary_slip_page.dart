import 'dart:convert' as convert;
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
import '../../models/GetPeriodListModel.dart';
import '../../models/GetSlipModel.dart';
import '../../models/profile.dart';
import '../../services/get_period_list_service.dart';
import '../../services/get_slip_service.dart';
// import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:developer';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import '../../services/util_service.dart';

class SalarySlipPage extends StatefulWidget {
  final Profile profile;

  const SalarySlipPage({Key? key, required this.profile}) : super(key: key);
  @override
  SalarySlipPageState createState() => SalarySlipPageState();
}

class SalarySlipPageState extends State<SalarySlipPage> {
  bool isLoading = false;
  int _selectedYear = DateTime.now().year;
  List<Period> periodList = [];

  @override
  void initState() {
    super.initState();

    changeSelectedYear(_selectedYear);
  }

  changeSelectedYear(int year) async {
    setState(() {
      isLoading = true;
      _selectedYear = year;
    });

    GetPeriodListService getPeriodListService = GetPeriodListService();
    periodList = await getPeriodListService.getData(
        profile: widget.profile, selectedYear: _selectedYear);

    setState(() {
      periodList = periodList;
      isLoading = false;
    });
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
          'Pay Slip',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(25),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => changeSelectedYear(_selectedYear - 1),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => showDialog(
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
                                      changeSelectedYear(dateTime.year);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          child: Text(
                            _selectedYear.toString(),
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () => changeSelectedYear(_selectedYear + 1),
                      ),
                    ],
                  ),
                  Text(
                      UtilService.getTextFromLang("remark_secure_payslip",
                          "***เอกสารมีการเข้ารหัสด้วย เลข 4 ตัวท้ายของเลขบัตรประชาชน***"),
                      style: const TextStyle(fontSize: 16, color: Colors.red)),
                  buildTable(),
                ],
              ),
            ),
    );
  }

  Widget buildTable() {
    return Expanded(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                UtilService.getTextFromLang("period", 'งวด'),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Expanded(
                        //   flex: 1,
                        //   child: Container(
                        //     decoration: const BoxDecoration(
                        //       border: Border(
                        //         top: BorderSide(
                        //           color: Colors.black,
                        //           width: 1.0,
                        //         ),
                        //         bottom: BorderSide(
                        //           color: Colors.black,
                        //           width: 1.0,
                        //         ),
                        //         right: BorderSide(
                        //           color: Colors.black,
                        //           width: 1.0,
                        //         ),
                        //       ),
                        //     ),
                        //     child: const Center(
                        //       child: Text(
                        //         '',
                        //         style: TextStyle(
                        //           fontSize: 18.0,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    periodList.isEmpty
                        ? Container()
                        : Expanded(
                            child: ListView.builder(
                                itemCount: periodList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Period p = periodList[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? 10.0 : 0.0,
                                      left: 5.0,
                                      right: 5.0,
                                      bottom: 10.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Center(
                                            child: Text(
                                              p.getPeriodString(),
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Center(
                                                  child: InkWell(
                                                    onTap: () {
                                                      getSlip(
                                                          p.periodid ?? -1,
                                                          p.getPeriodString(),
                                                          false);
                                                    },
                                                    child: const Icon(
                                                      Icons.download,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: InkWell(
                                                    onTap: () {
                                                      getSlip(
                                                          p.periodid ?? -1,
                                                          p.getPeriodString(),
                                                          true);
                                                    },
                                                    child: const Icon(
                                                      Icons.share,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  // getSlip(int periodId, bool isShare) async {
  //   // Show alert dialog
  //   showAlertLoading(context);

  //   GetSlipService getSlipService = GetSlipService();
  //   SlipModel? slip = await getSlipService.getData(
  //       profile: widget.profile, periodId: periodId);
  //   print('Open slip: ${slip!.filename ?? ""}');

  //   // Get temporary directory and write file
  //   Directory directory = await getTemporaryDirectory();
  //   String savePath = '${directory.path}/${slip.filename}';
  //   File file = File(savePath);
  //   Uint8List data = convert.base64Decode(slip.attachfile ?? "");
  //   await file.writeAsBytes(data);

  //   // Dismiss alert dialog
  //   Navigator.of(context).pop();

  //   if (isShare) {
  //     imagePaths = [];
  //     imagePaths.add(file.path);
  //     _onShare(context);
  //   } else // Open file
  //     OpenFile.open(file.path);
  // }

  getSlip(int periodId, String periodName, bool isShare) async {
    // Show alert dialog
    showAlertLoading(context);

    GetSlipService getSlipService = GetSlipService();
    SlipModel? slip = await getSlipService.getData(
        profile: widget.profile, periodId: periodId);
    print('Open slip: ${slip!.filename ?? ""}');

    // Get temporary directory and write file
    // Directory directory = await getTemporaryDirectory();
    //String savePath = '${directory.path}/${slip.filename}';
    //File file = File(savePath);
    Uint8List data = convert.base64Decode(slip.attachfile ?? "");
    //await file.writeAsBytes(data);

    MimeType type = MimeType.PDF;
    String path = await FileSaver.instance
        .saveFile("PaySlip_$periodName", data, "pdf", mimeType: type);
    log(path);

    // Dismiss alert dialog
    Navigator.of(context).pop();

    if (isShare) {
      imagePaths = [];
      imagePaths.add(path);
      _onShare(context);
    } else {
      if (!kIsWeb) OpenFilex.open(path);
    }
  }

  String text = '';
  String subject = '';
  List<String> imagePaths = [];

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
}
