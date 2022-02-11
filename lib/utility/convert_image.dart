// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:camera/camera.dart';
// import 'package:image/image.dart' as imglib;
// import 'package:non_helmet_mobile/models/data_image.dart';
// import 'package:non_helmet_mobile/models/model_tflite.dart';
// import 'package:non_helmet_mobile/models/position_image.dart';
// import 'package:non_helmet_mobile/utility/utility.dart';

// ///แปลงรูปภาพพร้อม Crop
// List<ListResultImage> convertImage(listdata) {
//   print("convertImage");
//   ////////////////////////ตัวแปร////////////////////////////////////////
//   CameraImage image = listdata[0]; //ไฟล์รูปจาก CameraImage
//   List<dynamic>? recognitions = listdata[1]; //ข้อมูลที่ได้จากการตรวจจับ
//   List<DataAveColor> listAvgColors = listdata[3]; //ลิสสำหรับเก็บค่าเฉลี่ยสี
//   int rotation_detect = listdata[4]; //ลิสสำหรับเก็บค่าเฉลี่ยสี
//   List<DataDetectedImage> listDataImage = []; //ลิสเก็บข้อมูลรูปภาพ
//   List<ListResultImage> listresult = []; //ลิสคำตอบที่จะรีเทิร์นกลับ
//   List<ModelTflite> recogNew = []; //ลิสค่า Recognition ใหม่
//   List<dynamic> dataforTrack = [];
//   int? checkColorImg;
//   int? avgColorID;
//   /////////////////////////////////////////////////////////////////////
//   print("2222 2 = $listAvgColors");
//   int countlistAvg = listAvgColors.length;
//   //รูปกรณีมีมากกว่า 1 คันใน 1 ภาพ
//   for (var i = 0; i < recognitions!.length; i++) {
//     if (recognitions[i]["detectedClass"] == "Rider") {
//       //recogNew.add(recognitions[i]);
//       recogNew.add(ModelTflite(recognitions[i], null, null));
//     }
//   }

//   //ตรวจสอบคลาส
//   if (recogNew.isNotEmpty) {
//     for (var i = 0; i < recogNew.length; i++) {
//       // print("recogNew : ${recogNew[i]}");
//       for (var y = 0; y < recognitions.length; y++) {
//         if (recognitions[y]["detectedClass"] != "Rider") {
//           double resultCheck = isObject(recogNew[i].rider, recognitions[y]);
//           //print("resultCheck = $resultCheck");
//           if (resultCheck > 0.02) {
//             // print("recogNew : ${recogNew[i]}");
//             // print("recognitions : ${recognitions[y]}");
//             if (recognitions[y]["detectedClass"] == "None-helmet") {
//               recogNew[i] = ModelTflite(recogNew[i].rider, recognitions[y],
//                   recogNew[i].license_plate);
//             } else if (recognitions[y]["detectedClass"] == "License-plate") {
//               recogNew[i] = ModelTflite(
//                   recogNew[i].rider, recogNew[i].helmet, recognitions[y]);
//             }
//           }
//         }
//       }
//       // if (recogNew[i].helmet == null || recogNew[i].license_plate == null) {
//       //   recogNew.removeAt(i);
//       // } else {}
//     }

//     //ตรวจสอบให้เหลือคลาสที่จะนำไปใช้
//     if (recogNew.isNotEmpty) {
//       for (var i = 0; i < recogNew.length; i++) {
//         if (recogNew[i].helmet == null || recogNew[i].license_plate == null) {
//           recogNew.removeAt(i);
//         } else {}
//       }
//     } else {
//       return [];
//     }
//     print("recogNew = $recogNew");
//     print("recogNew = ${recogNew.length}");
//     // print("rider = ${recogNew.first.rider}");
//     // print("helmet = ${recogNew.first.helmet}");
//     // print("license_plate = ${recogNew.first.license_plate}");

//     if (recogNew.isNotEmpty) {
//       //แปลง image stream to image
//       imglib.Image fixedImage = yuv420toImageColor(image, rotation_detect);

//       for (var i = 0; i < recogNew.length; i++) {
//         //รับตำแหน่งภาพที่ได้จากการตรวจจับ Class Rider
//         PositionImage coorRider = imagePosition(listdata, recogNew[i].rider);

//         //ฟังก์ชัน Crop รูป Class Rider
//         imglib.Image destImageRider = copyCropp(
//           fixedImage, //ไฟล์รูปที่ได้จากการแปลง
//           coorRider.x.round(), //ค่า x
//           coorRider.y.round(), //ค่า y
//           coorRider.w.round(), //ค่า w
//           coorRider.h.round(), //ค่า h
//         );

//         //ฟังก์ชัน Crop รูป Class Rider สำหรับนำไปเช็คค่า
//         imglib.Image destImageCheck = copyCropp(
//             destImageRider, //ไฟล์รูปที่ได้จากการแปลง
//             (destImageRider.width / 4).round(), //ค่า x
//             (destImageRider.height / 4).round(), //ค่า y
//             (destImageRider.width / 2).round(), //ค่า w
//             (destImageRider.height / 2).round()); //ค่า h

//         //ไฟล์ภาพ Class Rider ที่ได้ Crop แล้ว
//         var riderImage = imglib.encodeJpg(destImageCheck) as Uint8List?;
//         //ไฟล์ภาพ Class Rider ที่ได้ Crop แล้ว สำหรับนำไปเช็คค่า
//         var checkImage = imglib.encodeJpg(destImageCheck) as Uint8List?;

//         //รับค่าสี
//         Color averageColor = getAverageColor(checkImage!);
//         //print("averageColor = ${averageColor}");
//         print("listAvgColors 3 = $listAvgColors");
//         print("listAvgColors 3 = $countlistAvg");

//         if (countlistAvg != listAvgColors.length) {
//           return [];
//         }

//         print("riderImage 1 = $listAvgColors");

//         if (listAvgColors.isNotEmpty) {
//           //เปรียบเทียบค่าสี
//           for (var i = 0; i < listAvgColors.length; i++) {
//             checkColorImg =
//                 compareColor(averageColor, listAvgColors[i].avgColor);
//             print("checkColorImg = $checkColorImg");
//             // 75 = เปอร์เซ็นการ Macth ของสี
//             if (checkColorImg > 75) {
//               avgColorID = listAvgColors[i].id;
//               riderImage = null;
//               break;
//             } else {
//               continue;
//             }
//           }
//         }

//         print("riderImage 2 = $riderImage");
//         print("riderImage 3 = $checkColorImg");

//         if (riderImage != null) {
//           //รับตำแหน่งภาพที่ได้จากการตรวจจับ Class License
//           PositionImage coorlicenseP =
//               imagePosition(listdata, recogNew[i].license_plate);

//           //ฟังก์ชัน Crop รูป Class license plate
//           imglib.Image destImagesLicense = copyCropp(
//               fixedImage, //ไฟล์รูปที่ได้จากการแปลง
//               coorlicenseP.x.round(), //ค่า x
//               coorlicenseP.y.round(), //ค่า y
//               min(coorlicenseP.w.round(),
//                   fixedImage.width - coorlicenseP.x.round()), //ค่า w
//               min(coorlicenseP.h.round(),
//                   fixedImage.height - coorlicenseP.y.round())); //ค่า h

//           var licensePlateImg =
//               imglib.encodeJpg(destImagesLicense) as Uint8List?;

//           listDataImage.add(DataDetectedImage(riderImage, licensePlateImg!));
//           dataforTrack.add({
//             "id": listAvgColors.length + 1,
//             "coorRider": recogNew[i].rider['rect'],
//             "confidenceTracking": checkColorImg ??= 100
//           });
//           listAvgColors
//               .add(DataAveColor(listAvgColors.length + 1, averageColor));
//         } else {
//           listDataImage = [];

//           dataforTrack.add({
//             "id": avgColorID,
//             "coorRider": recogNew[i].rider['rect'],
//             "confidenceTracking": checkColorImg ??= 100
//           });
//         }
//       }
//       // print("listFileImage = ${listFileImage}");
//       // print("listFileImage = ${listAvaColors}");
//       if (listDataImage.isNotEmpty) {
//         print("ListImageIsnotempty");
//         listresult
//             .add(ListResultImage(listDataImage, listAvgColors, dataforTrack));
//         return listresult;
//       } else {
//         listresult.add(ListResultImage([], [], dataforTrack));
//         return listresult;
//       }
//     } else {
//       return [];
//     }
//   } else {
//     return [];
//   }
// }

// ///แปลง Image Stream ในรูป yuv420 เป็นรูปภาพ
// imglib.Image yuv420toImageColor(CameraImage image, int rotation_detect) {
//   print("yuv420toImageColor");
//   List listindex = [];
//   List listuvIndex = [];
//   int uvRowStride = image.planes[1].bytesPerRow;
//   int? uvPixelStride = image.planes[1].bytesPerPixel;
//   int width = image.width;
//   int height = image.height;

//   var img = imglib.Image(width, height); // Create Image buffer
//   for (int x = 0; x < width; x++) {
//     for (int y = 0; y < height; y++) {
//       int uvIndex =
//           uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
//       int index = y * width + x;
//       listindex.add(index);
//       listuvIndex.add(uvIndex);
//     }
//   }
//   /* for (var i = 0; i < a.length; i++) { */
//   for (var i = 0; i < listuvIndex.length; i++) {
//     var yp = image.planes[0].bytes[listindex[i]];
//     var up = image.planes[1].bytes[listuvIndex[i]];
//     var vp = image.planes[2].bytes[listuvIndex[i]];
//     int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
//     int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
//         .round()
//         .clamp(0, 255);
//     int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
//     img.data[listindex[i]] = (0xFF << 24) | (b << 16) | (g << 8) | r;
//   }
//   /*  } */

//   imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
//   List<int> png = pngEncoder.encodeImage(img);
//   final originalImage = imglib.decodeImage(png);
//   final height1 = originalImage!.height;
//   final width1 = originalImage.width;
//   late imglib.Image fixedImage;
//   if (height1 < width1) {
//     fixedImage = imglib.copyRotate(originalImage, 90);
//   }
//   switch (rotation_detect) {
//     case 360: //แนวนอนหมุนซ้าย
//       fixedImage = imglib.copyRotate(fixedImage, 270);
//       break;
//     case 180: //แนวนอนหมุนขวา
//       fixedImage = imglib.copyRotate(fixedImage, 90);
//       break;
//     case 270: //แนวตั้งกลับหัว
//       fixedImage = imglib.copyRotate(fixedImage, 180);
//       break;
//     default: //แนวตั้งปกติ
//       //fixedImage = imglib.copyRotate(fixedImage, 90);
//       break;
//   }
//   return fixedImage;
// }
