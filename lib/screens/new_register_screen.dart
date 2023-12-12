//import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:upgrader/upgrader.dart';

import '../constants/colors.dart';
import '../constants/config.dart';
// import '../screens/NewRegisterScreen.dart';
import '../widgets/text_input_widget.dart';

class NewRegisterScreen extends StatefulWidget {
  static const id = 'Register';

  const NewRegisterScreen({Key? key}) : super(key: key);

  @override
  NewRegisterScreenState createState() => NewRegisterScreenState();
}

class NewRegisterScreenState extends State<NewRegisterScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  String msgSendToEmail = "";
  TextEditingController emailController = TextEditingController(
      text: kDebugMode ? "help.iexcellence@gmail.com" : "");

  @override
  Widget build(BuildContext context) {
    final emailField = TextInputWidget(
        hintText: "Email",
        iconWidget: Icon(
          Icons.email,
          color: colorOrange1,
        ),
        controller: emailController);

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(36.0),
      color: colorOrange1,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          var email = emailController.text;

          bool validField = true;

          if (email.isEmpty) {
            validField = false;
          }

          if (validField) {
            var jsonConvert = convert.jsonEncode({
              'email': email,
            });

            var response = await http.post(
                Uri.parse('$ApiMaster/RequestRegisterLink'),
                body: jsonConvert,
                headers: {"Content-Type": "application/json"});
            var feedback = convert.jsonDecode(response.body);

            if (feedback['flag'] == true) {
              setState(() {
                isLoading = false;
              });

              await Alert(
                style: const AlertStyle(
                  isCloseButton: false,
                  animationType: AnimationType.grow,
                  isOverlayTapDismiss: false,
                ),
                context: context,
                type: AlertType.info,
                title: "ข้อมูล",
                desc: feedback['message'],
                buttons: [
                  DialogButton(
                    onPressed: () => Navigator.pop(context),
                    width: 120,
                    child: const Text(
                      "ตกลง",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ).show();

              Navigator.pop(context);
            } else {
              setState(() {
                isLoading = false;
              });
              Alert(
                style: const AlertStyle(
                  isCloseButton: false,
                  animationType: AnimationType.grow,
                  isOverlayTapDismiss: false,
                ),
                context: context,
                type: AlertType.warning,
                title: "แจ้งเตือน",
                desc: feedback['message'],
                buttons: [
                  DialogButton(
                    onPressed: () => Navigator.pop(context),
                    width: 120,
                    child: const Text(
                      "ตกลง",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ).show();
            }
          } else {
            setState(() {
              isLoading = false;
            });
            Alert(
              style: const AlertStyle(
                isCloseButton: false,
                animationType: AnimationType.grow,
                isOverlayTapDismiss: false,
              ),
              context: context,
              type: AlertType.warning,
              title: "แจ้งเตือน",
              desc: "กรุณากรอกข้อมูลให้ครบถ้วน",
              buttons: [
                DialogButton(
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                  child: const Text(
                    "ตกลง",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ],
            ).show();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    "ลงทะเบียน",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                            fontFamily: 'Montserrat', fontSize: 20.0)
                        .copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  )
                : const Text('')
          ],
        ),
      ),
    );

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: 230,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/images/S30092002.png"),
                                fit: BoxFit.fill),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        "assets/images/scan1.png",
                                        width: 120,
                                        height: 120,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "WeCheck - HRMI",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "ลงทะเบียน",
                          style: TextStyle(color: colorOrange1, fontSize: 25),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: Column(
                        children: <Widget>[emailField],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 30, right: 30, bottom: 20),
                      child: Column(
                        children: [
                          (isLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ),
                                )
                              : loginButon),
                          const SizedBox(height: 10),
                          Text(msgSendToEmail),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
