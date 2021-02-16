import 'package:drishti_camera/mode.dart';
class Instructions{

  Mode _mode;
  List<List<String>> _instructionsList;

  Instructions(Mode mode){
    this._mode = mode;
    _setupInstructions();
  }

  List<List<String>> getInstructions(){
    return _instructionsList;
  }

  void _setupInstructions() {
    if(_mode == Mode.CASH_RECOGNITION){
      _instructionsList = [
        ["Getting started", "cash_recognition/instructions/1.mp3"],
        ["Audio Feedback", "cash_recognition/instructions/2.mp3"],
        ["History Feature", "cash_recognition/instructions/3.mp3"],
        ["Placement of Notes", "cash_recognition/instructions/4.mp3"],
        ["More Queries", "cash_recognition/instructions/5.mp3"],
        ["Additional Information","cash_recognition/instructions/6.mp3"],
      ];
    }
  }
}