import 'dart:ui';
import 'package:flutter/material.dart';

Color color1 = HexColor("#69BDF9"); //แดง
Color color2 = HexColor("#0082E6"); //สีฟ้า
Color color3 = HexColor("#69BDF9"); //สีฟ้า
Color colorOrange1 = HexColor("#FFA500"); //สีแสด
Color colorOrangeDeep1 = HexColor("#FF7043"); //สีส้มเข้ม
Color colorWhite1 = HexColor("#FFFFFF"); //สีขาว
Color colorWhite2 = HexColor("#FFFFF0"); //สีขาว
Color colorBlack = HexColor("#000000"); //สีขาว

Color colorTextPrimary = HexColor("#000000"); //สีดำ
Color colorTextSecondary = colorWhite1;

int fontHeadLine = 20;
int fontNormal = 16;
int fontsmall = 14;
int fontsmallest = 12;

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
