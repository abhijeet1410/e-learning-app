import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_app/pages/authentication/login_page.dart';
import 'package:learning_app/pages/courses/course_details_page.dart';
import 'package:learning_app/views/bottom_sheet_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _email, _phone, _age;
  String _uid;
  File _image;
  bool isEmptyList = false;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    uploadPhoto();
  }

  void uploadPhoto() {
    if (_image == null) {
      return;
    } else {
      FirebaseAuth.instance.currentUser().then((user) {
        if (user != null) {
          setState(() {
            _uid = user.uid;
          });
          String uid = user.uid;
          FirebaseStorage.instance
              .ref()
              .child('user profile photo')
              .child('$uid.jpg')
              .putFile(_image)
              .onComplete
              .then((res) {
            FirebaseStorage.instance
                .ref()
                .child('user profile photo')
                .child('$uid.jpg')
                .getDownloadURL()
                .then((res) {
              String dpUrl = res.toString();
              Map<String, dynamic> data = {'dp': dpUrl};
              Firestore.instance
                  .collection('users')
                  .document(uid)
                  .updateData(data)
                  .then((res) {})
                  .catchError((error) {
                print(error.toString());
              });
            });
          });
        }
      });
    }
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        FirebaseAuth.instance.signOut().then((value) =>
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()),
                (route) => false));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Logout?"),
      content: Text("Are you sure you want to logout?"),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 2.0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.black),
            onPressed: () => showAlertDialog(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<FirebaseUser>(
            future: FirebaseAuth.instance.currentUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _uid = snapshot.data.uid;
                String uid = snapshot.data.uid;
                return StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance
                      .collection('users')
                      .document(uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      DocumentSnapshot data = snapshot.data;
                      List<dynamic> myCourseList = data['myCourses'] as List;
                      if (myCourseList == null) {
                        isEmptyList = true;
                      }
                      _email = data['email'];
                      _phone = data['phone'];
                      _age = data['age'];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Positioned(
                                  child: Container(
                                margin: const EdgeInsets.only(top: 32.0),
                                height: 120,
                                width: 120,
                                child: CircularProgressIndicator(
                                  value: 0.85,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey),
                                ),
                              )),
                              Positioned(
                                left: 3,
                                top: 3,
                                bottom: 3,
                                right: 3,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 32.0),
                                  height: 120,
                                  width: 120,
                                  child: CircleAvatar(
                                    backgroundImage: _image == null
                                        ? NetworkImage('${data['dp']}')
                                        : FileImage(_image),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 120,
                                left: 85,
                                height: 30,
                                width: 30,
                                child: FloatingActionButton(
                                  mini: true,
                                  onPressed: getImage,
                                  tooltip: 'Pick Image',
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${data['name']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black),
                          ),
                          Container(
                            padding: EdgeInsets.all(4.0),
                            decoration: new BoxDecoration(
                              color: Colors
                                  .white, //new Color.fromRGBO(255, 0, 0, 0.0),
                              borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  topRight: const Radius.circular(20.0),
                                  bottomLeft: const Radius.circular(20.0),
                                  bottomRight: const Radius.circular(20.0)),
                            ),
                            child: Text(
                              '1200 Point',
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Personal Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.black,
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    _settingModalBottomSheet(context);
                                  },
                                  textColor: Colors.blue,
                                  child: Text('Edit'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            height: 1,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            leading: IconButton(
                              icon: Icon(Icons.email, color: Colors.black),
                              onPressed: null,
                            ),
                            title: Text(
                              '${data['email']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: IconButton(
                              icon: Icon(Icons.call, color: Colors.black),
                              onPressed: null,
                            ),
                            title: Text(
                              '+91 ${data['phone']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: IconButton(
                              icon: Icon(Icons.person, color: Colors.black),
                              onPressed: null,
                            ),
                            title: Text(
                              '${data['age']} yrs',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  isEmptyList
                                      ? 'Popular Courses'
                                      : 'My courses',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            height: 1,
                            color: Colors.grey,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: isEmptyList
                                ? Firestore.instance
                                    .collection('courses')
                                    .limit(4)
                                    .snapshots()
                                : Firestore.instance
                                    .collection('courses')
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot coursesQuery = snapshot.data;
                                List<DocumentSnapshot> purchasedCourses = [];
                                if (!isEmptyList) {
                                  coursesQuery.documents.forEach((element) {
                                    if (myCourseList
                                        .contains(element.documentID)) {
                                      purchasedCourses.add(element);
                                    }
                                  });
                                }
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 8.0),
                                  height: 150,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    physics: ScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: isEmptyList
                                        ? 3
                                        : purchasedCourses.length,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot dat;
                                      if (isEmptyList) {
                                        dat = coursesQuery.documents[index];
                                      } else {
                                        dat = purchasedCourses[index];
                                      }
                                      return InkWell(
                                        onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CourseDetailsPage(
                                                      doc: dat,
                                                    ))),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: AspectRatio(
                                              aspectRatio: 9 / 5.5,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      '${dat['logo']}'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Container(),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  void _settingModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext bc) {
          return BottomSheetItem(
            phone: _phone,
            email: _email,
            uid: _uid,
            age: _age,
          );
        });
  }
}
