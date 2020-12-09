import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/courses/tests/listen_and_answer/listen_and_answer_row.dart';
import 'package:learning_app/pages/home/home_page.dart';
import 'package:learning_app/views/gradient_button.dart';

class ListenAndAnswerPage extends StatefulWidget {
  final List<DocumentSnapshot> listenAndGuessQuestionList;
  ListenAndAnswerPage({@required this.listenAndGuessQuestionList});
  @override
  _ListenAndAnswerPageState createState() => _ListenAndAnswerPageState();
}

class _ListenAndAnswerPageState extends State<ListenAndAnswerPage> {
  List<TextEditingController> answerControllerList = List();
  List<String> answerList = List();

  @override
  void initState() {
    widget.listenAndGuessQuestionList.forEach((element) {
      TextEditingController answerController = TextEditingController();
      answerControllerList.add(answerController);
    });

    for (int index = 0;
        index < widget.listenAndGuessQuestionList.length;
        index++) {
      final DocumentSnapshot questionSnapshot =
          widget.listenAndGuessQuestionList[index];
      Map<dynamic, dynamic> dataMap = questionSnapshot['data'];
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
        title: Text(
          'Listen & Answer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: widget.listenAndGuessQuestionList.length,
                itemBuilder: (ctx, index) {
                  if (widget.listenAndGuessQuestionList.isEmpty) {
                    return Center(
                      child: Text('No questions found'),
                    );
                  } else {
                    final DocumentSnapshot questionSnapshot =
                        widget.listenAndGuessQuestionList[index];
                    Map<dynamic, dynamic> dataMap = questionSnapshot['data'];
                    return ListenAndAnswerRow(
                      audioUrl: dataMap['audio'],
                      answerController: answerControllerList[index],
                    );
                  }
                }),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 24, left: 12, right: 12, bottom: 8),
            child: GradientButton(
              onPressed: () {
                for (int i = 0; i < answerControllerList.length; i++) {
                  if (answerControllerList[i].text.isEmpty) {
                    showShortToast('Please answer the questions');
                  } else if (answerControllerList[i].text != answerList[i]) {
                    showShortToast('Please check your answers');
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (ctx) => HomePage()),
                        (route) => false);
                  }
                }
              },
              text: 'Return Home',
              width: MediaQuery.of(context).size.width,
              height: 50,
            ),
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
