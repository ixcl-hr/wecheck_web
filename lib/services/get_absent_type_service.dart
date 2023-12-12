import '../constants/config.dart';
import '../models/absentTypeModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetAbsentTypeService {
  Future getData({required Profile profile}) async {
    List<AbsentType> absentType = [];
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
    });
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetAbsentType';

    try {
      var response0 =
          await http.post(Uri.parse(url), headers: header, body: payload);
      //print(_response.body);
      var response = convert.jsonDecode(response0.body);
      if (response['flag'] == true) {
        AbsentTypeModel feedback =
            AbsentTypeModel.fromJson(convert.jsonDecode(response0.body));
        return absentType = feedback.objectresult;
      } else {
        print('Error Status : ${response0.body}');
        return absentType;
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
