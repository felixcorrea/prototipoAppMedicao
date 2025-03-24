import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      home: CameraScreen(camera: firstCamera),
    ),
  );

}






class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}): super(key:key);

  @override
  _CameraScreenState createState() => _CameraScreenState();

}

class _CameraScreenState extends State<CameraScreen> {
late CameraController _controller;
late Future<void> _initializeControllerFuture;
bool _isRed = true;
double _lineLength = 0;
bool isGrowing = false;

@override
void initState() {
super.initState();
_controller = CameraController(
widget.camera,
ResolutionPreset.medium,
);

_initializeControllerFuture = _controller.initialize();
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

void _togglePointColor(){
  setState((){
    _isRed = !_isRed;
    isGrowing = !isGrowing;
  }
  );

  if(isGrowing){
    _growLine();
  }

}
void _cleanLine(){
  setState(() {
    _lineLength = 0;
    isGrowing = false;
  });
}


void _growLine(){
  Future.delayed(Duration(milliseconds: 50), (){
if (isGrowing){
  setState((){
    _lineLength += 0.5;
  });
  _growLine();
}

  });
}

@override
Widget build(BuildContext context) {
return Scaffold(

appBar: AppBar(title: Text('Câmera')),
body: FutureBuilder<void>(
future: _initializeControllerFuture,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.done) {
return Stack(
  children: [
    CameraPreview(_controller),
    Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: _isRed ? Colors.red : Colors.red[200],
          shape: BoxShape.circle,
        ),
      )

    ),
Positioned(
  bottom: 100,
  left: 20,
  child: Container(
    height: 2,
    width: _lineLength,
    color: Colors.black,
  ),
),
  ],

);




} else {
return Center(child: CircularProgressIndicator());
}
},
),
  floatingActionButton: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [

      Text('$_lineLength cm'),
      SizedBox(width: 16),
      FloatingActionButton(
        onPressed: _togglePointColor,
        child: Icon(Icons.square_foot),
      ),
      SizedBox(width: 16), // Espaço entre os botões
      /*FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera_alt),
      ),
      */

      SizedBox(width: 16,),
      FloatingActionButton(onPressed: _cleanLine,
      child: Icon(Icons.clear),),
    ],
  ),
);
}
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Foto Capturada')),
      body: Image.file(File(imagePath)),
    );
  }
}