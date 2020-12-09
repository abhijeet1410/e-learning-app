import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JumbleCard extends StatelessWidget {
  const JumbleCard({Key key, this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/4.5,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 2,
          color: Colors.black
        )
      ),
      child: Center(
        child: Text('$text', style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
      ),
    );
  }
}
