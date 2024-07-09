import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/api_helper.dart';
import 'package:nina_remote/views/equipment/camera.dart';

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