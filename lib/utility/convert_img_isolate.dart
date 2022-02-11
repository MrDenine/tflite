import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:easy_isolate/easy_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:image_compare/image_compare.dart';
import 'package:non_helmet_mobile/models/data_image.dart';
import 'package:non_helmet_mobile/models/model_tflite.dart';
import 'package:non_helmet_mobile/models/position_image.dart';
import 'package:non_helmet_mobile/modules/constant.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:image/image.dart' as imglib;

class IsolateUtils {
  static const String DEBUG_NAME = "InferenceIsolate";

  late Isolate _isolate;
  ReceivePort _receivePort = ReceivePort();
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static Future<void> entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port) {
      print("convertImage");
      ////////////////////////ตัวแปร////////////////////////////////////////
      //ไฟล์รูปจาก CameraImage
      CameraImage image = isolateData.cameraImage;
      //ข้อมูลที่ได้จากการตรวจจับ
      List<dynamic>? recognitions = isolateData.recognitions;
      //ลิสสำหรับเก็บภาพสำหรับนำไปเช็คค่า ทำ Tracking
      List<DataImageForCheck> listImgForCheck = isolateData.listDataImgForCheck;
      //ตัวแปรหมุนจอ
      int rotation_detect = isolateData.rotation_value;

      List<DataDetectedImage> listDataImage = []; //ลิสเก็บข้อมูลรูปภาพ
      List<ListResultImage> listresult = []; //ลิสคำตอบที่จะรีเทิร์นกลับ
      List<ModelTflite> recogNew = []; //ลิสค่า Recognition ใหม่
      List<dynamic> dataforTrack = []; //ลิสเก็บข้อมูลไปแสดง Tracking
      int? showpercentCheck;
      int? avgColorID;
      int countlistAvg = listImgForCheck.length;
      /////////////////////////////////////////////////////////////////////

      //รูปกรณีมีมากกว่า 1 คันใน 1 ภาพ
      for (var i = 0; i < recognitions.length; i++) {
        if (recognitions[i]["detectedClass"] == "Rider") {
          //recogNew.add(recognitions[i]);
          recogNew.add(ModelTflite(recognitions[i], null, null));
        }
      }

      //ตรวจสอบคลาส
      if (recogNew.isNotEmpty) {
        for (var i = 0; i < recogNew.length; i++) {
          // print("recogNew : ${recogNew[i]}");
          for (var y = 0; y < recognitions.length; y++) {
            if (recognitions[y]["detectedClass"] != "Rider") {
              double resultCheck = isObject(recogNew[i].rider, recognitions[y]);
              //print("resultCheck = $resultCheck");
              if (resultCheck > 0.02) {
                // print("recogNew : ${recogNew[i]}");
                // print("recognitions : ${recognitions[y]}");
                if (recognitions[y]["detectedClass"] == "None-helmet") {
                  recogNew[i] = ModelTflite(recogNew[i].rider, recognitions[y],
                      recogNew[i].license_plate);
                } else if (recognitions[y]["detectedClass"] ==
                    "License-plate") {
                  recogNew[i] = ModelTflite(
                      recogNew[i].rider, recogNew[i].helmet, recognitions[y]);
                }
              }
            }
          }
        }

        //ตรวจสอบให้เหลือคลาสที่จะนำไปใช้
        if (recogNew.isNotEmpty) {
          for (var i = 0; i < recogNew.length; i++) {
            if (recogNew[i].helmet == null ||
                recogNew[i].license_plate == null) {
              recogNew.removeAt(i);
            } else {}
          }
        } else {
          isolateData.responsePort!.send([]);
        }

        print("recogNew = $recogNew");
        print("recogNew = ${recogNew.length}");
        // print("rider = ${recogNew.first.rider}");
        // print("helmet = ${recogNew.first.helmet}");
        // print("license_plate = ${recogNew.first.license_plate}");

        if (recogNew.isNotEmpty) {
          //แปลง image stream to image
          imglib.Image fixedImage =
              await compute(yuv420toImageColor, isolateData);

          for (var i = 0; i < recogNew.length; i++) {
            //รับตำแหน่งภาพที่ได้จากการตรวจจับ Class Rider
            PositionImage coorRider =
                imagePosition(isolateData, recogNew[i].rider);

            //ฟังก์ชัน Crop รูป Class Rider
            imglib.Image destImageRider = copyCropp(
              fixedImage, //ไฟล์รูปที่ได้จากการแปลง
              coorRider.x.round(), //ค่า x
              coorRider.y.round(), //ค่า y
              coorRider.w.round(), //ค่า w
              coorRider.h.round(), //ค่า h
            );

            //ฟังก์ชัน Crop รูป Class Rider สำหรับนำไปเช็คค่า
            imglib.Image destImageCheck = copyCropp(
                destImageRider, //ไฟล์รูปที่ได้จากการแปลง
                (destImageRider.width / 4).round(), //ค่า x
                (destImageRider.height / 4).round(), //ค่า y
                (destImageRider.width / 3).round(), //ค่า w
                (destImageRider.height / 2).round()); //ค่า h

            //ไฟล์ภาพ Class Rider ที่ได้ Crop แล้ว
            var riderImage = imglib.encodeJpg(destImageRider) as Uint8List?;
            //ไฟล์ภาพ Class Rider ที่ได้ Crop แล้ว สำหรับนำไปเช็คค่า
            var checkImage = imglib.encodeJpg(destImageCheck) as Uint8List?;

            //รับค่าสี
            //Color averageColor = getAverageColor(checkImage!);

            //print("averageColor = ${averageColor}");
            print("listAvgColors 3 = $listImgForCheck");
            print("listImgForCheck 3 = $countlistAvg");

            if (countlistAvg != listImgForCheck.length) {
              isolateData.responsePort!.send([]);
            }

            print("riderImage 1 = $listImgForCheck");

            if (listImgForCheck.isNotEmpty) {
              try {
                //เปรียบเทียบภาพ
                for (var i = 0; i < listImgForCheck.length; i++) {
                  // double checkColorImgs = await compareImages(
                  //     src1: checkImage,
                  //     src2: listImgForCheck[i].img,
                  //     algorithm: IntersectionHistogram(/* ignoreAlpha: true */));
                  double checkColorImgs = await compareImages(
                      src1: checkImage,
                      src2: listImgForCheck[i].img,
                      algorithm: EuclideanColorDistance(ignoreAlpha: true));

                  //สำหรับนำไปตรวจสอบค่า
                  int checkColorImg = (checkColorImgs * 100).round();
                  //สำหรับนำไปโชว์ Tracking
                  showpercentCheck = ((1 - checkColorImgs) * 100).round();
                  print("------------checkColorImg---------------");
                  print("checkColorImg 1 list = ${listImgForCheck.length}");
                  print("checkColorImg 2 % = $checkColorImg");
                  print("checkColorImg 3 ID = ${listImgForCheck[i].id}");

                  if (checkColorImg < 20) {
                    avgColorID = listImgForCheck[i].id;
                    listImgForCheck[i] =
                        DataImageForCheck(listImgForCheck[i].id, checkImage!);
                    riderImage = null;
                    break;
                  } else {
                    continue;
                  }
                }
                // ignore: empty_catches
              } catch (e) {}
            }

            print("riderImage 2 = $riderImage");
            print("riderImage 3 = $showpercentCheck");

            if (riderImage != null) {
              //รับตำแหน่งภาพที่ได้จากการตรวจจับ Class License
              PositionImage coorlicenseP =
                  imagePosition(isolateData, recogNew[i].license_plate);

              //ฟังก์ชัน Crop รูป Class license plate
              imglib.Image destImagesLicense = copyCropp(
                  fixedImage, //ไฟล์รูปที่ได้จากการแปลง
                  coorlicenseP.x.round(), //ค่า x
                  coorlicenseP.y.round(), //ค่า y
                  min(coorlicenseP.w.round(),
                      fixedImage.width - coorlicenseP.x.round()), //ค่า w
                  min(coorlicenseP.h.round(),
                      fixedImage.height - coorlicenseP.y.round())); //ค่า h

              var licensePlateImg =
                  imglib.encodeJpg(destImagesLicense) as Uint8List?;

              listDataImage
                  .add(DataDetectedImage(checkImage!, licensePlateImg!));

              dataforTrack.add({
                "id": listImgForCheck.length + 1,
                "coorRider": recogNew[i].rider['rect'],
                "confidenceTracking": showpercentCheck ??= 100
              });

              listImgForCheck.add(
                  DataImageForCheck(listImgForCheck.length + 1, checkImage));
            } else {
              listDataImage = [];

              dataforTrack.add({
                "id": avgColorID,
                "coorRider": recogNew[i].rider['rect'],
                "confidenceTracking": showpercentCheck ??= 100
              });
            }
          }
          // print("listFileImage = ${listFileImage}");
          // print("listFileImage = ${listAvaColors}");
          if (listDataImage.isNotEmpty) {
            print("ListImageIsnotempty");

            listresult.add(
                ListResultImage(listDataImage, listImgForCheck, dataforTrack));

            isolateData.responsePort!.send(listresult);
          } else {
            listresult.add(ListResultImage([], listImgForCheck, dataforTrack));

            isolateData.responsePort!.send(listresult);
          }
        } else {
          isolateData.responsePort!.send([]);
        }
      } else {
        isolateData.responsePort!.send([]);
      }
    }
  }
}

/// Bundles data to pass between Isolate
class IsolateData {
  CameraImage cameraImage;
  List<dynamic> recognitions;
  Size screen;
  List<DataImageForCheck> listDataImgForCheck;
  int rotation_value;
  SendPort? responsePort;

  IsolateData(
    this.cameraImage,
    this.recognitions,
    this.screen,
    this.listDataImgForCheck,
    this.rotation_value,
  );
}

///แปลง Image Stream ในรูป yuv420 เป็นรูปภาพ
imglib.Image yuv420toImageColor(IsolateData isolateData) {
  print("yuv420toImageColor");
  CameraImage image = isolateData.cameraImage;
  int rotation_detect = isolateData.rotation_value;
  List listindex = [];
  List listuvIndex = [];
  int uvRowStride = image.planes[1].bytesPerRow;
  int? uvPixelStride = image.planes[1].bytesPerPixel;
  int width = image.width;
  int height = image.height;

  var img = imglib.Image(width, height); // Create Image buffer

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
      int index = y * width + x;
      listindex.add(index);
      listuvIndex.add(uvIndex);
    }
  }

  for (var i = 0; i < listuvIndex.length; i++) {
    var yp = image.planes[0].bytes[listindex[i]];
    var up = image.planes[1].bytes[listuvIndex[i]];
    var vp = image.planes[2].bytes[listuvIndex[i]];
    int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
    int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
        .round()
        .clamp(0, 255);
    int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
    img.data[listindex[i]] = (0xFF << 24) | (b << 16) | (g << 8) | r;
  }

  imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
  List<int> png = pngEncoder.encodeImage(img);
  final originalImage = imglib.decodeImage(png);
  final height1 = originalImage!.height;
  final width1 = originalImage.width;
  late imglib.Image fixedImage;

  if (height1 < width1) {
    fixedImage = imglib.copyRotate(originalImage, 90);
  }

  switch (rotation_detect) {
    case 360: //แนวนอนหมุนซ้าย
      fixedImage = imglib.copyRotate(fixedImage, 270);
      break;
    case 180: //แนวนอนหมุนขวา
      fixedImage = imglib.copyRotate(fixedImage, 90);
      break;
    case 270: //แนวตั้งกลับหัว
      fixedImage = imglib.copyRotate(fixedImage, 180);
      break;
    default: //แนวตั้งปกติ
      //fixedImage = imglib.copyRotate(fixedImage, 90);
      break;
  }

  return fixedImage;
}
