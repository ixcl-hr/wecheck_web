import '../constants/config.dart';
import 'package:http/http.dart' as http;
import '../models/GetPersonalDetailModel.dart';
import 'dart:convert' as convert;

import '../models/profile.dart';

class GetPersonalDetailService {
  final profile;
  GetPersonalDetailService({
    required this.profile,
  });

  Future<PersonalDetail?> getData({required Profile profile}) async {
    PersonalDetail? personalDtl;
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "passcode": profile.passcode,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    var url = '${ApiMaster}GetEmployeeProfile/GetEmployeePersonalDetail';

    try {
      var response0 =
          await http.post(Uri.parse(url), headers: header, body: payload);
      print(response0.body);
      print(response0.statusCode);

      var response = convert.jsonDecode(response0.body);
      if (response['flag'] == true) {
        var result = response['objectresult'];
        personalDtl =
            PersonalDetail.fromJson(convert.jsonDecode(result)['data']);
        return personalDtl;
      } else {
        print('Error Status : ${response0.body}');
        return personalDtl;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
