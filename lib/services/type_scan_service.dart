import '../constants/config.dart';
import '../models/feedback.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class TypeScan {
  Future getTypeScan({required Profile profile}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetScanType';

    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    // print('GetScanType');
    // print(_response.body);
    if (response.statusCode == 200) {
      Feedback feedback = Feedback.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return feedback.objectresult;
      } else if (feedback.flag == false) {
        return '';
        // return feedback.objectresult;
      }
    } else {
      print('Error Status : ${response.body}');
    }
  }
}
