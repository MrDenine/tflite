import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:non_helmet_mobile/models/position_image.dart';
import 'package:non_helmet_mobile/utility/convert_img_isolate.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lo;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as imglib;

///แปลงรูปแบบวันที่
String formatDate(dateTime) {
  try {
    DateTime date = DateTime.parse(dateTime);
    String formattedDate = DateFormat('dd-MM-yyyy เวลา HH:mm').format(date);
    return formattedDate;
  } catch (e) {
    return "ไม่สามารถแสดงวันที่ได้";
  }
}

///แปลงรูปแบบวันที่จากฐานข้อมูล
String formatDateDatabase(dateTime) {
  try {
    DateTime dateNew =
        DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(dateTime).toLocal();

    return dateNew.day.toString() +
        '-' +
        dateNew.month.toString() +
        '-' +
        dateNew.year.toString() +
        ' ' +
        'เวลา' +
        ' ' +
        dateNew.hour.toString() +
        ':' +
        dateNew.minute.toString();
  } catch (e) {
    return "ไม่สามารถแสดงวันที่ได้";
  }
}

///การขออนุญาตแอป
Future<bool> permissionCamera() async {
  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
  }

// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.location,
    Permission.microphone,
    Permission.storage,
  ].request();

  if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.camera] == PermissionStatus.denied ||
      statuses[Permission.location] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.location] == PermissionStatus.denied ||
      statuses[Permission.microphone] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.microphone] == PermissionStatus.denied ||
      statuses[Permission.storage] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.storage] == PermissionStatus.denied) {
    return false;
  } else {
    return true;
  }
}

///เช็คพิกัด
Future<bool> checkGPS() async {
  lo.Location location = lo.Location();

  bool _serviceEnabled;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}

///เช็คโฟลเดอร์
Future<Directory> checkDirectory(String folderName) async {
  final dir =
      Directory((await getExternalStorageDirectory())!.path + '/$folderName');

  if ((await dir.exists())) {
    return dir;
  } else {
    dir.create();
    return dir;
  }
}

///เช็คเน็ต
checkInternet(context) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    print("I am connected to a mobile network.");
    // I am connected to a mobile network.
  } else if (connectivityResult == ConnectivityResult.wifi) {
    // I am connected to a wifi network.
    print("I am connected to a wifi network.");
  } else {
    print("No net");
    normalDialog(context, "กรุณาตรวจสอบอินเทอร์เน็ต");
  }
}

///ดึงข้อมูลการตั้งค่า
Future<dynamic> getDataSetting() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString('listSetting') ?? '';
    return jsonDecode(rawJson);
  } catch (e) {
    //print("Error = $e");
    return "Error";
  }
}

// ///รับตำแหน่งภาพ สำหรับ Crop รูปภาพ
// PositionImage imagePosition(List listdata, listRecogClass) {
//   print("imagePosition");
//   CameraImage image = listdata[0]; //ไฟล์รูปจาก CameraImage
//   List<dynamic>? recognitions = listdata[1]; //ข้อมูลที่ได้จากการตรวจจับ
//   Size? screen = listdata[2]; //ขนาดจอ
//   int rotation_detect = listdata[4]; //ลิสสำหรับเก็บค่าเฉลี่ยสี
//   int? previewH = math.max(image.height, image.width);
//   int? previewW = math.min(image.height, image.width);
//   PositionImage result; //ค่า x y w h สำหรับส่งกลับ

//   final double _x = listRecogClass['rect']['x'] as double;
//   final double _w = listRecogClass['rect']['w'] as double;
//   final double _y = listRecogClass['rect']['y'] as double;
//   final double _h = listRecogClass['rect']['h'] as double;
//   double x, y, w, h;
//   if (rotation_detect == 90 || rotation_detect == 270) {
//     x = _x * previewW;
//     y = _y * previewH;
//     w = _w * previewW;
//     h = _h * previewH;
//   } else {
//     var screenH = image.height;
//     var screenW = image.width;
//     var scaleH = screenH;
//     var scaleW = screenW;
//     var difH = (scaleH - screenH) / scaleH;
//     x = _x * scaleW;
//     w = _w * scaleW;
//     y = (_y - difH / 2) * scaleH;
//     h = _h * scaleH;
//     if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
//   }

//   // print(listRecogClass['detectedClass']);
//   // print("x = $x");
//   // print("y = $y");
//   // print("w = $w");
//   // print("h = $h");
//   result = PositionImage(x, y, w, h);

//   return result;
// }

///รับตำแหน่งภาพ สำหรับ Crop รูปภาพ
PositionImage imagePosition(IsolateData listdata, listRecogClass) {
  print("imagePosition");
  CameraImage image = listdata.cameraImage; //ไฟล์รูปจาก CameraImage
  List<dynamic>? recognitions = listdata.recognitions; //ข้อมูลที่ได้จากการตรวจจับ
  Size? screen = listdata.screen; //ขนาดจอ
  int rotation_detect = listdata.rotation_value; //ลิสสำหรับเก็บค่าเฉลี่ยสี
  int? previewH = math.max(image.height, image.width);
  int? previewW = math.min(image.height, image.width);
  PositionImage result; //ค่า x y w h สำหรับส่งกลับ

  final double _x = listRecogClass['rect']['x'] as double;
  final double _w = listRecogClass['rect']['w'] as double;
  final double _y = listRecogClass['rect']['y'] as double;
  final double _h = listRecogClass['rect']['h'] as double;
  double x, y, w, h;
  if (rotation_detect == 90 || rotation_detect == 270) {
    x = _x * previewW;
    y = _y * previewH;
    w = _w * previewW;
    h = _h * previewH;
  } else {
    var screenH = image.height;
    var screenW = image.width;
    var scaleH = screenH;
    var scaleW = screenW;
    var difH = (scaleH - screenH) / scaleH;
    x = _x * scaleW;
    w = _w * scaleW;
    y = (_y - difH / 2) * scaleH;
    h = _h * scaleH;
    if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
  }

  // print(listRecogClass['detectedClass']);
  // print("x = $x");
  // print("y = $y");
  // print("w = $w");
  // print("h = $h");
  result = PositionImage(x, y, w, h);

  return result;
}

///Crop and return cropped image
imglib.Image copyCropp(imglib.Image src, int x, int y, int w, int h) {
  final imglib.Image dst = imglib.Image(w, h,
      channels: src.channels, exif: src.exif, iccp: src.iccProfile);

  for (var yi = 0, sy = y; yi < h; ++yi, ++sy) {
    for (var xi = 0, sx = x; xi < w; ++xi, ++sx) {
      dst.setPixel(xi, yi, src.getPixel(sx, sy));
    }
  }
  return dst;
}

///รับค่าเฉลี่ยสี
Color getAverageColor(Uint8List fileImage) {
  print("getAverageColor");
  imglib.Image? bitmap = imglib.decodeImage(fileImage);

  int redBucket = 0;
  int greenBucket = 0;
  int blueBucket = 0;
  int pixelCount = 0;

  for (int y = 0; y < bitmap!.height; y++) {
    for (int x = 0; x < bitmap.width; x++) {
      int c = bitmap.getPixel(x, y);

      pixelCount++;
      redBucket += imglib.getRed(c);
      greenBucket += imglib.getGreen(c);
      blueBucket += imglib.getBlue(c);
    }
  }

  Color averageColor = Color.fromRGBO(redBucket ~/ pixelCount,
      greenBucket ~/ pixelCount, blueBucket ~/ pixelCount, 1);
  return averageColor;
}

///เปรียบเทียบค่าสี
int compareColor(Color col1, Color col2) {
  print("compareColor");
  double maxColDist = 764.8339663572415;
  double rmean = (col1.red + col2.red) / 2;
  int r = col1.red - col2.red;
  int g = col1.green - col2.green;
  int b = col1.blue - col2.blue;
  double weightR = 2 + rmean / 256;
  double weightG = 4.0;
  double weightB = 2 + (255 - rmean) / 256;
  double result =
      math.sqrt(weightR * r * r + weightG * g * g + weightB * b * b);
  return (((maxColDist - result) / maxColDist) * 100).round();
}

///ตรวจสอบว่าคลาสต่าง ๆ อยู่ในคลาส Rider หรือไม่
double isObject(box1, box2) {
  double x1 = box1['rect']['x'];
  double w1 = box1['rect']['w'];
  double y1 = box1['rect']['y'];
  double h1 = box1['rect']['h'];

  double x2 = box2['rect']['x'];
  double w2 = box2['rect']['w'];
  double y2 = box2['rect']['y'];
  double h2 = box2['rect']['h'];
  var w_intersection = math.min(x1 + w1, x2 + w2) - math.max(x1, x2);
  var h_intersection = math.min(y1 + h1, y2 + h2) - math.max(y1, y2);
  if (w_intersection <= 0 || h_intersection <= 0) {
    return 0;
  }
  var I = w_intersection * h_intersection;
  var U = w1 * h1 + w2 * h2 - I;
  return I / U;
}
