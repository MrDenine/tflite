import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:non_helmet_mobile/modules/constant.dart';

///อัปโหลดรูปภาพที่ถูกตรวจจับ class rider และ class license plate
Future<void> uploadDatectedImage(
    int userID, Uint8List fileImgRider, Uint8List fileImgLicense) async {
  print("uploadDatectedImage");
  String uploadurl = "${Constant().domain}/DetectedImage/uploadImage";

  int genName = DateTime.now().millisecondsSinceEpoch;
  DateTime datenow = DateTime.now();
  //รับพิกัด
  var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  FormData formdata = FormData.fromMap({
    "file": [
      MultipartFile.fromBytes(fileImgRider,
          filename: 'rider_' + userID.toString() + genName.toString() + '.jpg'),
      MultipartFile.fromBytes(fileImgLicense,
          filename: 'license-plate_' +
              userID.toString() +
              genName.toString() +
              '.jpg')
    ],
    "user_id": userID,
    "datetime": datenow.toString(),
    "latitude": position.latitude,
    "longitude": position.longitude,
    "detection_at": datenow.toString(),
  });

  Response response = await Dio().post(
    uploadurl,
    data: formdata,
  );
  if (response.statusCode == 200) {
  } else {}
}
