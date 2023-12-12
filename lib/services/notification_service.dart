import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../models/profile.dart';

class NotificationService {
  Future<List<NotificationObject>> getAllNotification(
      {required Profile profile,
      DateTime? startdate,
      DateTime? enddate}) async {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    String payload = jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "startdate": startdate == null
          ? dateFormat.format(DateTime.now())
          : dateFormat.format(startdate),
      "enddate": enddate == null
          ? dateFormat.format(DateTime.now())
          : dateFormat.format(enddate),
    });
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };

    var url = '${ApiMaster}GetAllNotification';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    // print('_response.body');
    // print(_response.body);

    if (response.statusCode == 200) {
      debugPrint("Data posted successfully");
      final NotificationModel notification =
          NotificationModel.fromJson(jsonDecode(response.body));

      return notification.objectresult;
    } else {
      print("Something went wrong! Status Code is: ${response.statusCode}");
      // return [];
      return NotificationModel.fromJson(mock()).objectresult;
    }
  }

  Map<String, dynamic> mock() {
    return {
      'flag': true,
      'message': '',
      'objectresult': [
        {
          'notificationtype': 'AOT',
          'notificationdatetime': '24/08/2021 18:59',
          'employeecode': 'E0001',
          'employeename': 'นางผู้อนุมัติ ทดสอบ',
          'startdate': '04/08/2021',
          'starttime': '14:59',
          'oldlocationname': 'old',
          'oldisactive': 'Y',
          'enddate': '14/08/2021',
          'endtime': '08:59',
          'newlocationname': 'new',
          'newisactive': 'N',
        }
      ]
    };
  }
}
