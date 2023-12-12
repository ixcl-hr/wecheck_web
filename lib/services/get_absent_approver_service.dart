import '../constants/config.dart';
import '../models/AbsentApproverModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetAbsentApproverService {
  Future getDate({required Profile profile}) async {
    List<AbsentApprover> absentApproverList = [];
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetAbsentApprover';

    try {
      var response0 =
          await http.post(Uri.parse(url), headers: header, body: payload);
      // print(_response.body);
      var response = convert.jsonDecode(response0.body);
      if (response['flag'] == true) {
        AbsentApproverModel feedback =
            AbsentApproverModel.fromJson(convert.jsonDecode(response0.body));
        return absentApproverList = feedback.objectresult;
      } else {
        return absentApproverList;
      }
    } catch (e) {
      print(e);
    }
  }
}
