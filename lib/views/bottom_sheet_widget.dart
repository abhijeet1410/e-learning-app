import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/authentication/phone_update_page.dart';
import 'package:learning_app/utils/check_internet.dart';

class BottomSheetItem extends StatefulWidget {
  final String phone, email, uid, age;
  BottomSheetItem({this.phone, this.email, this.uid, this.age});
  @override
  _BottomSheetItemState createState() => _BottomSheetItemState();
}

class _BottomSheetItemState extends State<BottomSheetItem> {
  TextEditingController _emailController, _phoneController, _ageController;
  bool _isEditEmail = false;
  bool _isEditPhone = false;
  bool _isEditAge = false;
  String verificationId = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = new TextEditingController(text: widget.email);
    _phoneController = new TextEditingController(text: widget.phone);
    _ageController = new TextEditingController(text: widget.age);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void showShortToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 24.0, top: 24.0),
              child: Text(
                'Edit Info',
                style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.email, color: Colors.black),
                onPressed: null,
              ),
              title: _isEditEmail
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(),
                      ),
                    )
                  : Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              trailing: _isEditEmail
                  ? isLoading
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.check,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            String email = _emailController.text.trim();
                            Map<String, dynamic> data = {
                              'email': email,
                            };
                            if (email.isNotEmpty) {
                              if (email == widget.email) {
                                setState(() {
                                  isLoading = false;
                                  _isEditEmail = false;
                                });
                              } else {
                                setState(() {
                                  isLoading = true;
                                });
                                Firestore.instance
                                    .collection('users')
                                    .document(widget.uid)
                                    .updateData(data)
                                    .then((result) {
                                  setState(() {
                                    isLoading = false;
                                    _isEditEmail = false;
                                  });
                                  Navigator.of(context).pop();
                                }).catchError((e) {
                                  isLoading = false;
                                  print(e.toString());
                                });
                              }
                            } else {
                              showShortToast('Enter email');
                            }
                          },
                        )
                  : IconButton(
                      icon: Icon(Icons.edit, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _isEditEmail = true;
                        });
                      },
                    ),
            ),
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.phone, color: Colors.black),
                onPressed: null,
              ),
              title: _isEditPhone
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(),
                      ),
                    )
                  : Text(
                      widget.phone,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              trailing: _isEditPhone
                  ? isLoading
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        )
                      : IconButton(
                          icon: Icon(Icons.check, color: Colors.black),
                          onPressed: () async {
                            String phone = _phoneController.text.trim();
                            if (phone.isEmpty) {
                              showShortToast('Enter Phone');
                            } else if (phone == widget.phone) {
                              setState(() {
                                isLoading = false;
                                _isEditPhone = false;
                              });
                            } else {
                              if (await NetworkUtils.isNetworkAvailable()) {
                                setState(() {
                                  isLoading = true;
                                });
                                _sendOtp(phone);
                              } else {
                                showShortToast('Check your connection');
                              }
                            }
                          },
                        )
                  : IconButton(
                      icon: Icon(Icons.edit, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _isEditPhone = true;
                        });
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.person, color: Colors.black),
                  onPressed: null,
                ),
                title: _isEditAge
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(),
                        ),
                      )
                    : Text(
                        widget.age + " yrs",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                trailing: _isEditAge
                    ? isLoading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : IconButton(
                            icon: Icon(Icons.check, color: Colors.black),
                            onPressed: () async {
                              String age = _ageController.text.trim();
                              Map<String, dynamic> data = {
                                'age': age,
                              };
                              if (age.isEmpty) {
                                showShortToast('Enter age to edit');
                              } else if (age == widget.age) {
                                setState(() {
                                  isLoading = false;
                                  _isEditAge = false;
                                });
                              } else {
                                setState(() {
                                  isLoading = true;
                                });
                                Firestore.instance
                                    .collection('users')
                                    .document(widget.uid)
                                    .updateData(data)
                                    .then((result) {
                                  setState(() {
                                    isLoading = false;
                                    _isEditAge = false;
                                  });
                                  Navigator.of(context).pop();
                                }).catchError((e) {
                                  isLoading = false;
                                  print(e.toString());
                                });
                              }
                            },
                          )
                    : IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _isEditAge = true;
                          });
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOtp(String phone) {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91' + phone,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (authCredential) {
          FirebaseAuth.instance.signInWithCredential(authCredential);
        },
        verificationFailed: (authException) {
          setState(() {
            isLoading = false;
          });
          showShortToast('${authException.message}');
        },
        codeSent: (verificationId, [code]) {
          showShortToast('Code sent');
          setState(() {
            isLoading = false;
            this.verificationId = verificationId;
          });
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PhoneUpdatePage(
              uid: widget.uid,
              phone: phone,
              verificationId: verificationId,
            ),
          ));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          setState(() {
            isLoading = false;
            this.verificationId = verificationId;
          });
        });
  }
}
