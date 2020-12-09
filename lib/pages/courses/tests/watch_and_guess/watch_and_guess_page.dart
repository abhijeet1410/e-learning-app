import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/courses/tests/listen_and_answer/listen_and_answer_page.dart';
import 'package:learning_app/pages/courses/tests/watch_and_guess/watch_and_guess_row.dart';
import 'package:learning_app/views/gradient_button.dart';
import 'package:learning_app/views/outline_button.dart';

class WatchAndGuessPage extends StatefulWidget {
  final List<DocumentSnapshot>listenAudioQuestionList;
  final List<DocumentSnapshot>guessTheQuestionList;

  WatchAndGuessPage({@required this.listenAudioQuestionList,
    @required this.guessTheQuestionList});

  @override
  _WatchAndGuessPageState createState() => _WatchAndGuessPageState();
}

class _WatchAndGuessPageState extends State<WatchAndGuessPage> {
  List<TextEditingController>answerControllerList = List();
  List<String>answerList = List();

  @override
  void initState() {
    widget.guessTheQuestionList.forEach((element){
      TextEditingController answerController = TextEditingController();
      answerControllerList.add(answerController);
    });

    for(int index=0; index<widget.guessTheQuestionList.length; index++){
      final DocumentSnapshot questionSnapshot = widget.guessTheQuestionList[index];
      Map<dynamic,dynamic> dataMap = questionSnapshot['data'];
      String answer = dataMap['answer'];
      answerList.add(answer);
    }

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
        title: Text('Watch & Guess', style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
        ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: widget.guessTheQuestionList.length,
                itemBuilder: (ctx,index){
                  if(widget.guessTheQuestionList.isEmpty){
                    return Center(
                      child: Text('No questions found'),
                    );
                  }else{
                    final DocumentSnapshot questionSnapshot = widget.guessTheQuestionList[index];
                    Map<dynamic,dynamic> dataMap = questionSnapshot['data'];
                    return WatchAndGuessRow(
                      answerController: answerControllerList[index],
                      imageUrl: dataMap['image'],
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
                        builder: (context) => ListenAndAnswerPage(
                          listenAndGuessQuestionList: widget.listenAudioQuestionList,
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
                    for(int i = 0; i<answerControllerList.length; i++){
                      if(answerControllerList[i].text.isEmpty){
                        showShortToast('Please answer the questions');
                      }else if(answerControllerList[i].text != answerList[i]){
                        showShortToast('Please check your answers');
                      }else{
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ListenAndAnswerPage(
                            listenAndGuessQuestionList: widget.listenAudioQuestionList,
                          )
                        ));
                      }
                    }
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
