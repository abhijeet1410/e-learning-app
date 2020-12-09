import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/courses/tests/fill_in_the_blanks/fill_in_the_blanks_row.dart';
import 'package:learning_app/pages/courses/tests/jumble_words/jumble_words_page.dart';
import 'package:learning_app/views/gradient_button.dart';
import 'package:learning_app/views/outline_button.dart';

class FillInTheBlankPage extends StatefulWidget {
  final String episodeId;
  FillInTheBlankPage({@required this.episodeId});
  @override
  _FillInTheBlankPageState createState() => _FillInTheBlankPageState();
}

class _FillInTheBlankPageState extends State<FillInTheBlankPage> {

  void showShortToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
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
        title: Text('Fill In The Blanks', style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('tests').snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            QuerySnapshot fillInTheBlanksQuery = snapshot.data;
            List<DocumentSnapshot>questionsList = [];
            List<DocumentSnapshot>jumbleQuestionsList = [];
            List<DocumentSnapshot>guessImageQuestionList = [];
            List<DocumentSnapshot>listenAnswerQuestionList = [];
            List<DocumentSnapshot>matchTheColumnQuestionList = [];
            fillInTheBlanksQuery.documents.forEach((element) {
              if(widget.episodeId == element['episodeId']){
                if(element['type'] == 'fill_blanks'){
                  questionsList.add(element);
                }
                if(element['type'] == 'jumble_word'){
                  jumbleQuestionsList.add(element);
                }

                if(element['type'] == 'guess_image'){
                  guessImageQuestionList.add(element);
                }

                if(element['type'] == 'guess_audio'){
                  listenAnswerQuestionList.add(element);
                }

                if(element['type'] == 'match_the_column'){
                  matchTheColumnQuestionList.add(element);
                }
              }

            });
            List<TextEditingController> answerList = List();
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: questionsList.length,
                      itemBuilder: (ctx,index){
                        if(questionsList.isEmpty){
                          return Center(
                            child: Text('No questions found'),
                          );
                        }else{
                          questionsList.forEach((element){
                            TextEditingController answerController = TextEditingController();
                            answerList.add(answerController);
                          });
                          final DocumentSnapshot questionSnapshot = questionsList[index];
                          Map<dynamic,dynamic> dataMap = questionSnapshot['data'];
                          String question = dataMap['question'];
                          List<dynamic> optionsList = dataMap['options'] as List;
                          return FillBlanks(
                            answer: answerList[index],
                            initialString: question,
                            options: [
                              optionsList[0].toString(), optionsList[1].toString(),
                              optionsList[2].toString(), optionsList[3].toString()
                            ],
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
                            builder: (ctx) => JumbleWordsPage(
                              jumbleQuestionsList: jumbleQuestionsList,
                              guessImageQuestionList: guessImageQuestionList,
                              listenAudioQuestionList: listenAnswerQuestionList,
                              matchTheColumnQuestionList: matchTheColumnQuestionList,
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
                          for(int i=0; i<answerList.length; i++){
                            if(answerList[i].text.isEmpty){
                              showShortToast('If');
                            }else{
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => JumbleWordsPage(
                                    jumbleQuestionsList: jumbleQuestionsList,
                                    guessImageQuestionList: guessImageQuestionList,
                                    listenAudioQuestionList: listenAnswerQuestionList,
                                    matchTheColumnQuestionList: matchTheColumnQuestionList,
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
            );
          }else{
            return Center(child: CircularProgressIndicator(),);
          }
        }
      )
    );
  }
}
