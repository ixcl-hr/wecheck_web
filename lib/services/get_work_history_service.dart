import '../constants/config.dart';
import '../models/GetWorkHistoryModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetWorkHistoryService {
  Future<List<WorkHistory>> getData(
      {required Profile profile, String? firstDay, String? lastDay}) async {
    List<WorkHistory> workHistory = [];
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "startdate": firstDay,
      "enddate": lastDay
    });
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetWorkHistory';

    var response0 =
        await http.post(Uri.parse(url), headers: header, body: payload);
    //print('===>>  GetWorkHistory');
    //print(_response.body);
    var response = convert.jsonDecode(response0.body);
    if (response['flag'] == true) {
      GetWorkHistoryModel feedback =
          GetWorkHistoryModel.fromJson(convert.jsonDecode(response0.body));
      return workHistory = feedback.objectresult;
    } else {
      print('Error Status : ${response0.body}');
      return workHistory;
    }
  }
}
