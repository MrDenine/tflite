import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/models/data_statics.dart';
import 'package:non_helmet_mobile/modules/constant.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/capture_detection/home_screen_camera.dart';
import 'package:non_helmet_mobile/pages/edit_profile.dart';
import 'package:non_helmet_mobile/pages/settings.dart';
import 'package:non_helmet_mobile/pages/upload_Page/upload_home.dart';
import 'package:non_helmet_mobile/pages/video_page/video_main.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? countAllRider;
  int? countMeRider;
  bool? checkNewvideo;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    checkInternet(context);
    permissionCamera()
        .then((value) => !value ? settingPermissionDialog(context) : null);
    //getData();
  }

  Future<DataStatics?> getData() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    Directory dir = await checkDirectory("Pictures");
    List<FileSystemEntity> _photoLists = dir.listSync();
    int numDetectedImg = 0;

    for (var i = 0; i < _photoLists.length; i++) {
      String userIDFromFile =
          _photoLists[i].path.split('/').last.split('_').first;

      if (user_id.toString() == userIDFromFile) {
        numDetectedImg += 1;
      }
    }

    try {
      var result = await getAmountRider(user_id);
      if (result.pass) {
        if (result.data["status"] == "Succeed") {
          return DataStatics(
            numDetectedImg,
            result.data["data"]["countMeRider"]["today"],
            result.data["data"]["countMeRider"]["tomonth"],
            result.data["data"]["countMeRider"]["total"],
            result.data["data"]["countAllRider"]["today"],
            result.data["data"]["countAllRider"]["tomonth"],
            result.data["data"]["countAllRider"]["total"],
          );
        }
      }
    } catch (e) {
      return null;
    }
  }

  Stream<bool> showloadingVideo() async* {
    final prefs = await SharedPreferences.getInstance();
    // This loop will run forever because _running is always true
    while (_running) {
      await Future<void>.delayed(const Duration(seconds: 1));
      int listFrameImg = prefs.getInt('listFrameImg') ?? 0;
      // This will be displayed on the screen as current time
      if (listFrameImg == 0) {
        _running = false;
        yield false;
      } else {
        yield true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Helmet',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Capture',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  children: <Widget>[
                    buildimageAc(EditProfile()),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 175,
                child: FutureBuilder(
                    future: getData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 3,
                            itemBuilder: (context, index) =>
                                displayStatics(index, snapshot.data));
                      } else {
                        return const Text("กรุณารอสักครู่");
                      }
                    }),
              ),
              const Divider(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildMenuBtn(
                        1,
                        const Icon(
                          Icons.camera_alt,
                          size: 60,
                        ),
                        "ตรวจจับ"),
                    Stack(
                      children: [
                        buildMenuBtn(
                            2,
                            const Icon(
                              Icons.video_collection,
                              size: 60,
                            ),
                            "วิดีโอ"),
                        StreamBuilder(
                          stream: showloadingVideo(),
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.data == true) {
                              return Positioned(
                                  child: Container(
                                color: Colors.red,
                                child: const Text(
                                  "กำลังโหลดวิดีโอใหม่",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ));
                            } else {
                              return Container();
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildMenuBtn(
                        3,
                        const Icon(
                          Icons.cloud_download,
                          size: 60,
                        ),
                        "อัปโหลด"),
                    buildMenuBtn(
                        4,
                        const Icon(
                          Icons.settings_outlined,
                          size: 60,
                        ),
                        "ตั้งค่า"),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  //แสดงสถิติ (ส่วนหลัก)
  Widget displayStatics(int index, DataStatics data) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            index == 0
                ? staticsNotUpload(data)
                : index == 1
                    ? staticsRiderMe(data)
                    : staticsRiderAll(data)
          ],
        ));
  }

  //สถิติของผู้ใช้คนนั้น กรณียังไม่อัปโหลด
  Widget staticsNotUpload(DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "จำนวนรถจักรยานยนต์ที่คุณตรวจจับได้ (ยังไม่อัปโหลด)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ทั้งหมด:',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
                margin: const EdgeInsets.all(20.0),
                height: 25.0,
                width: 80.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  // ignore: unnecessary_const
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(data.countRiderNotup.toString()))),
            const Text(
              'คัน',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //สถิติของผู้ใช้คนนั้น กรณีอัปโหลดแล้ว
  Widget staticsRiderMe(DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "จำนวนรถจักรยานยนต์ที่คุณตรวจจับได้ (อัปโหลดแล้ว)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        displayDataStatics("\t\t\t\tวันนี้", data.countMeRidertoday),
        displayDataStatics("เดือนนี้", data.countMeRidertomonth),
        displayDataStatics("ทั้งหมด", data.countMeRidertotal),
      ],
    );
  }

  //สถิติของผู้ใช้ในระบบทั้งหมด
  Widget staticsRiderAll(DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "จำนวนรถจักรยานยนต์ที่ถูกตรวจจับทั้งหมด",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        displayDataStatics("\t\t\t\tวันนี้", data.countAllRidertoday),
        displayDataStatics("เดือนนี้", data.countAllRidertomonth),
        displayDataStatics("ทั้งหมด", data.countAllRidertotal),
      ],
    );
  }

  //แสดงข้อมูล รายวัน เดือน ทั้งหมด
  Widget displayDataStatics(String title, int data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
            margin: const EdgeInsets.all(8.0),
            height: 25.0,
            width: 80.0,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              // ignore: unnecessary_const
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Align(
                alignment: Alignment.center, child: Text(data.toString()))),
        const Text(
          'คัน',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildMenuBtn(onPressed, icon, content) {
    print("1");
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber,
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 2),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (onPressed == 1) {
            late List<CameraDescription> cameras;
            try {
              cameras = await availableCameras();
            } on CameraException catch (e) {
              print('Error: $e.code \n Eooro Message: $e.message');
              cameras = [];
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomeScreen(cameras)));
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => onPressed == 2
                      ? VideoMain()
                      : onPressed == 3
                          ? Upload()
                          : onPressed == 4
                              ? SettingPage()
                              : HomePage()),
            );
          }
        },
        child: Column(
          children: [
            icon,
            Text(
              "$content",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )
          ],
        ),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(25),
          // primary: Colors.blue, // <-- Button color
          // onPrimary: Colors.red, // <-- Splash color
        ),
      ),
    );
  }

  Widget buildimageAc(onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => onTap),
        );
      },
      child: FutureBuilder(
        future: getImage(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data != null &&
              snapshot.data != "false" &&
              snapshot.data != "Error") {
            return Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
                image: DecorationImage(
                    image: NetworkImage("${snapshot.data}"), fit: BoxFit.fill),
              ),
            );
          } else if (snapshot.data == "Error") {
            return const CircleAvatar();
          } else {
            return const CircleAvatar(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<String> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    try {
      var result = await getDataUser(user_id);
      if (result.pass) {
        var imagename = result.data["data"][0]["image_profile"];
        if (imagename != null) {
          String urlImage = "${Constant().domain}/profiles/$imagename";
          var response = await Dio().get(urlImage);
          if (response.statusCode == 200) {
            return urlImage;
          } else {
            return "false";
          }
        } else {
          return "Error";
        }
      } else {
        return "false";
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return "Error";
    }
  }
}
