import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import '../constants/config.dart';
import '../models/feedback.dart';
import '../models/profile.dart';

class ScanService {
  checkIn({
    required Profile profile,
    required latitude,
    required longitude,
    required typescan,
    required locationid,
    qrcode,
    required routerssid,
    required routerip,
    // @required needgps = null,
    // @required needqrcode = null,
    // @required needwifi = null,
    isactive = 'Y',
    attachfile,
    attachfiletype = '',
    attachcameraimg,
    attachcameraimgtype = '',
  }) async {
    var payload = convert.jsonEncode({
      "companyname": profile.companyname,
      "employeeid": profile.employeeid,
      "locationid": locationid,
      "latitude": latitude,
      "longitude": longitude,
      "qrcode": qrcode,
      "routermacaddress": routerip,
      "routerssid": routerssid,
      "scantype": typescan,
      "attachfile": attachfile,
      "attachfiletype": attachfiletype,
      "attachcameraimg": attachcameraimg,
      "attachcameraimgtype": attachcameraimgtype,
      "isactive": isactive,
    });
    print(payload);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };

    var url = '${ApiMaster}MobileScan';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    print(response.body);

    if (response.body.isEmpty) {
      print('Empty response body');
      return null;
    }

    try {
      Feedback feedback = Feedback.fromJson(convert.jsonDecode(response.body));
      if (feedback.flag == true) {
        return feedback;
        // Navigator.pop(context);
        // scanCheckIn(typeCheck: 'สแกนเวลาเข้า');
      } else if (feedback.flag == false) {
        return feedback;
        // Navigator.pop(context);
        // buildAlert(context, feedback).show();
        //
        // print('Error ลงเวลาไม่สำเร็จ');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
