import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/authentication/sign_up_page.dart';
import 'package:learning_app/pages/home/home_page.dart';
import 'package:pin_view/pin_view.dart';

class VerificationPage extends StatefulWidget {
  final String phone;
  final String verificationId;

  VerificationPage({this.verificationId, this.phone});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  TextEditingController smsController;
  Timer _timer;
  int _start = 60;
  bool isLoading = false;
  String enteredOtp = '';

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  void showShortToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }

  void _sendOtp(String veriId) {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91' + widget.phone,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (authCredential) {
          FirebaseAuth.instance.signInWithCredential(authCredential);
        },
        verificationFailed: (authException) {
          print('${authException.message}');
          showShortToast('${authException.message}');
        },
        codeSent: (verificationId, [code]) {
          showShortToast('Code sent');
          setState(() {
            veriId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          setState(() {
            veriId = verificationId;
          });
        });
  }

  void _verifyPhone() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: widget.verificationId, smsCode: enteredOtp);
    final FirebaseUser user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        //showShortToast('Successfully signed in, uid: ' + user.uid);
        Firestore.instance
            .collection('users')
            .document(user.uid)
            .get()
            .then((snapshot) {
          if (snapshot == null || !snapshot.exists) {
            // widget.onSignUp(user.uid,widget.phone);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SignUpPage(
                        uid: user.uid,
                        phone: widget.phone,
                      )),
            );
            isLoading = false;
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage()),
              (route) => false,
            );
            isLoading = false;
          }
        });
      } else {
        isLoading = false;
        //key.currentState.showSnackBar(SnackBar(content: Text('Failed'),));
      }
    });
  }

  @override
  void initState() {
    startTimer();
    smsController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    smsController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: Colors.deepPurpleAccent,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                height: 355,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 68.0),
                              child: Text(
                                'Enter OTP',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 4, top: 8, bottom: 8),
                          height: 2,
                          color: Colors.grey[200],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Verification code has been sent to your registered phone number',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: PinView(
                              count: 6,
                              autoFocusFirstField: false,
//                              sms: SmsListener (
//                                  from: "6505551212",
//                                  formatBody: (String body){
//                                    String codeRaw = body.split(": ")[1];
//                                    List<String> code = codeRaw.split("-");
//                                    return code.join();
//                                  }
//                              ),
                              submit: (String pin) {
                                enteredOtp = pin;
                                //_verifyPhone();
                              } // gets triggered when all the fields are filled
                              ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(_start < 10 ? '00:0$_start' : '00:$_start'),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('If you did not get it yet? '),
                            FlatButton(
                                onPressed: _start == 0
                                    ? () {
                                        print("here");
                                        _sendOtp(widget.verificationId);
                                        startTimer();
                                        setState(() {
                                          _start = 60;
                                        });
                                      }
                                    : null,
                                textColor: Colors.blue,
                                child: Text('Resend')),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MaterialButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (enteredOtp.isEmpty) {
                                    showShortToast("Please enter OTP");
                                  } else {
                                    _verifyPhone();
                                    setState(() {
                                      isLoading = true;
                                    });
                                  }
                                },
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          color: Colors.blueAccent,
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                      )
                                    : Text(
                                        'Next',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
