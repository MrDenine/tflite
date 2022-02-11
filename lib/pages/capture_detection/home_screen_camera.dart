// ignore: file_names
// ignore: file_names

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/pages/capture_detection/tracking.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'bounding_box.dart';
import 'camera_utility.dart';

const String ssd = "My model";

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen(this.cameras);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? _recognitions;
  List<dynamic>? _dataForTrack;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";
  String? boundingBox;
  String? tracking;

  loadModel() async {
    String? result;
    switch (_model) {
      case ssd:
        result = await Tflite.loadModel(
            labels: "assets/tflite/label_map.txt",
            model: "assets/tflite/ssd_mobilenet_320_v4.tflite",
            numThreads: 4,
            useGpuDelegate: false);
    }
    print(result);
  }

  onSelectModel(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth, dataForTrack) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
      _dataForTrack = dataForTrack;
      print("test = $dataForTrack");
    });
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    // checkGPS().then((value) => value
    //     ? onSelectModel(ssd)
    //     : succeedDialog(context, "กรุณาเปิด GPS", HomePage()));

    //onSelectModel(ssd);
    getData();
  }

  getData() async {
    bool rusult = await checkGPS();
    if (rusult) {
      var listdata = await getDataSetting();
      if (listdata != "Error") {
        print("listdata = $listdata");
        boundingBox = listdata["boundingBox"];
        tracking = listdata["tracking"];
      } else {
        boundingBox = "true";
        tracking = "true";
      }
      onSelectModel(ssd);
    } else {
      succeedDialog(context, "กรุณาเปิด GPS", HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: const Icon(
      //       Icons.arrow_back_ios,
      //       color: Colors.black,
      //     ),
      //   ),
      // ),
      body: _model == ""
          ? Container()
          : Stack(
              children: [
                Camera(widget.cameras, _model, setRecognitions),
                Positioned(
                  left: 10.0,
                  top: 35.0,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => HomePage()),
                          (Route<dynamic> route) => false);
                    },
                  ),
                ),
                boundingBox == "true" && boundingBox != null
                    ? BoundingBox(
                        _recognitions ?? [],
                        math.max(_imageHeight, _imageWidth),
                        math.min(_imageHeight, _imageWidth),
                        screen.height,
                        screen.width,
                        _model)
                    : Container(),
                tracking == "true" && tracking != null
                    ? Tracking(
                        _dataForTrack ?? [],
                        math.max(_imageHeight, _imageWidth),
                        math.min(_imageHeight, _imageWidth),
                        screen.height,
                        screen.width,
                      )
                    : Container(),
              ],
            ),
    );
  }
}
