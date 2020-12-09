import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/authentication/verification_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String verificationId;
  bool _visible = false;
  bool isLoading = false;

  void showShortToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }

  TextEditingController mobileController, smsController;

  GlobalKey<ScaffoldState> key = GlobalKey();
  @override
  void initState() {
    super.initState();
    mobileController = TextEditingController();
    smsController = TextEditingController();
    if (!mounted)
      Future.delayed(Duration(seconds: 5)).then((value) {
        setState(() {
          _visible = !_visible;
        });
      });
  }

  @override
  void dispose() {
    mobileController.dispose();
    smsController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91' + mobileController.text.trim(),
        timeout: const Duration(seconds: 120),
        verificationCompleted: (authCredential) {
          FirebaseAuth.instance.signInWithCredential(authCredential);
        },
        verificationFailed: (authException) {
          setState(() {
            isLoading = false;
          });
          print('${authException.message}');
          showShortToast('${authException.message}');
        },
        codeSent: (verificationId, [code]) {
          setState(() {
            isLoading = false;
          });
          print(code);
          showShortToast('Code sent');
          setState(() {
            this.verificationId = verificationId;
          });
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => VerificationPage(
              phone: mobileController.text.trim(),
              verificationId: verificationId,
            ),
          ));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          setState(() {
            isLoading = false;
          });
          setState(() {
            this.verificationId = verificationId;
          });
        });
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
                height: 260,
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
                        Text(
                          'Logo',
                          style: TextStyle(fontSize: 32),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        TextField(
                          controller: mobileController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Enter your Mobile Number',
                              border: OutlineInputBorder(),
                              hintText: 'Phone (Required)'),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        MaterialButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (mobileController.text.trim().isEmpty) {
                                    showShortToast("Please enter phone number");
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _sendOtp();
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
