//import 'package:flutter_html/flutter_html.dart';
// import 'dart:html';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants/colors.dart';
import '../constants/config.dart';
import '../pages/scan_qrcode_page.dart';
// import '../screens/new_register_screen.dart';
import '../widgets/qrcode_scan_widget.dart';
import '../widgets/text_input_widget.dart';
import '../screens/otp_screen.dart';

class Register extends StatefulWidget {
  static const id = 'Register';

  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    initPrefs();
  }

  initPrefs() async {
    //await document.documentElement!.requestFullscreen();
    //window.history.pushState(null, 'wecheck', '#Register');
  }

  Future<void> Login() async {
    setState(() {
      isLoading = true;
    });
    var empCode = employeeCodeController.text;
    var email = emailController.text;
    var phoneno = '';
    var passcode = passCodeController.text;
    bool validField = true;

    if (email.isEmpty || passcode.isEmpty) {
      validField = false;
    }

    if (validField) {
      var jsonConvert = convert.jsonEncode({
        'employeecode': empCode,
        'phoneno': phoneno,
        'email': email,
        'passcode': passcode
      });

      var response = await http.post(Uri.parse('$ApiMaster/RequestEmployeeOTP'),
          body: jsonConvert, headers: {"Content-Type": "application/json"});
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              passcode: passcode,
              email: email,
            ),
          ),
        );
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
  }

  TextEditingController emailController = TextEditingController(
      text: kDebugMode
          ? "help.iexcellence@gmail.com" //"store.tester@iexcellence.cloud"
          : "");
  TextEditingController employeeCodeController = TextEditingController();
  TextEditingController passCodeController =
      TextEditingController(text: kDebugMode ? "FKNFvnnHwsE5" : "");

  @override
  Widget build(BuildContext context) {
    final emailField = TextInputWidget(
        hintText: "Email",
        iconWidget: Icon(
          Icons.email,
          color: colorOrange1,
        ),
        controller: emailController);
    final passcodeField = TextInputWidget(
        hintText: "Passcode",
        iconWidget: Icon(
          Icons.password_rounded,
          color: colorOrange1,
        ),
        controller: passCodeController);

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(36.0),
      color: colorOrange1,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        onPressed: () async {
          await Login();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    "Login",
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

    final ScanQrCodeButon = Material(
      elevation: 0.5,
      //borderRadius: BorderRadius.circular(36),
      //color: colorOrange1,
      child: MaterialButton(
        //minWidth: MediaQuery.of(context).size.width,
        //padding: const EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          String? qrcode = "";
          if (kDebugMode) {
            qrcode = "FKNFvnnHwsE5|help.iexcellence@gmail.com";
            print("qrcode: $qrcode");
            //print(Navigator.of(context).((ScanScreen.id) => false));
          } else {
            if (kIsWeb) {
              qrcode = await Navigator.of(context).push(MaterialPageRoute(
                  //builder: (context) => QrCodeScannerWidget.defaultStyle()));
                  builder: (context) => const ScanQrCodePage()));
            } else {
              qrcode = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => QrCodeScannerWidget.defaultStyle()));
            }
          }

          if (qrcode != null && qrcode.isNotEmpty) {
            List<String> qrToScan = qrcode.split('|');

            if (!kIsWeb) {
              emailController.text = qrToScan[1];
              passCodeController.text = qrToScan[0];
            } else {
              emailController.text = qrToScan[1].split(',')[0].trim();
              passCodeController.text = qrToScan[0].split(':')[1].trim();
            }

            await Login();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 50,
            ),
            // isLoading
            //     ? const Center(child: CircularProgressIndicator())
            //     : const Icon(
            //         Icons.crop_free_sharp,
            //         size: 50,
            //       ),
            // isLoading
            //     ? const Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 10),
            //         child: CircularProgressIndicator(
            //           backgroundColor: Colors.white,
            //         ),
            //       )
            //     : const Text('')
          ],
        ),
      ),
    );

    // final registerButon = Material(
    //   elevation: 1,
    //   borderRadius: BorderRadius.circular(36),
    //   color: Colors.white,
    //   child: MaterialButton(
    //     minWidth: MediaQuery.of(context).size.width,
    //     padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
    //     onPressed: () async{
    //           Navigator.of(context).push(
    //    MaterialPageRoute(builder: (context) => const NewRegisterScreen()));
    //     },
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(
    //           "ยังไม่ได้ลงทะเบียนกิจการ? ",
    //           textAlign: TextAlign.center,
    //           style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15.0)
    //               .copyWith(
    //             color: Colors.black,
    //             //fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         Text(
    //           "ทดลองใช้ฟรี",
    //           textAlign: TextAlign.center,
    //           style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17.0)
    //               .copyWith(
    //             color: colorOrange1,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

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
                    // Column(
                    //   children: <Widget>[
                    //     Text(
                    //       "Login",
                    //       style: TextStyle(color: colorOrange1, fontSize: 25),
                    //     ),
                    //   ],
                    // ),
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
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: Column(
                        children: <Widget>[passcodeField],
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
                          const SizedBox(height: 20),
                          const Text(
                            "or scan qrcode",
                            textScaleFactor: 1.5,
                          ),
                          const SizedBox(height: 10),
                          ScanQrCodeButon,
                          const SizedBox(height: 10),

                          // Platform.isIOS
                          //     ? const SizedBox(height: 1)
                          //     : registerButon,
                          // const SizedBox(height: 15),
                          // InkWell(
                          //     child: const Text('นโยบายความเป็นส่วนตัว'),
                          //     onTap: () => UtilService.launchInBrowser(
                          //         'https://hrmobile.iexcellence.cf/policy/privacy-policy-th.html')),
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(
                    //       left: 30, right: 30, bottom: 20),
                    //   child: Column(
                    //     children: <Widget>[registerButon],
                    //   ),
                    // ),
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
