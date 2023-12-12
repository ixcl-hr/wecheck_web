import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/GetSlipModel.dart';
import '../models/profile.dart';

class GetSlipService {
  GetSlipService();

  Future<SlipModel?> getData(
      {required Profile profile, required int periodId}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "periodid": periodId,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetSlip';
    var response0 =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print('===>>  GetSlipService from $periodId');
    print(response0.body);
    print(response0.statusCode);

    var response = convert.jsonDecode(response0.body);
    if (response['flag'] == true) {
      GetSlipModel feedback =
          GetSlipModel.fromJson(convert.jsonDecode(response0.body));
      return feedback.objectresult;
    } else {
      print('Error Status : ${response0.body}');
      return null;
    }
  }
}
