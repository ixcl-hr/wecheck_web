import 'package:flutter/material.dart';
import '../constants/colors.dart';

class TextInputWidget extends StatelessWidget {
  const TextInputWidget(
      {Key? key,
      this.hintText,
      this.iconImage,
      this.iconWidget,
      this.controller})
      : super(key: key);
  final String? hintText;
  final Image? iconImage;
  final Widget? iconWidget;
  final TextEditingController? controller;
  @override
  Container build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: colorOrange1, spreadRadius: 2)],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(
              icon: iconImage ?? iconWidget,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.yellow[800], fontSize: 18),
            ),
            style: TextStyle(color: colorOrange1, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
