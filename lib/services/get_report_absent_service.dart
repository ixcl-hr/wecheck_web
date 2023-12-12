import 'package:intl/intl.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/GetReportAbsentModel.dart';
import '../models/profile.dart';

class GetReportAbsentService {
  GetReportAbsentService();

  getData(
      {required Profile profile,
      required DateTime start,
      required DateTime end,
      List<dynamic>? depIds,
      int? empId,
      bool? isCheckMissing,
      bool? isCheckLeave,
      bool? isCheckLate,
      String? timeUnit}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "start": DateFormat('dd/MM/yyyy').format(start),
      "end": DateFormat('dd/MM/yyyy').format(end),
      "depIds": depIds,
      "empId": empId ?? "",
      "isCheckMissing": isCheckMissing,
      "isCheckLeave": isCheckLeave,
      "isCheckLate": isCheckLate,
      "timeUnit": timeUnit,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetRptAbsent/GetRptAbsent';
    var response0 =
        await http.post(Uri.parse(url), headers: header, body: payload);
    //print('===>>  GetReportAbsentService from $periodId');
    print(response0.body);
    print(response0.statusCode);

    var response = convert.jsonDecode(response0.body);
    if (response['flag'] == true) {
      GetReportAbsentModel feedback =
          GetReportAbsentModel.fromJson(convert.jsonDecode(response0.body));
      return feedback.objectresult;
    } else {
      print('Error Status : ${response0.body}');
      return null;
    }
  }

  Future getInitialData({required Profile profile}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetRptAbsent/GetInitialFilterData';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);
      // print(_response.body);
      if (response.statusCode == 200) {
        // GetDepartmentListModel feedback =
        //     GetDepartmentListModel.fromJson(convert.jsonDecode(_response.body));
        return response.body;
      } else {
        throw response.statusCode;
      }
    } catch (e) {
      print(e);
    }
  }
}
