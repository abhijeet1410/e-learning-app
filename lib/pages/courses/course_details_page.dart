import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/courses/course_info_page.dart';
import 'package:learning_app/pages/courses/episode/episode_page.dart';
import 'package:learning_app/views/gradient_text.dart';
import 'package:learning_app/views/payment_failure_page.dart';
import 'package:learning_app/views/payment_successful_page.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'course_video_play_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final DocumentSnapshot doc;
  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
  CourseDetailsPage({this.doc});
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  bool isExpand = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    double price = double.parse(widget.doc['price']);
    price += 100;
    return Scaffold(
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
                  if (myCourseList != null &&
                      myCourseList.contains(widget.doc.documentID)) {
                    return SingleChildScrollView(
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: 9 / 5,
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            '${widget.doc['logo']}'),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: FloatingActionButton(
                                            heroTag: "backBtn",
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            mini: true,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              color: Colors.blue,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: FloatingActionButton(
                                            heroTag: "infoBtn",
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CourseInfoPage(
                                                              doc:
                                                                  widget.doc)));
                                            },
                                            mini: true,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.info_outline,
                                              color: Colors.black,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 62.0, left: 16.0, right: 16.0),
                                  child: GradientText(
                                    text: widget.doc['name'],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(12),
                                  height: 1,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                StreamBuilder<QuerySnapshot>(
                                    stream: Firestore.instance
                                        .collection('chapters')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot chaptersQuery =
                                            snapshot.data;
                                        List<DocumentSnapshot> chaptersList =
                                            [];
                                        chaptersQuery.documents
                                            .forEach((element) {
                                          if (widget.doc.documentID ==
                                              element['courseId']) {
                                            chaptersList.add(element);
                                          }
                                        });
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: chaptersList.map((item) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16),
                                                    child: Text(
                                                      '${item['name']}',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 22),
                                                    )),
                                                Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 18,
                                                      vertical: 12),
                                                  color: Colors.grey,
                                                  height: 1,
                                                ),
                                                StreamBuilder<QuerySnapshot>(
                                                    stream: Firestore.instance
                                                        .collection('episodes')
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        QuerySnapshot
                                                            episodesQuery =
                                                            snapshot.data;
                                                        List<DocumentSnapshot>
                                                            episodesList = [];
                                                        episodesQuery.documents
                                                            .forEach((element) {
                                                          if (item.documentID ==
                                                              element[
                                                                  'chapterId']) {
                                                            episodesList
                                                                .add(element);
                                                          }
                                                        });
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 2.0,
                                                                  horizontal:
                                                                      16.0),
                                                          height: 150,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child:
                                                              ListView.builder(
                                                            physics:
                                                                ScrollPhysics(),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                episodesList
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final DocumentSnapshot
                                                                  episodeSnapshot =
                                                                  episodesList[
                                                                      index];
                                                              if (episodesList
                                                                  .isEmpty) {
                                                                return Center(
                                                                    child: Text(
                                                                        'Episodes Coming soon'));
                                                              } else {
                                                                return InkWell(
                                                                  onTap: () => Navigator.of(
                                                                          context)
                                                                      .push(MaterialPageRoute(
                                                                          builder: (context) => EpisodePage(
                                                                                episodeId: '${episodeSnapshot.documentID}',
                                                                                url: '${episodeSnapshot['audio']}',
                                                                                appBarTitle: '${episodeSnapshot['name']}',
                                                                                episodeDetails: '${episodeSnapshot['details']}',
                                                                              ))),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            12),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Card(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                100,
                                                                            width:
                                                                                160,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              child: Image(
                                                                                fit: BoxFit.cover,
                                                                                image: NetworkImage('${episodeSnapshot['logo']}'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              vertical: 4,
                                                                              horizontal: 4),
                                                                          child:
                                                                              Text('${episodeSnapshot['name']}'),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        );
                                                      } else {
                                                        return Center(
                                                            child:
                                                                CircularProgressIndicator());
                                                      }
                                                    })
                                              ],
                                            );
                                          }).toList(),
                                        );
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    }),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 160,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                height: 120,
                                width: 180,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            'https://img.youtube.com/vi/5aPahOD4ssk/default.jpg'),
                                      ),
                                    ),
                                    Positioned.fill(
                                        child: Container(
                                      color: Colors.black54,
                                    )),
                                    Positioned.fill(
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => VideoPlayPage(
                                              videoId: '5aPahOD4ssk',
                                              appBarTitle: widget.doc['name'],
                                            ),
                                          ));
                                        },
                                        icon: Icon(
                                          Icons.play_arrow,
                                          size: 48,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned.fill(
                                      top: 84,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Text(
                                          'Course demo video',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: 9 / 5,
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            '${widget.doc['logo']}'),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: FloatingActionButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        mini: true,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.blue,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 62.0, left: 16.0, right: 16.0),
                                  child: GradientText(
                                    text: widget.doc['name'],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0, top: 8.0),
                                  child: Text(
                                    widget.doc['description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, left: 16.0),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 2.0,
                                            bottom: 2.0),
                                        decoration: new BoxDecoration(
                                          color: Colors
                                              .blue, //new Color.fromRGBO(255, 0, 0, 0.0),
                                          borderRadius: new BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(20.0),
                                              topRight:
                                                  const Radius.circular(20.0),
                                              bottomLeft:
                                                  const Radius.circular(20.0),
                                              bottomRight:
                                                  const Radius.circular(20.0)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'New',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, left: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 2.0,
                                            bottom: 2.0),
                                        decoration: new BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: new BorderRadius.only(
                                                topLeft:
                                                    const Radius.circular(20.0),
                                                topRight:
                                                    const Radius.circular(20.0),
                                                bottomLeft:
                                                    const Radius.circular(20.0),
                                                bottomRight:
                                                    const Radius.circular(
                                                        20.0)),
                                            border: Border.all(
                                              color: Colors.grey[
                                                  800], // <--- border color
                                              width: 1.0,
                                            )),
                                        child: Center(
                                          child: Text(
                                            'Updated 04/2020',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 12.0, left: 12.0, right: 12.0),
                                  height: 1,
                                  color: Colors.grey,
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, left: 16.0),
                                      child: Text(
                                        '₹${widget.doc['price']}',
                                        style: TextStyle(
                                            fontSize: 28,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, left: 16.0),
                                      child: Text(
                                        '₹$price',
                                        style: TextStyle(
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    'Save upto 60%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0,
                                      left: 48,
                                      right: 48,
                                      bottom: 16.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      var _razorpay = Razorpay();
                                      var options = {
                                        'key': 'rzp_test_cIOVPpM3WgAt47',
                                        'amount': int.parse(
                                            widget.doc['price'] + '00'),
                                        'name': '${widget.doc['name']}',
                                        'description':
                                            '${widget.doc['description']}',
                                        'prefill': {
                                          'contact': '9438560593',
                                          'email': 'abhijeet34m@gmail.com'
                                        }
                                      };
                                      _razorpay.open(options);
                                      new Timer.periodic(Duration(seconds: 5),
                                          (Timer t) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      });
                                      _razorpay
                                          .on(Razorpay.EVENT_PAYMENT_SUCCESS,
                                              (response) {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentSuccessfulPage()))
                                            .then((value) {
                                          List<String> list = new List();
                                          list.add(widget.doc.documentID);
                                          Map<String, dynamic> data = {
                                            'myCourses':
                                                FieldValue.arrayUnion(list)
                                          };
                                          FirebaseAuth.instance
                                              .currentUser()
                                              .then((user) => {
                                                    Firestore.instance
                                                        .collection('users')
                                                        .document(user.uid)
                                                        .updateData(data)
                                                        .then((result) {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Payment Successfull",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        timeInSecForIosWeb: 1,
                                                      );
                                                    }).catchError((error) {})
                                                  });
                                        });
                                      });
                                      _razorpay.on(
                                          Razorpay.EVENT_PAYMENT_ERROR,
                                          (response) => {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PaymentFailurePage()))
                                              });
                                    },
                                    child: isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                            ),
                                          )
                                        : Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                gradient: LinearGradient(
                                                    begin: Alignment.topRight,
                                                    end: Alignment.bottomLeft,
                                                    colors: [
                                                      Color(0xFF00D2FF),
                                                      Color(0xFF1D60BC)
                                                    ])),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: Text(
                                                'Buy Now',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 8.0),
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, left: 16.0, right: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'This course includes',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 20),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 8.0),
                                            height: 1,
                                            color: Colors.grey,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.blueAccent,
                                                  size: 24.0,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text('6 hours on-demand audio')
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.blueAccent,
                                                  size: 24.0,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text('Support Files')
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.blueAccent,
                                                  size: 24.0,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text('Full time Access')
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, bottom: 16.0),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.blueAccent,
                                                  size: 24.0,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    'Certification of Completion')
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 8.0),
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, left: 16.0, right: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Course Details',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 20),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                  'Total Chapters (${widget.doc['chapters']}),'),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                  'Total Episodes (${widget.doc['episodes']})'),
                                            ],
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 12.0),
                                            height: 1,
                                            color: Colors.grey,
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                              stream: Firestore.instance
                                                  .collection('chapters')
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  QuerySnapshot chaptersQuery =
                                                      snapshot.data;
                                                  List<DocumentSnapshot>
                                                      chaptersList = [];
                                                  chaptersQuery.documents
                                                      .forEach((element) {
                                                    if (widget.doc.documentID ==
                                                        element['courseId']) {
                                                      chaptersList.add(element);
                                                    }
                                                  });
                                                  return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: chaptersList
                                                          .map((item) {
                                                        return ExpansionTile(
                                                            children: <Widget>[
                                                              StreamBuilder<
                                                                      QuerySnapshot>(
                                                                  stream: Firestore
                                                                      .instance
                                                                      .collection(
                                                                          'episodes')
                                                                      .snapshots(),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                        .hasData) {
                                                                      QuerySnapshot
                                                                          episodesQuery =
                                                                          snapshot
                                                                              .data;
                                                                      List<DocumentSnapshot>
                                                                          episodesList =
                                                                          [];
                                                                      episodesQuery
                                                                          .documents
                                                                          .forEach(
                                                                              (element) {
                                                                        if (item.documentID ==
                                                                            element['chapterId']) {
                                                                          episodesList
                                                                              .add(element);
                                                                        }
                                                                      });
                                                                      return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children:
                                                                            episodesList.map((item) {
                                                                          return Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 16,
                                                                                bottom: 8,
                                                                                right: 16),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  '${episodesList.indexOf(item) + 1}.  ' + item['name'],
                                                                                  style: TextStyle(
                                                                                    fontSize: 16,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                                Icon(
                                                                                  Icons.lock,
                                                                                  color: Colors.black,
                                                                                  size: 16,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                      );
                                                                    } else {
                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      );
                                                                    }
                                                                  })
                                                            ],
                                                            trailing: Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              size: 32,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            onExpansionChanged:
                                                                (value) {
                                                              chaptersList
                                                                  .clear();
                                                              setState(() {
                                                                isExpand =
                                                                    value;
                                                              });
                                                            },
                                                            title: Container(
                                                              width: double
                                                                  .infinity,
                                                              child: Text(
                                                                "${item['name']}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ));
                                                      }).toList());
                                                } else {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 160,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                height: 120,
                                width: 180,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            'https://img.youtube.com/vi/5aPahOD4ssk/default.jpg'),
                                      ),
                                    ),
                                    Positioned.fill(
                                        child: Container(
                                      color: Colors.black54,
                                    )),
                                    Positioned.fill(
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => VideoPlayPage(
                                              videoId: '5aPahOD4ssk',
                                              appBarTitle: widget.doc['name'],
                                            ),
                                          ));
                                        },
                                        icon: Icon(
                                          Icons.play_arrow,
                                          size: 48,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned.fill(
                                      top: 84,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Text(
                                          'Course demo video',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
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
      ),
    );
  }
}
