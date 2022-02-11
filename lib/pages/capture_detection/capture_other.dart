import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image/image.dart' as img;

//สำหรับการเทสระบบตรวจจับ
const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

class TfliteHome extends StatefulWidget {
  @override
  TfliteHomeState createState() => TfliteHomeState();
}

class TfliteHomeState extends State<TfliteHome> {
  final String _model = ssd;
  File? _image;

  double? _imageWidth;
  double? _imageHeight;
  bool _busy = false;

  List? _recognitions;

  @override
  void initState() {
    super.initState();
    _busy = true;
    loadMedel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  loadMedel() async {
    Tflite.close();
    try {
      String res;
      if (_model == yolo) {
        res = (await Tflite.loadModel(
            model: "assets\tflite\my_model.tflite",
            labels: "assets\tflite\my_model.txt",
            useGpuDelegate: true))!;
      } else {
        res = (await Tflite.loadModel(
            model: "assets\tflite\my_model.tflite",
            labels: "assets\tflite\my_model.txt",
            useGpuDelegate: true))!;
      }
      // ignore: avoid_print
      print(res);
    } on PlatformException {
      // ignore: avoid_print
      print("Failed to load the model");
    }
  }

  selectFromImagePicker() async {
    var imageSelect =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    File image = File(imageSelect!.path);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  predictImage(File image) async {
    //if (image == null) return;
    if (_model == yolo) {
      await yolov2Tiny(image);
    } else {
      await ssdMobileNet(image);
    }

    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
      });
    }));
    setState(() {
      _image = image;
      _busy = false;
    });
  }

  //optional
  yolov2Tiny(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        model: "YOLO",
        threshold: 0.3,
        imageMean: 0.0,
        imageStd: 255.0,
        numResultsPerClass: 1);
    setState(() {
      _recognitions = recognitions;
    });
  }

  ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 1);
    setState(() {
      _recognitions = recognitions;
    });
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageWidth == null || _imageHeight == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight! / _imageHeight! * screen.width;

    Color blue = Colors.blue;
    return _recognitions!.map((re) {
      return Positioned(
          left: re["rect"]["x"] * factorX,
          top: re["rect"]["y"] * factorY,
          width: re["rect"]["w"] * factorX,
          height: re["rect"]["h"] * factorY,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: blue,
              width: 3,
            )),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}",
              style: TextStyle(
                background: Paint()..color = blue,
                fontSize: 15,
              ),
            ),
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];
    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null
          ? const Text("No Image Selected")
          : Image.file(_image!),
    ));

    stackChildren.addAll(renderBoxes(size));
    if (_busy) {
      stackChildren.add(const Center(
        child: CircularProgressIndicator(),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("TFlite Demo"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.image),
        tooltip: "Pick Image From gallery",
        onPressed: selectFromImagePicker,
      ),
      body: Stack(
        children: stackChildren,
      ),
    );
  }
}
