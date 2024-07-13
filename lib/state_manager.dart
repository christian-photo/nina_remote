import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/views/equipment/camera.dart';
import 'package:nina_remote/views/equipment/telescope.dart';
import 'package:nina_remote/views/image_view.dart';

final cameraInfoProvider = FutureProvider<CameraInfo>((ref) async {
  CameraInfo currentInfo = CameraInfo.empty();
  String responseString = await ApiHelper.getEquipment("camera");

  currentInfo = CameraInfo.fromJson(responseString);
  return currentInfo;
});

final telescopeInfoProvider = FutureProvider<TelescopeInfo>((ref) async {
  TelescopeInfo currentInfo = TelescopeInfo.empty();
  String responseString = await ApiHelper.getEquipment("telescope");

  currentInfo = TelescopeInfo.fromJson(responseString);
  return currentInfo;
});


List<CapturedImage> _capturedImages = [];

final capturedImagesProvider = StateProvider<List<CapturedImage>>((ref) => _capturedImages);

final refreshImageProvider = FutureProvider<List<CapturedImage>>((ref) async {
  List<CapturedImage> images = await ApiHelper.getCapturedImages();
  ref.read(capturedImagesProvider.notifier).state = images;
  return images;
});