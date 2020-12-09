import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/pages/courses/all_courses_page.dart';
import 'package:learning_app/pages/courses/my_courses_page.dart';
import 'package:learning_app/pages/home/components/home_animator.dart';
import 'package:learning_app/pages/home/components/home_search_button.dart';
import 'package:learning_app/pages/profile/profile_page.dart';
import '../courses/course_details_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TextEditingController _searchController;

  AnimationController _controller, _listController;
  HomeAnimator _animator;
  HomeListAnimator _listAnimator;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _listController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animator = HomeAnimator(_controller);
    _listAnimator = HomeListAnimator(_listController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // FocusScope.of(context).unfocus();
    return WillPopScope(
      onWillPop: () {
        if (_controller.isDismissed) {
          return Future.value(true);
        } else {
          _searchController.clear();
          FocusScope.of(context).unfocus();
          _controller.reverse();
          return Future.value(false);
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (ctx, child) => Scaffold(
//            floatingActionButton: FloatingActionButton(
//              onPressed: () {
//                if (_controller.status == AnimationStatus.completed) {
//                  _controller.reverse();
//                } else if (_controller.status == AnimationStatus.dismissed) {
//                  _controller.forward();
//                }
//              },
//            ),
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
                    return Stack(
                        fit: StackFit.expand,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Positioned(
                            top: _animator.nameYTranslation.value,
                            left: 32,
                            right: 32,
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProfilePage()));
                                },
                                child: Opacity(
                                  opacity: _animator.nameOpacity.value,
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Hello,\n',
                                        style: TextStyle(
                                            fontSize: 28,
                                            color: Colors.black54)),
                                    TextSpan(
                                        text: '${data['name']}',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black))
                                  ])),
                                )),
                          ),
                          Positioned(
                            top: _animator.searchYTranslation.value + 15,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(_searchController.text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          Positioned(
                              top: _animator.searchYTranslation.value,
                              left: 32,
                              right: 32,
                              child: Opacity(
                                opacity: _animator.nameOpacity.value,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation:
                                      _searchController.text.isNotEmpty ? 8 : 0,
                                  shadowColor: Colors.grey.withOpacity(0.2),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                              autofocus: false,
                                              controller: _searchController,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Search here ...',
                                                hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black45,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 48),
                                              )),
                                        ),
                                        HomeSearchButton(onPressed: () {
                                          String query = _searchController.text
                                              .toString()
                                              .trim();
                                          if (query.isNotEmpty) {
                                            //unfocus
                                            // _controller.forward();
                                          } else {
                                            // _scaffoldKey.currentState.showSnackBar(SnackBar(
                                            //   content: Text('Enter what you want to search.'),
                                            //   behavior: SnackBarBehavior.floating,
                                            // ));
                                          }
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          if (_searchController.text.isNotEmpty)
                            Positioned(
                              top: _animator.progressYTranslation.value,
                              left: 0,
                              right: 0,
                              child: Opacity(
                                opacity: _animator.progressOpacity.value,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: _animator.progressSize.value,
                                  width: _animator.progressSize.value,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          if (_searchController.text.isEmpty)
                            Positioned(
                              top: _animator.studyingCoursesYTranslation.value,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Opacity(
                                opacity: _animator.studyingCoursesOpacity.value,
                                child: ListView(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 5, 16, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Popular',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900),
                                          ),
                                          FlatButton(
                                            child: Text('View more'),
                                            textColor: Colors.blue,
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AllCoursesPage()));
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: Firestore.instance
                                            .collection('courses')
                                            .limit(4)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            QuerySnapshot data = snapshot.data;
                                            _listController.forward();
                                            return Opacity(
                                              opacity: _listAnimator
                                                  .coursesListOpacity.value,
                                              child: ListView.builder(
                                                padding: EdgeInsets.fromLTRB(
                                                    _listAnimator
                                                        .coursesListXTranslation
                                                        .value,
                                                    8,
                                                    8,
                                                    8),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: 4,
                                                itemBuilder: (context, index) {
                                                  final DocumentSnapshot dat =
                                                      data.documents[index];
                                                  return Card(
                                                    elevation: 4,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 8, left: 8),
                                                    shadowColor: Colors.grey
                                                        .withOpacity(0.4),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    child: InkWell(
                                                      splashColor: Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.12),
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () => Navigator.of(
                                                              context)
                                                          .push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CourseDetailsPage(
                                                                            doc:
                                                                                dat,
                                                                          ))),
                                                      child: AspectRatio(
                                                        aspectRatio: 9 / 5.5,
                                                        child: Ink.image(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                              '${dat['logo']}'),
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 8, 16, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Studying',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900),
                                          ),
                                          FlatButton(
                                            child: Text('View more'),
                                            textColor: Colors.blue,
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyCoursesPage()));
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150,
                                      width: double.infinity,
                                      child: isNotNullList
                                          ? StreamBuilder<QuerySnapshot>(
                                              stream: Firestore.instance
                                                  .collection('courses')
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  QuerySnapshot coursesQuery =
                                                      snapshot.data;
                                                  List<DocumentSnapshot>
                                                      purchasedCourses = [];
                                                  coursesQuery.documents
                                                      .forEach((element) {
                                                    if (myCourseList.contains(
                                                        element.documentID)) {
                                                      purchasedCourses
                                                          .add(element);
                                                    }
                                                  });
                                                  return Opacity(
                                                    opacity: _listAnimator
                                                        .coursesListOpacity
                                                        .value,
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.fromLTRB(
                                                          _listAnimator
                                                              .coursesListXTranslation
                                                              .value,
                                                          8,
                                                          8,
                                                          8),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          purchasedCourses
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final DocumentSnapshot
                                                            dat =
                                                            purchasedCourses[
                                                                index];
                                                        return Card(
                                                            elevation: 4,
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8,
                                                                    left: 8),
                                                            shadowColor: Colors
                                                                .grey
                                                                .withOpacity(
                                                                    0.4),
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                            child: InkWell(
                                                              onTap: () => Navigator
                                                                      .of(context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (context) => CourseDetailsPage(
                                                                            doc:
                                                                                dat,
                                                                          ))),
                                                              splashColor: Theme
                                                                      .of(
                                                                          context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withOpacity(
                                                                      0.12),
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    9 / 5.5,
                                                                child:
                                                                    Ink.image(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image: NetworkImage(
                                                                      '${dat['logo']}'),
                                                                ),
                                                              ),
                                                            ));
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  return Center(
                                                      child: Container());
                                                }
                                              },
                                            )
                                          : Container(
                                              child: Text(
                                                  'You have not purchased any course yet'),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Positioned(
                            top: _animator.searchCoursesXTranslation.value,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Opacity(
                              opacity: _animator.searchCoursesListOpacity.value,
                              child: ListView.builder(
                                itemCount: 5,
                                itemBuilder: (ctx, index) =>
                                    Text('Index $index'),
                              ),
                            ),
                          )
                        ]);
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )),
      ),
    );
  }
}
