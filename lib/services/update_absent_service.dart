import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/profile.dart';

class UpdateAbsentService {
  onUpdate(Profile profile, payload, context) async {
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}'
    };
    String url = '${ApiMaster}UpdateAbsent';
    var response =
        await http.post(Uri.parse(url), headers: header, body: payload);
    var feedback = convert.jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (feedback['flag'] == true) {
        createAlertDialog(context, 'แก้ไขคำขอลางานสำเร็จ', true).show();
      } else {
        print(feedback['message']);
        createAlertDialog(
          context,
          feedback['message'] ?? 'แก้ไขคำขอลางานไม่สำเร็จ',
          false,
        ).show();
      }
    } else {
      print(feedback['approverid']);
      createAlertDialog(
        context,
        'แก้ไขคำขอลางานไม่สำเร็จ',
        false,
      ).show();
    }
  }

  Alert createAlertDialog(BuildContext context, String title, bool isSuccess) {
    return Alert(
      style: const AlertStyle(
        isCloseButton: false,
        animationType: AnimationType.grow,
        isOverlayTapDismiss: false,
      ),
      context: context,
      type: isSuccess ? AlertType.success : AlertType.error,
      title: title,
      buttons: [
        DialogButton(
          color: const Color(0xFFFF8101),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            if (isSuccess) {
              Navigator.pop(context);
            }
          },
          width: 120,
          child: const Text(
            "ตกลง",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    );
  }
}
