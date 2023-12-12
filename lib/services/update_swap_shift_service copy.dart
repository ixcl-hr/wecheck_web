import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class UpdateSwapShiftService {
  UpdateSwapShift(Profile profile, payload, context) async {
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    String url = '${ApiMaster}UpdateSwapShift';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    var feedback = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (feedback['flag'] == true) {
        Alert(
          style: const AlertStyle(
              isCloseButton: false,
              animationType: AnimationType.grow,
              isOverlayTapDismiss: false),
          context: context,
          type: AlertType.success,
          title: 'แก้ไขคำขอทำโอทีสำเร็จ',
          buttons: [
            DialogButton(
              color: const Color(0xFFFF8101),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              width: 120,
              child: const Text(
                "ตกลง",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ).show();
      } else {
        print(feedback['message']);
      }
    } else {
      print(feedback['approverid']);
    }
  }
}
