import 'package:intl/intl.dart';
import '../constants/config.dart';

import 'package:http/http.dart' as http;
import '../models/GetAbsentRequestModel.dart';
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetAbsentRequestService {
  List<AbsentRequest> absentRequestList = [];
  var dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());

  DateTime yesterdayDate = DateTime.now();
  DateTime tomorrowDate = DateTime.now();

  Future getRequest({required Profile profile}) async {
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
    var url = '${ApiMaster}GetAbsentRequest';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);
      print(response.body);
      GetAbsentRequestModel feedback =
          GetAbsentRequestModel.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return absentRequestList = feedback.objectresult;
      } else {
        return absentRequestList = [];
      }
    } catch (e) {
      print(e);
    }
  }

  unApprove({required Profile profile, required listRequest}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "absentrequestidtlist": listRequest
    });

    print("payload");
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}UnapproveAbsent';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);

    //print(_response.body);
    if (response.statusCode == 200) {
      print("UnapproveAbsent successfully");
    } else {
      print(
          "UnapproveAbsent went wrong! Status Code is: ${response.statusCode}");
    }
  }

  onApprove({required Profile profile, required listRequest}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "absentrequestidtlist": listRequest
    });

    print("payload");
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}ApproveAbsent';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);

    print(response.body);
    if (response.statusCode == 200) {
      print("ApproveAbsent successfully");
    } else {
      print("ApproveAbsent went wrong! Status Code is: ${response.statusCode}");
    }
  }
}
