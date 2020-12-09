import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/pages/home/home_page.dart';

class SignUpPage extends StatefulWidget {
  final String uid;
  final String phone;
  SignUpPage({this.uid, this.phone});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<ScaffoldState> key = GlobalKey();
  TextEditingController nameController, ageController, emailController;
  bool isLoading = false;
  @override
  void initState() {
    nameController = TextEditingController();
    ageController = TextEditingController();
    emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
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
                height: 405,
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
                              padding: EdgeInsets.only(left: 58.0),
                              child: Text(
                                'Registration',
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
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter name",
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter age",
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter email",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        MaterialButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  String name = nameController.text.trim();
                                  String age = ageController.text.trim();
                                  String email = emailController.text.trim();
                                  if (name.trim().isEmpty) {
                                    key.currentState.showSnackBar(SnackBar(
                                      content: Text('Name is required'),
                                    ));
                                  } else if (age.trim().isEmpty) {
                                    key.currentState.showSnackBar(SnackBar(
                                      content: Text('Age is required'),
                                    ));
                                  } else if (email.trim().isEmpty) {
                                    key.currentState.showSnackBar(SnackBar(
                                      content: Text('Email is required'),
                                    ));
                                  } else {
                                    setState(() {
                                      setState(() {
                                        isLoading = true;
                                      });
                                    });
                                    Map<String, dynamic> data = {
                                      'name': name,
                                      'age': age,
                                      'email': email,
                                      'phone': widget.phone,
                                      'createdAt': DateTime.now(),
                                      'dp': ''
                                    };
                                    Firestore.instance
                                        .collection('users')
                                        .document(widget.uid)
                                        .setData(data)
                                        .then((result) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                HomePage()),
                                        (route) => false,
                                      );
                                    }).catchError((e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      print(e.toString());
                                    });
                                  }
                                },
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          color: Colors.blueAccent,
                          child: Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                      )
                                    : Text(
                                        'Get Started',
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
