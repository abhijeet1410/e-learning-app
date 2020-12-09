import 'package:flutter/cupertino.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({Key key, this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 4.5,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: CupertinoColors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              width: 2,
              color: CupertinoColors.black
          )
      ),
      child: Center(
        child: Text('$text',
            style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
