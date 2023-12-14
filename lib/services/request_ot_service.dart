import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:wecheck/services/util_service.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class RequestOTService {
  requestOT(Profile profile, payload, context) async {
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    String url = '${ApiMaster}RequestOT';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    var feedback = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (feedback['flag'] == true) {
        showAlert(
            context,
            UtilService.getTextFromLang(
                'ot_request_success', 'สร้างคำขอทำโอทีสำเร็จ'),
            AlertType.success, () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {
        print(feedback['message']);
        showAlert(context, feedback['message'].toString(), AlertType.error, () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    } else {
      print(feedback['approverid']);
      showAlert(context, 'เกิดข้อผิดพลาดในการเชื่อมต่อ', AlertType.error, () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  showAlert(BuildContext context, String title, AlertType alertType,
      void Function()? onPressed) {
    Alert(
      style: const AlertStyle(
          isCloseButton: false,
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false),
      context: context,
      type: alertType,
      title: title,
      buttons: [
        DialogButton(
          color: const Color(0xFFFF8101),
          onPressed: onPressed,
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }
}
