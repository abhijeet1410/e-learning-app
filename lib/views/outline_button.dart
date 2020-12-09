import 'package:flutter/material.dart';
class ELearningOutLineButton extends StatefulWidget {
  final String text;
  final double height; final double width;
  final VoidCallback onPressed;
  ELearningOutLineButton({this.text, this.height, this.width, this.onPressed});
  @override
  _ELearningOutLineButtonState createState() => _ELearningOutLineButtonState();
}

class _ELearningOutLineButtonState extends State<ELearningOutLineButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
                width: 2,
                color: Colors.blue
            )
        ),
        width: widget.width,
        child: Center(child: Text('Skip',
          style: TextStyle(
              color: Colors.blue,
              fontSize: 18
          ),
        ),
        ),
      ),
    );
  }
}
