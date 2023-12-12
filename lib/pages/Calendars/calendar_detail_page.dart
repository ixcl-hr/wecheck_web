import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:core';
import '../../models/history.dart';
import '../../models/profile.dart';
import '../../pages/Calendars/adjust_time_page.dart';
import '../../pages/map_view_page.dart';
import '../../services/convert_date_service.dart';
import '../../services/convert_time_service.dart';
import '../../services/get_attach_file_service.dart';
import '../../services/history_service.dart';
import '../../services/util_service.dart';

class CalendarDetailPage extends StatefulWidget {
  final String dateSelected;
  final Profile profile;

  const CalendarDetailPage(
      {Key? key, required this.dateSelected, required this.profile})
      : super(key: key);
  @override
  _CalendarDetailPageState createState() => _CalendarDetailPageState();
}

class _CalendarDetailPageState extends State<CalendarDetailPage> {
  @override
  void initState() {
    getHistoryScan();
    super.initState();
  }

  List<History> historyList = [];

  List<History> reversedHistoryList = [];
  bool isLoading = false;
  getHistoryScan() async {
    setState(() {
      isLoading = true;
    });
    HistoryService historyService = HistoryService();
    historyList = await historyService.getScanHistory(
        profile: widget.profile, day: widget.dateSelected);
    setState(() {
      isLoading = false;
      if (historyList.isNotEmpty) {
        reversedHistoryList = historyList.reversed.toList();
      } else {
        reversedHistoryList = historyList;
      }
      // reversedHistoryList = historyList;
    });
    // sortDate(historyList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8101),
        title: Text(
            UtilService.getTextFromLang("timework_detail", "รายละเอียดงาน")),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: Column(
                children: [
                  buildHistory(context),
                ],
              ),
            ),
      bottomNavigationBar: buildBottomButton(context),
    );
  }

  Container buildBottomButton(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(55, 0, 55, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWidget(
            title: UtilService.getTextFromLang("back", "กลับ"),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.orange,
            icon: Icons.arrow_back_ios,
          ),
        ],
      ),
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

  downloadAttachFile(History histObj) async {
    var payload = convert.jsonEncode({
      "companyname": widget.profile.companyname,
      "employeeid": widget.profile.employeeid,
      "requesttype": "SC",
      "requestid": histObj.scanid,
    });
    //print(payload);
    showAlertLoading(context);
    GetAttachFileService getAttachFileService = GetAttachFileService();
    await getAttachFileService.getAttachFile(widget.profile, payload, context);
  }
/*
  Expanded buildHistory() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Scrollbar(
            child: ListView(
              // reverse: true,
              children: <Widget>[
                SizedBox(height: 5),
                Center(
                    child: Text(
                  'วันที่ ${widget.dateSelected}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                SizedBox(height: 10),
                reversedHistoryList.length == 0
                    ? Container()
                    : FittedBox(
                        child: DataTable(
                          // sortAscending: false,
                          // sortColumnIndex: 0,
                          dataRowHeight: 70,
                          columns: [
                            DataColumn(
                              label: Text('วัน', style: kLabel),
                            ),
                            DataColumn(label: Text('เวลา', style: kLabel)),
                            DataColumn(label: Text('เข้า/ออก', style: kLabel)),
                            DataColumn(label: Text('วิธีแสกน', style: kLabel)),
                          ],
                          rows: reversedHistoryList
                              .map(
                                (itemRow) => DataRow(
                                  cells: [
                                    DataCell(Text(
                                        ConvertDate(itemRow.scandate)
                                                .getDate() ??
                                            "",
                                        style: kDescription)),
                                    DataCell(Text(
                                        ConvertTime(itemRow.scantime)
                                                .getTime() ??
                                            "",
                                        style: kDescription)),
                                    DataCell(Align(
                                      alignment: Alignment.center,
                                      child: Text(itemRow.scanid ?? "-",
                                          style: kDescription),
                                    )),
                                    DataCell(
                                      Align(
                                          alignment: Alignment.center,
                                          child: itemRow.scantype == 'I'
                                              ? Text("เข้า",
                                                  style: kDescription)
                                              : Text("ออก",
                                                  style: kDescription)),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

  Expanded buildHistory(BuildContext context) {
    return Expanded(
      child: Container(
        // height: availableHeight,
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
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 5),
              Center(
                  child: Text(
                UtilService.getTextFromLang("date", "วันที่") +
                    ' ${widget.dateSelected}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(UtilService.getTextFromLang("date", "วัน"),
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(UtilService.getTextFromLang("time", "เวลา"),
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                        UtilService.getTextFromLang("in", "เข้า") +
                            "/" +
                            UtilService.getTextFromLang("out", "ออก"),
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                        UtilService.getTextFromLang("scantype", "วิธีสแกน"),
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ]),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                              color: Colors.grey,
                            ),
                        itemCount: reversedHistoryList.length,
                        itemBuilder: (context, index) {
                          return buildScanDetailItem(
                              reversedHistoryList[index]);
                        })),
              ),
            ],
          ),
        ),
      ),
    );
  }
// }

  Widget buildScanDetailItem(History histObj) {
    TextStyle style = const TextStyle(fontSize: 14);
    String gpsDataString = "";
    if (histObj.latitude != null) {
      gpsDataString += histObj.latitude!.toStringAsFixed(6);
    }
    if (histObj.longitude != null) {
      gpsDataString += ', ${histObj.longitude!.toStringAsFixed(6)}';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(histObj.locationcaption ?? "", style: style),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                if (histObj.isattachfile == 'Y')
                  InkWell(
                      child: const Icon(
                        Icons.attach_file,
                        size: 20.0,
                        color: Colors.orange,
                      ),
                      onTap: () {
                        print('get file');
                        downloadAttachFile(histObj);
                      }),
                if (histObj.isattachfile == 'N')
                  const InkWell(
                      child: Icon(
                    Icons.attach_file,
                    size: 20.0,
                    color: Colors.grey,
                  )),
                InkWell(
                    child: const Icon(
                      Icons.edit,
                      size: 20.0,
                      color: Colors.orange,
                    ),
                    onTap: () {
                      print('Edit pressed');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AdjustTimePage(
                                    profile: widget.profile,
                                    adjustRequestId: 0,
                                    history: histObj,
                                  )));
                    }),
              ],
            )
          ],
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              flex: 1,
              child: Text(ConvertDate(histObj.scandate ?? "").getDate() ?? "",
                  style: style),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(ConvertTime(histObj.scantime ?? "").getTime() ?? "",
                    style: style),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: histObj.scantype == 'I'
                    ? Text(UtilService.getTextFromLang("in", "เข้า"),
                        style: style)
                    : Text(UtilService.getTextFromLang("out", "ออก"),
                        style: style),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (histObj.needqrcode == 'Y')
                    InkWell(
                        child: const Icon(
                          Icons.qr_code,
                          size: 20.0,
                          color: Colors.orange,
                        ),
                        onTap: () {
                          print('qr code');
                        }),
                  if (histObj.needgps == 'Y')
                    InkWell(
                        child: const Icon(Icons.location_pin,
                            size: 20.0, color: Colors.orange),
                        onTap: () {
                          print('gps');
                        }),
                  if (histObj.needwifi == 'Y')
                    InkWell(
                        child: const Icon(Icons.wifi,
                            size: 20.0, color: Colors.orange),
                        onTap: () {
                          print('wifi');
                        }),
                  // Icon(Icons.location_pin)
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              flex: 1,
              child: Text('GPS:', style: style),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(gpsDataString, style: style),
                  if (gpsDataString != '')
                    InkWell(
                        child: const Icon(Icons.location_history,
                            size: 20.0, color: Colors.orange),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MapViewPage(
                                      lat: histObj.latitude ?? 0,
                                      lng: histObj.longitude ?? 0)));
                          // MaterialPageRoute(
                          //     builder: (_) => MapViewerPage(
                          //         profile: widget.profile,
                          //         lat: histObj.latitude,
                          //         lng: histObj.longitude)));
                          // MapWidget(
                          // lat: histObj.latitude, lng: histObj.longitude);
                        }),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              flex: 1,
              child: Text('SSID:', style: style),
            ),
            Expanded(
              flex: 2,
              child: Text(histObj.routerssid ?? '-', style: style),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              flex: 1,
              child: Text('Mac Address:', style: style),
            ),
            Expanded(
              flex: 2,
              child: Text(histObj.routermacaddress ?? '-', style: style),
            ),
          ],
        )
      ],
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
  final void Function() onPressed;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
