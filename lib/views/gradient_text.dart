import 'package:flutter/material.dart';

class GradientText extends StatefulWidget {
  final String text;
  GradientText({this.text});
  @override
  _GradientTextState createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText> {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(colors: [Color(0xFF1D60BC), Color(0xFF00D2FF)])
            .createShader(Offset.zero & bounds.size);
      },
      child: Text(
        widget.text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
