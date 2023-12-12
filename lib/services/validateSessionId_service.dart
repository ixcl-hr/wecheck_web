import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../constants/config.dart';
import '../models/authen.dart';
import '../models/feedback.dart';

class ValidateSessionIdService {
  final Authen authen;
  final String? sessionid;
  ValidateSessionIdService({required this.authen, this.sessionid});
  Future<bool?> validateSessionId() async {
    var payload = convert.jsonEncode({
      "passcode": authen.passcode,
      "sessionid": sessionid,
    });

    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authen.token}'
    };

    var url = '${ApiMaster}ValidateSessionId';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    if (response.statusCode == 200) {
      Feedback feedback = Feedback.fromJson(convert.jsonDecode(response.body));
      return feedback.flag;
    } else {
      print('Request status : ${response.statusCode}');
      return false;
    }
  }
}
