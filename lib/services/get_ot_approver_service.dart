import '../constants/config.dart';
import '../models/approver.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetOTApproverService {
  Future getOTApprover({required Profile profile}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetOTApprover';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);
      // print(_response.body);
      if (response.statusCode == 200) {
        OTApproverModel feedback =
            OTApproverModel.fromJson(convert.jsonDecode(response.body));
        return feedback.objectresult;
      } else {
        throw response.statusCode;
      }
    } catch (e) {
      print(e);
    }
  }
}
