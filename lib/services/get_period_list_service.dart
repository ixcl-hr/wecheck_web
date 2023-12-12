import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/GetPeriodListModel.dart';
import '../models/profile.dart';

class GetPeriodListService {
  GetPeriodListService();

  getData({required Profile profile, required int selectedYear}) async {
    List<Period> periodList = [];
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "startdate": '01/01/$selectedYear',
      "enddate": '31/12/$selectedYear',
    });
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetPeriodList';
    var response0 =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print('===>>  GetPeriodList from $selectedYear');
    // print(_response.body);
    // print(_response.statusCode);

    var response = convert.jsonDecode(response0.body);
    if (response['flag'] == true) {
      GetPeriodListModel feedback =
          GetPeriodListModel.fromJson(convert.jsonDecode(response0.body));
      return periodList = feedback.objectresult;
    } else {
      //print('Error Status : ${_response.body}');
      return periodList;
    }
  }
}
