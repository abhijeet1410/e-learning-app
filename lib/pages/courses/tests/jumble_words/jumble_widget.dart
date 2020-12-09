import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_app/pages/courses/tests/jumble_words/jumble_builder.dart';
import 'package:learning_app/pages/courses/tests/jumble_words/jumble_card.dart';
import 'package:learning_app/pages/courses/tests/jumble_words/result_card.dart';
import 'model.dart';

class JumbleWords extends StatefulWidget {
  final List<JumbleModel> list;
  const JumbleWords({@required this.list});

  @override
  _JumbleWordsState createState() => _JumbleWordsState();
}

class _JumbleWordsState extends State<JumbleWords> {
  bool _isEmptyAnsList = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        JumbleBuilder(
          animationDuration: Duration(milliseconds: 500),
          initialSourceList: widget.list,
          builder: (context, sourceBuilderDelegates, targetBuilderDelegates) {
            if(sourceBuilderDelegates == targetBuilderDelegates){
              print("match");
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 6.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  height: 260,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        width: MediaQuery.of(context).size.width,
                        child: Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: sourceBuilderDelegates.map((builderDelegate) {
                            JumbleModel model = builderDelegate.message;
                            return builderDelegate.build(
                              context,
                              GestureDetector(
                                onTap: () => builderDelegate.state
                                    .move(builderDelegate.message),
                                child: JumbleCard(text: '${model.text}'),
                              ),
                              animationBuilder: (animation) => CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                              flightShuttleBuilder: (
                                  context,
                                  animation,
                                  type,
                                  from,
                                  to,
                                  ) =>
                                  buildShuttle(
                                    animation,
                                    builderDelegate.message,
                                  ),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        height: 1,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 150),
                          child: Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: targetBuilderDelegates.map((builderDelegate) {
                              if(targetBuilderDelegates.isEmpty){
                                setState(() {
                                  _isEmptyAnsList = true;
                                });
                              }else{
                                _isEmptyAnsList = false;
                              }
                              JumbleModel model = builderDelegate.message;
                              return builderDelegate.build(
                                context,
                                GestureDetector(
                                  onTap: () => builderDelegate.state
                                      .move(builderDelegate.message),
                                  child: ResultCard(
                                    text: '${model.text}',
                                  ),
                                ),
                                animationBuilder: (animation) => CurvedAnimation(
                                  parent: animation,
                                  curve: FlippedCurve(Curves.easeOut),
                                ),
                                flightShuttleBuilder: (
                                    context,
                                    animation,
                                    type,
                                    from,
                                    to,
                                    ) =>
                                    buildShuttle(
                                      animation,
                                      builderDelegate.message,
                                    ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildShuttle(
    Animation<double> animation,
    JumbleModel model,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Icon(
          Icons.child_care,
          color: Colors.red,
        ); //ResultCard(text:model.text);
      },
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
