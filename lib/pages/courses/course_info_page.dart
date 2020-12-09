import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/pages/courses/course_video_play_page.dart';
import 'package:learning_app/views/gradient_text.dart';
class CourseInfoPage extends StatefulWidget {
  final DocumentSnapshot doc;
  CourseInfoPage({this.doc});
  @override
  _CourseInfoPageState createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage> {
  bool isExpand = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 9/5,
                          child: Image(
                            fit: BoxFit.cover,
                            image: NetworkImage('${widget.doc['logo']}'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: FloatingActionButton(
                            onPressed: ()=>Navigator.of(context).pop(),
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
                      padding: const EdgeInsets.only(top: 62.0, left: 16.0, right: 16.0),
                      child: GradientText(text: widget.doc['name'],),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                      child: Text(widget.doc['description'], style: TextStyle(
                        fontSize: 14,
                      ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, left: 16.0),
                          child: Container(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
                            decoration: new BoxDecoration(
                              color: Colors.blue, //new Color.fromRGBO(255, 0, 0, 0.0),
                              borderRadius: new BorderRadius.only(
                                  topLeft:  const  Radius.circular(20.0),
                                  topRight: const  Radius.circular(20.0),
                                  bottomLeft: const Radius.circular(20.0),
                                  bottomRight: const Radius.circular(20.0)),
                            ),
                            child: Center(
                              child: Text('New', style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12
                              ),),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, left: 8.0),
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 2.0, bottom: 2.0
                            ),
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.only(
                                    topLeft:  const  Radius.circular(20.0),
                                    topRight: const  Radius.circular(20.0),
                                    bottomLeft: const Radius.circular(20.0),
                                    bottomRight: const Radius.circular(20.0)
                                ),
                                border: Border.all(
                                  color: Colors.grey[800],// <--- border color
                                  width: 1.0,
                                )
                            ),
                            child: Center(
                              child: Text('Updated 04/2020',
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
                      margin: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                      height: 1,
                      color: Colors.grey,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('This course includes', style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20
                              ),),
                              Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                height: 1,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.check,
                                      color: Colors.blueAccent,
                                      size: 24.0,
                                    ),
                                    SizedBox(width: 5,),
                                    Text('6 hours on-demand audio')
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.check,
                                      color: Colors.blueAccent,
                                      size: 24.0,
                                    ),
                                    SizedBox(width: 5,),
                                    Text('Support Files')
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.check,
                                      color: Colors.blueAccent,
                                      size: 24.0,
                                    ),
                                    SizedBox(width: 5,),
                                    Text('Full time Access')
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.check,
                                      color: Colors.blueAccent,
                                      size: 24.0,
                                    ),
                                    SizedBox(width: 5,),
                                    Text('Certification of Completion')
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
                      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Course Details', style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20
                              ),),
                              Row(
                                children: <Widget>[
                                  Text('Total Chapters (${widget.doc['chapters']}),'),
                                  SizedBox(width: 5,),
                                  Text('Total Episodes (${widget.doc['episodes']})'),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 12.0),
                                height: 1,
                                color: Colors.grey,
                              ),
                              StreamBuilder<QuerySnapshot>(
                                  stream: Firestore.instance.collection('chapters').snapshots(),
                                  builder: (context, snapshot) {
                                    if(snapshot.hasData){
                                      QuerySnapshot chaptersQuery = snapshot.data;
                                      List<DocumentSnapshot>chaptersList = [];
                                      chaptersQuery.documents.forEach((element) {
                                        if(widget.doc.documentID == element['courseId']){
                                          chaptersList.add(element);
                                        }
                                      });
                                      return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: chaptersList.map((item){
                                            return ExpansionTile(
                                                children: <Widget>[
                                                  StreamBuilder<QuerySnapshot>(
                                                      stream: Firestore.instance.collection('episodes').snapshots(),
                                                      builder: (context, snapshot) {
                                                        if(snapshot.hasData){
                                                          QuerySnapshot episodesQuery = snapshot.data;
                                                          List<DocumentSnapshot>episodesList = [];
                                                          episodesQuery.documents.forEach((element) {
                                                            if(item.documentID == element['chapterId']){
                                                              episodesList.add(element);
                                                            }
                                                          });
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: episodesList.map((item){
                                                              return Padding(
                                                                padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
                                                                child: Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(item['name'], style: TextStyle(
                                                                      fontSize: 16,
                                                                      color: Colors.black
                                                                  ),),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          );
                                                        }else{
                                                          return Center(child: CircularProgressIndicator(),);
                                                        }
                                                      }
                                                  )
                                                ],
                                                trailing: Icon(Icons.arrow_drop_down,size: 32,color: Colors.blue,),
                                                onExpansionChanged: (value){
                                                  chaptersList.clear();
                                                  setState(() {
                                                    isExpand=value;
                                                  });
                                                },
                                                title: Container(
                                                  width: double.infinity,
                                                  child: Text("${item['name']}",style: TextStyle(fontSize: 18),),
                                                )
                                            );
                                          }).toList()
                                      );
                                    }else{
                                      return Center(child: CircularProgressIndicator(),);
                                    }
                                  }
                              ),
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
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    height: 120,
                    width: 180,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image(
                            fit: BoxFit.cover,
                            image: NetworkImage('https://img.youtube.com/vi/5aPahOD4ssk/default.jpg'),
                          ),
                        ),
                        Positioned.fill(child: Container(
                          color: Colors.black54,
                        )),
                        Positioned.fill(
                          child: IconButton(
                            onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => VideoPlayPage(videoId: '5aPahOD4ssk',
                                  appBarTitle: widget.doc['name'],),
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
                          left: 0, right: 0,
                          child: Center(
                            child: Text('Course demo video', style: TextStyle(
                                color: Colors.white
                            ),),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
