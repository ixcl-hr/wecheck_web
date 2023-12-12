import '../constants/config.dart';

import 'package:http/http.dart' as http;
import '../models/AdjustApproverModel.dart';
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetAdjustApproverService {
  List<AdjustApprover> absentRequestList = [];

  Future<List<AdjustApprover>> getApprover({required Profile profile}) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });

    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetAdjustApprover';

    try {
      var response =
          await http.post(Uri.parse(url), headers: header, body: payload);

      AdjustApproverModel feedback =
          AdjustApproverModel.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return absentRequestList = feedback.objectresult;
      } else {
        return absentRequestList = [];
      }
    } catch (e) {
      return [];
    }
  }
}
