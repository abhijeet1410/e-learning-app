import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MatchTheColumnRow extends StatefulWidget {
  final TextEditingController answerController;
  final List<String> originalColumnAList;
  final List<String> originalColumnBList;
  MatchTheColumnRow({@required this.originalColumnAList, @required this.originalColumnBList, @required this.answerController});
  @override
  _MatchTheColumnRowState createState() => _MatchTheColumnRowState();
}

class _MatchTheColumnRowState extends State<MatchTheColumnRow> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<AnimatedListState> _listKeyTwo = GlobalKey();

  List<String> shuffledColumnAList;
  List<String> shuffledColumnBList;
  List<String>answerColumnAList;
  List<String>answerColumnBList;
  String firstItem = '';

  int selectedIndexOne = -1;
  int selectedIndexTwo = -1;

  int selectedWrongIndex = -1;

  @override
  void initState() {
    shuffledColumnAList = List();
    shuffledColumnBList = List();

    answerColumnBList = List();
    answerColumnAList = List();

    widget.originalColumnAList.forEach((element) {
      shuffledColumnAList.add(element);
    });

    widget.originalColumnBList.forEach((element) {
      shuffledColumnBList.add(element);
    });

    shuffledColumnAList.shuffle();
    shuffledColumnBList.shuffle();

    super.initState();
  }

  @override
  void dispose() {
    widget.answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String>columnADemoList = List();
    List<String>columnBDemoList = List();

    answerColumnAList.forEach((element) {
      columnADemoList.add(element);
    });

    answerColumnBList.forEach((element) {
      columnBDemoList.add(element);
    });

    columnADemoList.addAll(shuffledColumnAList);
    columnBDemoList.addAll(shuffledColumnBList);
    
    return Card(
      elevation: 4.0,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        height: 400,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 48, right: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Column A', style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                    ),),
                  Text('Column B', style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Row(
               children: [
                 Expanded(
                   child: AnimatedList(
                     key: _listKeyTwo,
                     initialItemCount: columnADemoList.length,
                     itemBuilder: (ctx,index,animation){
                       return SizeTransition(
                         sizeFactor: animation,
                         child: Row(
                           children: <Widget>[
                             GestureDetector(
                               onTap: answerColumnAList.contains(columnADemoList[index])?null:(){
                                 setState(() {
                                   firstItem = columnADemoList[index];
                                   selectedIndexOne = index;
                                   selectedWrongIndex = -1;
                                 });
                               },
                               child: Center(
                                 child: Container(
                                   height: 40,
                                   width: 140,
                                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(5.0),
                                     border: Border.all(
                                       width: 1,
                                       color: selectedIndexOne == index ? Colors.green : answerColumnAList.contains(columnADemoList[index]) ? Colors.green : Colors.black54,
                                     ),
                                   ),
                                   child: Center(child: Text('${columnADemoList[index]}', style: TextStyle(
                                     color: selectedIndexOne == index ? Colors.green : answerColumnAList.contains(columnADemoList[index])?Colors.green:Colors.black,
                                   ),)),
                                 ),
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.only(left: 4),
                               child: Icon(
                                 selectedWrongIndex == index ? Icons.clear : Icons.arrow_forward,
                                 size: 20,
                                 color: selectedWrongIndex == index ? Colors.red : answerColumnAList.contains(columnADemoList[index]) ? Colors.green : Colors.black,
                               ),
                             ),
                           ],
                         ),
                       );
                     },
                   ),
                 ),
                 Expanded(
                   child: AnimatedList(
                     key: _listKey,
                     initialItemCount: columnBDemoList.length,
                     itemBuilder: (ctx,index,animation){
                       return _buildTwo(animation, index, columnBDemoList);
                     },
                   ),
                 )
               ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildTwo(Animation animation, int index, List columnBDemoList){
    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        onTap: answerColumnBList.contains(columnBDemoList[index])?null:(){
          setState(() {
            _match(index,columnBDemoList,animation);
          });
        },
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            height: 40,
            width: 140,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  width: 1,
                  color: answerColumnBList.contains(columnBDemoList[index]) ? Colors.green : Colors.black54,
                )
            ),
            child: Center(child: Text('${columnBDemoList[index]}', style: TextStyle(
              color: answerColumnBList.contains(columnBDemoList[index]) ? Colors.green : Colors.black
            ),)),
          ),
        ),
      ),
    );
  }
  void _match(int index, List columnBDemoList, Animation animation) {
    if(firstItem.isNotEmpty){
      String item = columnBDemoList[index];

      int indexOne = widget.originalColumnAList.indexOf(firstItem);
      int indexTwo = widget.originalColumnBList.indexOf(item);

      if(indexOne == indexTwo){
        shuffledColumnAList.remove(firstItem);
        shuffledColumnBList.remove(item);

        AnimatedListRemovedItemBuilder builder = (context, animation) {
          return _buildTwo(animation, index, columnBDemoList);
        };

        _listKey.currentState.removeItem(index, builder);

        answerColumnAList.add(firstItem);
        answerColumnBList.add(item);

        if(answerColumnAList.length == widget.originalColumnAList.length
            && answerColumnBList.length == widget.originalColumnBList.length){
          widget.answerController.text = 'completed';
        }

        _listKey.currentState.insertItem(answerColumnBList.indexOf(item));
      }else{
        selectedWrongIndex = index;
      }
    }
  }
}
