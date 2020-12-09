import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WatchAndGuessRow extends StatefulWidget {
  final String imageUrl;
  final TextEditingController answerController;
  WatchAndGuessRow({@required this.imageUrl,
     @required this.answerController});
  @override
  _WatchAndGuessRowState createState() => _WatchAndGuessRowState();
}

class _WatchAndGuessRowState extends State<WatchAndGuessRow> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          height: 260,
          width: width,
          child: AspectRatio(
            aspectRatio: 9/16,
            child: Image(
              fit: BoxFit.cover,
              image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/e-learning-34219.appspot.com/o/logo%2Fpngtree-math-calculations-png-image_4124283.jpg?alt=media&token=076c7fa6-78dc-48a5-a306-4521be48ce36'),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24.0),
          width: width/1.5,
          child: TextField(
              controller: widget.answerController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder().copyWith(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Color(0xff7a7a7a)),
                  ),
                  focusedBorder: OutlineInputBorder().copyWith(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Color(0xff7a7a7a)),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  hintStyle: new TextStyle(color: Colors.grey),
                  hintText: 'Your Answer'
              )
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

