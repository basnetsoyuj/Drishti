import 'package:flutter/material.dart';
import 'package:drishti_camera/media_player.dart';
import 'package:drishti_camera/mode.dart';
import 'package:drishti_camera/instructions.dart';

class InstructionPage extends StatelessWidget {
  final Mode _mode;
  InstructionPage(this._mode);

  final _iconSize = 40.0;
  final _fontSize = 25.0;
  final _iconImage = Icons.volume_up_sharp;




  @override
  Widget build(BuildContext context){

    String modeString = _mode.toString();
    String title = modeString.substring(modeString.indexOf(".") + 1).replaceAll("_"," ");
    return Scaffold(
      appBar: AppBar(
          title: Text(title),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
        body: getInstructionListView(),
      backgroundColor: Colors.white,
    );
  }

  Widget getInstructionListView(){
    final Icon icon = Icon(_iconImage, size: _iconSize);
    final TextStyle listTextStyle = TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold);
    final Instructions instructions = Instructions(_mode);
    final List<List<String>> instructionList = instructions.getInstructions();

    final listView = ListView.builder(
       itemCount: instructionList.length,
       itemBuilder: (context, index)
    {
      return Card(
          child: ListTile(
            title: Text('${index+1}. ' + instructionList[index][0], style: listTextStyle),
            trailing: icon,
            onTap: () {
              MediaPlayer.playAudio(instructionList[index][1]);
            },
          )
      );
    },
    );
    return listView;
  }
}