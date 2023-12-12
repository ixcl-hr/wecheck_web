import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../constants/config.dart';

import 'package:http/http.dart' as http;
import '../models/GetOTRequestModel.dart';
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetOTRequestService {
  List<OTRequest> oTRequestList = [];
  var dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());

  DateTime yesterdayDate = DateTime.now();
  DateTime tomorrowDate = DateTime.now();

  Future getOTRequest({required Profile profile}) async {
    yesterdayDate = yesterdayDate.subtract(const Duration(days: 31));
    var yesterday = DateFormat('dd/MM/yyyy').format(yesterdayDate);
    tomorrowDate = tomorrowDate.add(const Duration(days: 31));
    var tomorrow = DateFormat('dd/MM/yyyy').format(tomorrowDate);

    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "startdate": yesterday,
      "enddate": tomorrow,
    });
    print("payload");
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetOTRequest';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);
      print(response.body);
      GetOTRequestModel feedback =
          GetOTRequestModel.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return oTRequestList = feedback.objectresult;
      } else {
        return oTRequestList;
      }
    } catch (e) {
      print(e);
    }
  }

  unApproveOT({required Profile profile, @required listRequest}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "otrequestlist": listRequest
    });

    print("payload");
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}UnapproveOT';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);

    print(response.body);
    if (response.statusCode == 200) {
      print("UnapproveOT successfully");
    } else {
      print("Something went wrong! Status Code is: ${response.statusCode}");
    }
  }
}
