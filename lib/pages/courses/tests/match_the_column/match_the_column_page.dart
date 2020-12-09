import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/courses/tests/match_the_column/match_the_column_row.dart';
import 'package:learning_app/pages/courses/tests/watch_and_guess/watch_and_guess_page.dart';
import 'package:learning_app/views/gradient_button.dart';
import 'package:learning_app/views/outline_button.dart';

class MatchTheColumnPage extends StatefulWidget {
  final List<DocumentSnapshot>guessImageQuestionList;
  final List<DocumentSnapshot>listenAudioQuestionList;
  final List<DocumentSnapshot>matchTheColumnQuestionList;

  MatchTheColumnPage({@required this.guessImageQuestionList,
    @required this.listenAudioQuestionList,
    @required this.matchTheColumnQuestionList});

  @override
  _MatchTheColumnPageState createState() => _MatchTheColumnPageState();
}

class _MatchTheColumnPageState extends State<MatchTheColumnPage> {
  List<TextEditingController>answerControllerList = List();

  @override
  void initState() {
    widget.matchTheColumnQuestionList.forEach((element){
      TextEditingController answerController = TextEditingController();
      answerControllerList.add(answerController);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: FloatingActionButton(
            heroTag: "backBtn",
            mini: true,
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
              size: 22,
            ),
          ),
        ),
        title: Text('Match The Column', style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
        ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: widget.matchTheColumnQuestionList.length,
                itemBuilder: (ctx,index){
                  if(widget.matchTheColumnQuestionList.isEmpty){
                    return Center(
                      child: Text('No questions found'),
                    );
                  }else{
                    final DocumentSnapshot questionSnapshot = widget.matchTheColumnQuestionList[index];
                    Map<dynamic,dynamic> dataMap = questionSnapshot['data'];
                    List<dynamic> col1 = dataMap['col1'] as List;
                    List<dynamic> col2 = dataMap['col2'] as List;
                    List<String> originalColAList = List();
                    List<String> originalColBlist = List();

                    col1.forEach((element) {
                      originalColAList.add(element.toString());
                    });

                    col2.forEach((element) {
                      originalColBlist.add(element.toString());
                    });

                    return MatchTheColumnRow(
                      answerController: answerControllerList[index],
                      originalColumnAList: originalColAList,
                      originalColumnBList: originalColBlist,
                    );
                  }
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 2, right: 2, bottom: 12),
                child: ELearningOutLineButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => WatchAndGuessPage(
                        guessTheQuestionList: widget.guessImageQuestionList,
                        listenAudioQuestionList: widget.listenAudioQuestionList,
                      )
                    ));
                  },
                  height: 50,
                  width: MediaQuery.of(context).size.width/2.5,
                  text: 'Skip',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 2, right: 2, bottom: 12),
                child: GradientButton(
                  onPressed: (){
                    answerControllerList.forEach((element) {
                      if(element.text == 'completed'){
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => WatchAndGuessPage(
                              guessTheQuestionList: widget.guessImageQuestionList,
                              listenAudioQuestionList: widget.listenAudioQuestionList,
                            )
                        ));
                      }else{
                        showShortToast('You must complete the assignment to proceed');
                      }
                    });
                  },
                  text: 'Next',
                  width: MediaQuery.of(context).size.width/2,
                  height: 50,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  void showShortToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }
}
