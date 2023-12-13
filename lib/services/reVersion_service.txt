import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import '../constants/config.dart';
import '../models/appInfo.dart';
import '../models/feedback.dart';

class ReVersionService {
  ReVersionService();
  Future<bool?> getVersion() async {
    var header = {'Content-Type': 'application/json'};

    var url = '${ApiMaster}GetAppVersion';
    var response = await http.get(Uri.parse(url), headers: header);
    //print(_response.body);
    if (response.statusCode == 200) {
      print('Request status : ${response.statusCode}');
      Feedback feedback = Feedback.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        var result = convert.jsonDecode(response.body)['objectresult'];
        var valueJson = AppInfo.fromJson(result);
        //print(valueJson);
        await _initPrefs();
        await prefs.setString('appversion', convert.jsonEncode(valueJson));

        // await saveProfile(result['token'], result, profile);

        return true;
      } else if (feedback.flag == false) {
        print('Re-token failure');
        return false;
      }
    } else {
      print('Request status : ${response.statusCode}');
      return false;
    }
    return null;
  }

  late SharedPreferences prefs;
  _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}
