import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../constants/config.dart';
import '../models/profile.dart';

class ApproveSwapShiftService {
  Future onApproveSwapShift(
      {required Profile profile, required listSwapShift}) async {
    var payload = convert.jsonEncode({
      "employeecode": profile.employeecode,
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "requestlist": listSwapShift
    });

    print("payload");
    // print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}ApproveSwapShift';
    var response0 =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print(response0.statusCode);
    var response = convert.jsonDecode(response0.body);
    print(response);
    if (response['flag'] == true) {
      print("ApproveSwapShift successfully");
      return;
    } else {
      print("Something went wrong! Status Code is: ${response.message}");
      return;
    }
  }
}