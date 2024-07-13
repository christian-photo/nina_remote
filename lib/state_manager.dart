import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/core/api/nina_event.dart';
import 'package:nina_remote/views/equipment/camera.dart';
import 'package:nina_remote/views/equipment/telescope.dart';
import 'package:nina_remote/views/image/image_view.dart';

CameraInfo _currentCameraInfo = CameraInfo.empty();
TelescopeInfo _currentTelescopeInfo = TelescopeInfo.empty();

final cameraInfoProvider = FutureProvider<CameraInfo>((ref) async {
  String responseString = await ApiHelper.getEquipment("camera");

  CameraInfo newInfo  = CameraInfo.fromJson(responseString);

  if (_currentCameraInfo.connected != newInfo.connected) {
    ref.read(eventsProvider.notifier).state = [
      ...ref.read(eventsProvider),
      NINAEvent(newInfo.connected ? "${newInfo.name} Connected" : "${_currentCameraInfo.name} Disconnected", DateTime.now(), color: newInfo.connected ? Colors.green : Colors.red)
    ];
  }

  _currentCameraInfo = newInfo;
  return _currentCameraInfo;
});

final telescopeInfoProvider = FutureProvider<TelescopeInfo>((ref) async {
  String responseString = await ApiHelper.getEquipment("telescope");

  TelescopeInfo newInfo = TelescopeInfo.fromJson(responseString);
  if (newInfo.connected != _currentTelescopeInfo.connected) {
    ref.read(eventsProvider.notifier).state = [
      ...ref.read(eventsProvider),
      NINAEvent(newInfo.connected ? "${newInfo.name} Connected" : "${_currentTelescopeInfo.name} Disconnected", DateTime.now(), color: newInfo.connected ? Colors.green : Colors.red)
    ];
  }

  _currentTelescopeInfo = newInfo;
  return _currentTelescopeInfo;
});


List<CapturedImage> _capturedImages = [];

final capturedImagesProvider = StateProvider<List<CapturedImage>>((ref) => _capturedImages);

final refreshImageProvider = FutureProvider<List<CapturedImage>>((ref) async {
  List<CapturedImage> images = await ApiHelper.getCapturedImages();
  ref.read(capturedImagesProvider.notifier).state = images;
  return images;
});

List<NINAEvent> _events = [];
final eventsProvider = StateProvider<List<NINAEvent>>((ref) => _events);