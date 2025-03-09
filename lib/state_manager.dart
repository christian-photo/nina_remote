import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/core/api/nina_event.dart';
import 'package:nina_remote/views/equipment/camera.dart';
import 'package:nina_remote/views/equipment/telescope.dart';
import 'package:nina_remote/views/image/image_view.dart';

final cameraInfoProvider = FutureProvider<CameraInfo>((ref) async {
  String responseString = await ApiHelper.getEquipmentInfo("camera");

  return CameraInfo.fromJson(responseString);
});

final telescopeInfoProvider = FutureProvider<TelescopeInfo>((ref) async {
  String responseString = await ApiHelper.getEquipmentInfo("mount");

  return TelescopeInfo.fromJson(responseString);
});

List<CapturedImage> _capturedImages = [];

final capturedImagesProvider =
    StateProvider<List<CapturedImage>>((ref) => _capturedImages);

final refreshImageProvider = FutureProvider<List<CapturedImage>>((ref) async {
  List<CapturedImage> images = await ApiHelper.getCapturedImages();
  ref.read(capturedImagesProvider.notifier).state = images;
  return images;
});

List<NINAEvent> _events = [];
final eventsProvider = StateProvider<List<NINAEvent>>((ref) => _events);

void addEvent(NINAEvent event, WidgetRef ref) {
  ref.read(eventsProvider.notifier).state = [
    ...ref.read(eventsProvider),
    event
  ];
}
