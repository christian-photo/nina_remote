import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/api_helper.dart';
import 'package:nina_remote/views/equipment/camera.dart';
import 'package:nina_remote/views/image_view.dart';

final cameraInfoProvider = FutureProvider<CameraInfo>((ref) async {
  CameraInfo currentInfo = CameraInfo.empty();
  try {
    String responseString = await ApiHelper.getEquipment("camera");

    currentInfo = CameraInfo.fromJson(responseString);
  }
  catch (e) {
    print(e);
    // TODO: show error using local notification
  }
  return currentInfo;
});

List<CapturedImage> _capturedImages = [];

final capturedImageProvider = FutureProvider<List<CapturedImage>>((ref) async {
  List<Image> thumbnails = []; // TODO: implement lazy loading using the grid builder

  int diff = await ApiHelper.getImageCount() - _capturedImages.length;
  int startImage = 0;
  if (diff > 0 && _capturedImages.isNotEmpty) {
    startImage = _capturedImages.length;
    for (int i = 0; i < diff; i++) {
      thumbnails.add(await ApiHelper.getThumbnail((startImage + i).toString()));
      print("Got $i");
    }
  }
  else if (diff == 0) {
    return _capturedImages;
  }
  else {
    thumbnails = await ApiHelper.getThumbnails();
    print("Got all");
  }
  
  var infos = jsonDecode(await ApiHelper.getHistory())["Response"];

  for (int i = startImage; i < startImage + diff; i++) {
    dynamic info = infos[i];
    _capturedImages.add(
      CapturedImage(
        thumbnails[i - startImage],
        info["Id"] - 1, 
        info["Stars"], 
        info["Filter"], 
        info["RotatorPosition"] ?? double.nan, 
        info["Median"] ?? double.nan, 
        info["Rms"] ?? double.nan, 
        info["RmsText"], 
        info["Hfr"] ?? double.nan, 
        info["Duration"] ?? double.nan, 
        info["StDev"] ?? double.nan,
        info["Mean"] ?? double.nan,
        DateTime.parse(info["DateTime"] ?? "1970-01-01T00:00:00Z")
      )
    );
  }

  return _capturedImages;
});