import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/views/all_courses_row.dart';

class MyCoursesPage extends StatefulWidget {
  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'My Courses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1.0,
        ),
        body: FutureBuilder<FirebaseUser>(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
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
                    bool isNotNullList = (myCourseList != null);
                    return isNotNullList
                        ? StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection('courses')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot coursesQuery = snapshot.data;
                                List<DocumentSnapshot> purchasedCourses = [];
                                coursesQuery.documents.forEach((element) {
                                  if (myCourseList
                                      .contains(element.documentID)) {
                                    purchasedCourses.add(element);
                                  }
                                });
                                return GridView.builder(
                                  itemCount: myCourseList.length,
                                  padding: const EdgeInsets.all(8),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                          childAspectRatio: 0.95),
                                  itemBuilder: (context, index) =>
                                      CoursesCard(purchasedCourses[index]),
                                );
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            })
                        : Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'You have not purchased any courses yet',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24),
                            ),
                          );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
