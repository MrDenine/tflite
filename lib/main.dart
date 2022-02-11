// ignore_for_file: empty_catches, unused_catch_clause, avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';

//late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); ตั้งค่าการวางแนวแอปตามแนวโทรศัพท์
  // try {
  //   cameras = await availableCameras();
  // } on CameraException catch (e) {
  //   print('Error: $e.code \n Eooro Message: $e.message');
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'Non Helmet Detection',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          //fontFamily: 'NotoSansThai'
        ),
        home: SplashPage()
        //home: HomeScreen(cameras),
        );
  }
}
