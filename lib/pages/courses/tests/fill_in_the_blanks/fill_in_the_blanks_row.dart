import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FillBlanks extends StatefulWidget {
  final TextEditingController answer;
  final List<String> options;
  final String initialString;
  const FillBlanks({this.options = const [], this.initialString = '', this.answer});

  @override
  _FillBlanksState createState() => _FillBlanksState();
}

class _FillBlanksState extends State<FillBlanks> {
  List<GlobalKey> keys;
  List<String> splittedList;
  List<Position> positions = [];

  @override
  void initState() {
    super.initState();
    splittedList = widget.initialString.split('_');
  }

  @override
  void dispose() {
    widget.answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    child: Wrap(
                      children: splittedList.map((e) {
                        final index = splittedList.indexOf(e);
                        if (index != splittedList.length - 1) {
                          return Wrap(children: [
                            Text(e),
                            Container(
                              height: 30,
                              width: 90,
                              decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(width: 1.0, color: Colors.black54),
                                  )
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.answer.text}',style: TextStyle(
                                    color: Colors.green
                                  ),
                                ),
                              ),
                            )
                          ]);
                        } else {
                          return Text(e);
                        }
                      }).toList(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(2, (index){
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            widget.answer.text = widget.options[index];
                          });
                          print('selected ans => '+widget.answer.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          width: width/2.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 1, color: Colors.black45)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${index+1}. ${widget.options[index]}',
                              style: TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(2, (index){
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            widget.answer.text = widget.options[index+2];
                          });
                          print('selected ans => '+widget.answer.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          width: width/2.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 1, color: Colors.black45)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${index+3}. ${widget.options[index+2]}',
                              style: TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

class Position {
  double left, top;
  Position(this.left, this.top);
}
