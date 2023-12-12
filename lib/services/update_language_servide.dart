import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../constants/config.dart';
import '../models/feedback.dart';
import '../models/profile.dart';

class UpdateLanguageService {
  final Profile profile;
  final String? language;
  UpdateLanguageService({required this.profile, this.language});
  Future<bool?> updateLanguageToServer() async {
    var payload = convert.jsonEncode({
      "employeeid": profile.employeeid,
      "passcode": profile.passcode,
      "language": language
    });
    //print('---payload--');
    //print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };

    var url = '${ApiMaster}SetLanguage';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);

    if (response.statusCode == 200) {
      Feedback feedback = Feedback.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        var result = convert.jsonDecode(response.body)['objectresult'];
        print(result);
        return true;
      } else if (feedback.flag == false) {
        print('Update language failure');
        return false;
      }
    } else {
      print('Request status : ${response.statusCode}');
      return false;
    }

    return null;
  }
}
