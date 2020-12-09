import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/pages/courses/tests/jumble_words/jumble_widget.dart';
import 'package:learning_app/pages/courses/tests/match_the_column/match_the_column_page.dart';
import 'package:learning_app/views/gradient_button.dart';
import 'package:learning_app/views/outline_button.dart';
import 'model.dart';

class JumbleWordsPage extends StatefulWidget {
  final List<DocumentSnapshot>jumbleQuestionsList;
  final List<DocumentSnapshot>guessImageQuestionList;
  final List<DocumentSnapshot>listenAudioQuestionList;
  final List<DocumentSnapshot>matchTheColumnQuestionList;

  JumbleWordsPage({@required this.jumbleQuestionsList,
    @required this.guessImageQuestionList, @required this.listenAudioQuestionList,
  @required this.matchTheColumnQuestionList});

  @override
  _JumbleWordsPageState createState() => _JumbleWordsPageState();
}

class _JumbleWordsPageState extends State<JumbleWordsPage> {
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
        title: Text('Jumble Words', style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: widget.jumbleQuestionsList.length,
                itemBuilder: (ctx, index) {
                  if (widget.jumbleQuestionsList.isEmpty) {
                    print('yes');
                    return Center(
                      child: Text('No questions found'),
                    );
                  } else {
                    print('no');
                    final DocumentSnapshot questionSnapshot = widget
                        .jumbleQuestionsList[index];
                    Map<dynamic, dynamic> dataMap = questionSnapshot['data'];
                    String line = dataMap['line'];
                    List<String> words = line.split(' ');
                    List<JumbleModel> jQuestionList = List();
                    for (int i = 0; i < words.length; i++) {
                      jQuestionList.add(JumbleModel(
                          text: words[i],
                          id: i + 1
                      ));
                    }
                    return JumbleWords(
                      list: jQuestionList,
                    );
                  }
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 24, left: 2, right: 2, bottom: 12),
                child: ELearningOutLineButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => MatchTheColumnPage(
                        guessImageQuestionList: widget.guessImageQuestionList,
                        listenAudioQuestionList: widget.listenAudioQuestionList,
                        matchTheColumnQuestionList: widget.matchTheColumnQuestionList,
                      )
                    ));
                  },
                  height: 50,
                  width: MediaQuery.of(context).size.width / 2.5,
                  text: 'Skip',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 24, left: 2, right: 2, bottom: 12),
                child: GradientButton(
                  onPressed: () {

                  },
                  text: 'Next',
                  width: MediaQuery.of(context).size.width / 2,
                  height: 50,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
