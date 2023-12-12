import 'package:intl/intl.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetWorkTimeService {
  Future<dynamic> getTime({required Profile profile, DateTime? date}) async {
    WorkTime? workTime;

    DateTime date0;
    if (date != null) {
      date0 = date;
    } else {
      date0 = DateTime.now();
    }
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "workdate": dateFormat.format(date0),
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetWorkTime';

    var response0 =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print('===>>  GetWorkTime');
    // print(_response.body);
    try {
      var response = convert.jsonDecode(response0.body);
      if (response['flag'] == true) {
        workTime = WorkTime.fromJson(response['objectresult'], date0);
        return workTime;
      } else {
        //print('Error Status : ${_response.body}');
        return workTime;
      }
    } catch (e) {
      //print('GetWorkTimeService error: $e');
      return null;
    }
  }
}

class WorkTime {
  String? starttime;
  String? endtime;
  DateTime? startDatetime;
  DateTime? endDatetime;

  WorkTime(this.starttime, this.endtime, DateTime date) {
    DateFormat dateFormat = DateFormat('HH:mm:ss');
    try {
      DateTime s = dateFormat.parse(starttime ?? "");
      DateTime e = dateFormat.parse(endtime ?? "");
      startDatetime =
          DateTime(date.year, date.month, date.day, s.hour, s.minute, s.second);
      endDatetime =
          DateTime(date.year, date.month, date.day, e.hour, e.minute, e.second);
    } catch (e) {
      print('GetWorkTimeService error: $e');
    }
  }

  WorkTime.fromJson(Map<String, dynamic> json, DateTime date) {
    starttime = json['starttime'] ?? "08:00:00";
    endtime = json['endtime'] ?? "17:00:00";

    if (starttime != null && endtime != null) {
      DateFormat dateFormat = DateFormat('HH:mm:ss');
      try {
        DateTime s = dateFormat.parse(starttime ?? "");
        DateTime e = dateFormat.parse(endtime ?? "");
        startDatetime = DateTime(
            date.year, date.month, date.day, s.hour, s.minute, s.second);
        endDatetime = DateTime(
            date.year, date.month, date.day, e.hour, e.minute, e.second);
      } catch (e) {
        print('GetWorkTimeService error: $e');
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['starttime'] = starttime;
    data['endtime'] = endtime;
    return data;
  }

  @override
  String toString() {
    return 'WorkTime: ${startDatetime ?? starttime} - ${endDatetime ?? endtime}';
  }
}
