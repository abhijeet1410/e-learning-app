import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/pages/courses/course_details_page.dart';

class CoursesCard extends StatefulWidget {
  final DocumentSnapshot doc;
  @override
  _CoursesCardState createState() => _CoursesCardState();
  CoursesCard(this.doc);
}

class _CoursesCardState extends State<CoursesCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CourseDetailsPage(
                doc: widget.doc,
              ))),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 9 / 5.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    fit: BoxFit.cover,
                    image: NetworkImage('${widget.doc['logo']}'),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  '${widget.doc['name']}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  '${widget.doc['description']}',
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
