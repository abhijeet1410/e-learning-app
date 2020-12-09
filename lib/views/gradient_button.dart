import 'package:flutter/material.dart';
class GradientButton extends StatefulWidget {
  final String text;
  final double height; final double width;
  final VoidCallback onPressed;
  GradientButton({this.text, this.height, this.width, this.onPressed});
  @override
  _GradientButtonState createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF00D2FF), Color(0xFF1D60BC)])
        ),
        width: widget.width,
        child: Center(child: Text(widget.text,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18
            ),
          ),
        ),
      ),
    );
  }
}