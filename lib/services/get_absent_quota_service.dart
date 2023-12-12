import 'package:flutter/widgets.dart';
import '../constants/config.dart';
import '../models/GetAbsentQuotaModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetAbsentQuotaService {
  final profile;
  GetAbsentQuotaService({
    @required this.profile,
  });

  Future getData({required Profile profile, required int selectedYear}) async {
    List<AbsentQuota> absentQuota = [];
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "year": selectedYear
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetAbsentQuota';

    try {
      var response0 =
          await http.post(Uri.parse(url), headers: header, body: payload);
      print('===>>  GetAbsentQuota');
      print(response0.body);
      print(response0.statusCode);

      var response = convert.jsonDecode(response0.body);
      if (response['flag'] == true) {
        GetAbsentQuotaModel feedback =
            GetAbsentQuotaModel.fromJson(convert.jsonDecode(response0.body));
        return absentQuota = feedback.objectresult;
      } else {
        print('Error Status : ${response0.body}');
        return absentQuota;
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
