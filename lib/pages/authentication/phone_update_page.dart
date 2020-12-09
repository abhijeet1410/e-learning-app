import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_view/pin_view.dart';

class PhoneUpdatePage extends StatefulWidget {
  final String phone, uid, verificationId;
  PhoneUpdatePage({this.phone, this.uid, this.verificationId});
  @override
  _PhoneUpdatePageState createState() => _PhoneUpdatePageState();
}

class _PhoneUpdatePageState extends State<PhoneUpdatePage> {
  String otp = '';
  Timer _timer;
  int _start = 60;
  bool isLoading = false;

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

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Update your phone',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 2.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter OTP',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 45,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Verification code has been sent to your \nregistered phone number',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 35.0),
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
                    otp = pin;
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
                      if (otp.isEmpty) {
                        showShortToast("Please enter OTP");
                      } else {
                        _updateAuth(widget.phone);
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
                width: MediaQuery.of(context).size.width / 1.5,
                child: Center(
                    child: isLoading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : Text(
                            'Update',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAuth(String phone) {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91' + phone,
        timeout: const Duration(minutes: 2),
        verificationCompleted: (credential) async {
          await (await FirebaseAuth.instance.currentUser())
              .updatePhoneNumberCredential(credential);
          print("updated");
          // either this occurs or the user needs to manually enter the SMS code
        },
        verificationFailed: null,
        codeSent: (verificationId, [forceResendingToken]) async {
          print("phonCode" + otp);
          String smsCode = otp;
          // get the SMS code from the user somehow (probably using a text field)
          final AuthCredential credential = PhoneAuthProvider.getCredential(
              verificationId: verificationId, smsCode: smsCode);
          await (await FirebaseAuth.instance.currentUser())
              .updatePhoneNumberCredential(credential);
          print("updated phone");
          updateDb(phone);
        },
        codeAutoRetrievalTimeout: null);
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

  void showShortToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }

  void updateDb(String phone) {
    Map<String, dynamic> data = {
      'phone': phone,
    };
    phone.isEmpty
        ? showShortToast('Empty')
        : Firestore.instance
            .collection('users')
            .document(widget.uid)
            .updateData(data)
            .then((result) {
            showShortToast('Phone number updated Successfully');
            Navigator.of(context).pop();
          }).catchError((e) {
            print(e.toString());
          });
  }
}
