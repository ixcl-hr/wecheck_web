import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constants/colors.dart';
import '../constants/config.dart';
import '../constants/constant.dart';
import 'package:http/http.dart' as http;
import '../models/authen.dart';
import '../models/profile.dart';
import '../services/util_service.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen(
      {super.key,
      this.passcode,
      this.email,
      this.newEmail,
      this.isGuestCheckOut});
  // final String employeecode;
  // final String phoneno;
  final String? passcode;

  final String? email;
  final String? newEmail;
  final bool? isGuestCheckOut;

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  // Constants
  final int time = 900;
  AnimationController? _controller;

  // Variables
  Size? _screenSize;
  int? _currentDigit;
  int? _firstDigit;
  int? _sixDigit;
  int? _secondDigit;
  int? _thirdDigit;
  int? _fourthDigit;
  int? _firehDigit;

  Timer? timer;
  int? totalTimeInSeconds;
  bool? _hideResendButton;

  String userName = "";
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  // Returns "Appbar"
  get _getAppbar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
          padding: const EdgeInsets.only(top: 25),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange[900] as Color,
                Colors.orange[800] as Color,
                Colors.orange[600] as Color,
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.only(
              bottom: 10,
              left: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/images/scan1.png",
                        width: 30,
                        height: 30,
                      ),
                      const Text(
                        " WeCheck",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    ],
                  ),
                ),
                Container(
                  child: const Row(
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const MaterialButton(
                  onPressed: null,
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  // Return "Verification Code" label
  get _getVerificationCodeLabel {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        "ยืนยัน OTP",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 28.0, color: Colors.black, fontFamily: fontFamilyCustom),
      ),
    );
  }

  // Return "Email" label
  get _getEmailLabel {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 30, left: 10, right: 10),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamilyCustom),
      ),
    );
  }

  get _getContacLabel {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Return "OTP" input field
  get _getInputField {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
        _otpTextField(_firehDigit),
        _otpTextField(_sixDigit),
      ],
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          color: colorWhite2,
          image: const DecorationImage(
            image: AssetImage(
              "assets/images/S30092003.png",
            ),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
//          fit: BoxFit.cover
          )),
      child: SingleChildScrollView(
        child: Column(
//        mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            _getVerificationCodeLabel,
                            _getEmailLabel,
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 60, right: 60),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: <Widget>[
                                  _getInputField,
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  _getTimerText,
                                  _getResendButton,
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(),
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.white,
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            offset: Offset(0, 0))
                                      ],
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        _getOtpKeyboard,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Returns "Timer" label
  get _getTimerText {
    return SizedBox(
      height: 32,
      child: Offstage(
        offstage: !_hideResendButton!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.access_time),
            const SizedBox(
              width: 5.0,
            ),
            OtpTimer(_controller!, 15.0, Colors.black)
          ],
        ),
      ),
    );
  }

  // Returns "Resend" button
  get _getResendButton {
    return Padding(
      padding: const EdgeInsets.only(left: 70.0, right: 70),
      child: GestureDetector(
        onTap: () {
          clearOtp();
          _startCountdown();
        },
        child: const Text(
          "ส่ง OTP อีกครั้ง",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Returns "Resend" button
  get _getVerifyButton {
    return SizedBox(
      height: 50,
      width: 200,
      child: MaterialButton(
          splashColor: Colors.red.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          color: Colors.blueAccent,
          onPressed: () {
            // You can dall OTP verification API.
          },
          child: const Text(
            "Verify OTP",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          )),
    );
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return SizedBox(
        height: _screenSize!.width - 80,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: _sixDigit != null,
                    child: _otpKeyboardActionButton(
                        label: Icon(
                          Icons.check_circle,
                          color: colorOrange1,
                          size: 35,
                        ),
                        onPressed: () async {
                          // setState(() {
                          //   isLoading = true;
                          // });
                          // otp = _firstDigit.toString() +
                          //     _secondDigit.toString() +
                          //     _thirdDigit.toString() +
                          //     _fourthDigit.toString() +
                          //     _firehDigit.toString() +
                          //     _sixDigit.toString();
                          // var jsonBody = convert.jsonEncode(
                          //   {
                          //     // 'employeecode': widget.employeecode,
                          //     'passcode': widget.passcode,
                          //     // 'phoneno': widget.phoneno,
                          //     'otp': otp,
                          //   },
                          // );

                          // var response = await http.post(
                          //   Uri.parse(ApiMaster + '/RegisterEmployee'),
                          //   headers: {"Content-Type": "application/json"},
                          //   body: jsonBody,
                          // );

                          // var feedback = convert.jsonDecode(response.body);
                          // if (feedback['flag'] == true) {
                          //   var valueJson =
                          //       Profile.fromJson(feedback['objectresult']);
                          //   var authenJson =
                          //       Authen.fromJson(feedback['objectresult']);

                          //   await UtilService.setSharedPreferences(
                          //       'token', convert.jsonEncode(valueJson));

                          //   await UtilService.setSharedPreferences(
                          //       'authen', convert.jsonEncode(authenJson));

                          //   await UtilService.setSharedPreferences('session_id',
                          //       feedback['objectresult']['sessionid']);

                          //   setState(() {
                          //     isLoading = false;
                          //   });

                          //   Navigator.pushNamedAndRemoveUntil(context,
                          //       '/splash', (Route<dynamic> route) => false);
                          // } else if (feedback['flag'] == false) {
                          //   setState(() {
                          //     isLoading = false;
                          //   });
                          //   //print(feedback);
                          //   Alert(
                          //     context: context,
                          //     type: AlertType.warning,
                          //     title: "แจ้งเตือน",
                          //     desc: feedback["message"],
                          //     buttons: [
                          //       DialogButton(
                          //         child: const Text(
                          //           "ตกลง",
                          //           style: TextStyle(
                          //               color: Colors.white, fontSize: 20),
                          //         ),
                          //         onPressed: () {
                          //           Navigator.pop(context);
                          //         },
                          //         width: 120,
                          //       )
                          //     ],
                          //   ).show();
                          // }
                        }),
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: const Icon(
                        Icons.backspace,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sixDigit != null) {
                            _sixDigit = null;
                          } else if (_firehDigit != null) {
                            _firehDigit = null;
                          } else if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  // Overridden methods
  @override
  void initState() {
    totalTimeInSeconds = time;
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !_hideResendButton!;
              });
            }
          });
    _controller!
        .reverse(from: _controller!.value == 0.0 ? 1.0 : _controller!.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _getAppbar,
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: _screenSize!.width,
              child: _getInputPart,
            ),
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int? digit) {
    return Container(
      width: 40.0,
      height: 50.0,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          //            color: Colors.grey.withOpacity(0.4),
          border: Border(
        bottom: BorderSide(
          width: 2.0,
          color: Colors.orange,
        ),
        top: BorderSide(
          width: 2.0,
          color: Colors.orange,
        ),
        left: BorderSide(
          width: 2.0,
          color: Colors.orange,
        ),
        right: BorderSide(
          width: 2.0,
          color: Colors.orange,
        ),
      )),
      child: Text(
        digit != null ? digit.toString() : "",
        style: const TextStyle(
          fontSize: 30.0,
          color: Colors.black,
        ),
      ),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton(
      {required String label, VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40.0),
        child: Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({required Widget label, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        height: 90.0,
        width: 90.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) async {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      } else if (_firehDigit == null) {
        _firehDigit = _currentDigit;
      } else
        _sixDigit ??= _currentDigit;
    });

    if (_sixDigit != null) {
      await _readyOTP();
    }
  }

  Future _readyOTP() async {
    setState(() {
      isLoading = true;
    });
    otp = _firstDigit.toString() +
        _secondDigit.toString() +
        _thirdDigit.toString() +
        _fourthDigit.toString() +
        _firehDigit.toString() +
        _sixDigit.toString();
    var jsonBody = convert.jsonEncode(
      {
        // 'employeecode': widget.employeecode,
        'passcode': widget.passcode,
        // 'phoneno': widget.phoneno,
        'otp': otp,
        'language': language,
      },
    );

    var response = await http.post(
      Uri.parse('$ApiMaster/RegisterEmployee'),
      headers: {"Content-Type": "application/json"},
      body: jsonBody,
    );

    var feedback = convert.jsonDecode(response.body);
    if (feedback['flag'] == true) {
      var valueJson = Profile.fromJson(feedback['objectresult']);
      var authenJson = Authen.fromJson(feedback['objectresult']);

      await UtilService.setSharedPreferences(
          'token', convert.jsonEncode(valueJson));

      await UtilService.setSharedPreferences(
          'authen', convert.jsonEncode(authenJson));

      await UtilService.setSharedPreferences(
          'session_id', feedback['objectresult']['sessionid']);

      await UtilService.reToken();

      setState(() {
        isLoading = false;
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/splash', (Route<dynamic> route) => false);
    } else if (feedback['flag'] == false) {
      setState(() {
        isLoading = false;
      });
      //print(feedback);
      Alert(
        context: context,
        type: AlertType.warning,
        title: "แจ้งเตือน",
        desc: feedback["message"],
        buttons: [
          DialogButton(
            onPressed: () {
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
    }
  }

  Future<void> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    // _controller!
    //     .reverse(from: _controller!.value == 0.0 ? 1.0 : _controller!.value);
    _controller!.reverse(from: 1.0);
  }

  void clearOtp() {
    _sixDigit = null;
    _firehDigit = null;
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;

    setState(() {});
  }
}

class OtpTimer extends StatelessWidget {
  AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor, {super.key});

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration? get duration {
    Duration? duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Text(
            timerString,
            style: TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
