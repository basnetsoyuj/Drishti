import 'dart:async';
import 'package:camera/camera.dart';
import 'package:drishti_camera/instruction_page.dart';
import 'package:drishti_camera/history_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'package:drishti_camera/media_player.dart';
import 'package:drishti_camera/mode.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> with WidgetsBindingObserver {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  // Can be updated using gestures to feed to a different model
  String _modelLocation = "assets/cash_recognition/models/nrs_model/model.tflite";
  String _labelLocation = "assets/cash_recognition/models/nrs_model/labels.txt";

  List<String> _historyList = List<String>();

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _controller != null
            ? _initializeControllerFuture = _controller.initialize()
            : null; //on pause camera disposed so we need call again "issue is only for android"
      });
    }else if(state == AppLifecycleState.paused || state == AppLifecycleState.inactive){
      MediaPlayer.stopAudio();
    }

  }

  Future captureAndClassify() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);
      // Attempt to classify te image

      String prediction =
          await classifyImage(path, _modelLocation, _labelLocation);
      prediction = prediction.substring(2);

      _historyList.add(DateTime.now().toString().substring(0,16) + "  " + prediction.toUpperCase());

      String audioPath = "cash_recognition/audio/nrs_audio/" + prediction + ".m4a";
      MediaPlayer.playAudio(audioPath);

    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  Future<String> classifyImage(
      String imagePath, String modelPath, String labelPath) async {
    await Tflite.loadModel(model: modelPath, labels: labelPath);
    var output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    return output == null ? "No prediction" : output[0]["label"];
  }

  getHistoryPage(){
      MediaPlayer.stopAudio();
      Navigator.push(context, new MaterialPageRoute(
        builder: (context) => HistoryPage(_historyList),
      )).then((value) => MediaPlayer.stopAudio());

  }

  getInstructionsPage(){
    MediaPlayer.stopAudio();
    Navigator.push(context, new MaterialPageRoute(
      builder: (context) => InstructionPage(Mode.CASH_RECOGNITION),
    )).then((value) => MediaPlayer.stopAudio());
  }


  @override
  Widget build(BuildContext context) {
    String appBarTitle = "Drishti 2.0";
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: Text(appBarTitle),
        leading: IconButton(icon: Icon(Icons.history), tooltip: "Transaction History", iconSize: 40, onPressed: getHistoryPage,),
        actions: <Widget>[
      IconButton(
      icon: Icon(
        Icons.info,
        color: Colors.white,
        semanticLabel: "Instructions",
      ),
        iconSize: 40,
      onPressed: getInstructionsPage,
    )
    ],


      ),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;
            return Transform.scale(
              scale: _controller.value.aspectRatio / deviceRatio,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller),
                ),
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.3,
        padding: EdgeInsets.all(0),
        child: FittedBox(
          child: FloatingActionButton(
              child: Icon(Icons.camera_alt_rounded, semanticLabel: "Recognize Note",),
              onPressed: captureAndClassify,
            foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            splashColor: Colors.grey,
          ),
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}
