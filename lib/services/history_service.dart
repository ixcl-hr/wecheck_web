import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../constants/config.dart';
import '../models/history.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../models/profile.dart';

class HistoryService {
  DateTime today = DateTime.now();

  List<History> historyList = [];

  String dateSelect = "";
  String dateStart = "";
  getScanHistory({required Profile profile, day}) async {
    print('day : $day');
    if (day == null) {
      dateSelect = DateFormat('dd/MM/yyyy').format(today);
      // DateTime _dateStart = today.subtract(new Duration(days: 0));
      // dateStart = new DateFormat('dd/MM/yyyy').format(_dateStart);
    } else {
      dateSelect = day;
    }
    print('dateStart : $dateStart');
    print('dateSelect : $dateSelect');

    print('getScanHistoryDetail');
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "startdate": dateSelect,
      "enddate": dateSelect
    });

    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    print('payload $payload');
    var url = '${ApiMaster}GetScanHistoryDetail';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print('_response.body');
    print(response.body);
    if (response.statusCode == 200) {
      debugPrint("Data posted successfully");
      final HistoryModel history =
          HistoryModel.fromJson(convert.jsonDecode(response.body));

      return history.objectresult;
    } else {
      print("Something went wrong! Status Code is: ${response.statusCode}");
      return historyList = [];
    }
    // var feedback = convert.jsonDecode(_response.body);
    // print(feedback['objectresult']);
  }

  // List<History> getScanHistories() {
  //   return historyList;
  // }
}
