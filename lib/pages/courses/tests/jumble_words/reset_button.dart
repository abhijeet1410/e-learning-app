import 'package:flutter/material.dart';

class ResetButton extends StatelessWidget {
  ResetButton({
    @required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      elevation: 8,
      child: Icon(
        Icons.restore,
        color: Colors.pinkAccent,
      ),
    );
  }
}
