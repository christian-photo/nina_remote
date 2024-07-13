import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/state_manager.dart';
import 'package:nina_remote/util.dart';
import 'package:nina_remote/views/image/detail_image_viewer.dart';

class CapturedImage {
  final Image thumbnail;
  final int index;
  final int stars;
  final String filter;
  final int gain;
  final int offset;
  final double median;
  final String rmsText;
  final double hfr;
  final double exposureTime;
  final double stDev;
  final double mean;
  final DateTime date;
  final double temperature;
  final String cameraName;
  final String telescopeName;
  final double focalLength;

  CapturedImage(
    this.thumbnail, 
    this.index, 
    this.stars, 
    this.filter, 
    this.gain,
    this.offset,
    this.median, 
    this.rmsText, 
    this.hfr, 
    this.exposureTime, 
    this.stDev, 
    this.mean, 
    this.date,
    this.temperature,
    this.cameraName,
    this.telescopeName,
    this.focalLength
  );
}

class ImageView extends ConsumerStatefulWidget {
  const ImageView({super.key});

  @override
  ConsumerState<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends ConsumerState<ImageView> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  double axisWidth = 300;

  void socketRecieved(Map<String, dynamic> response) async {
    response = response["Response"];
    if (response["Event"] == "IMAGE-SAVE") {
      CapturedImage image = CapturedImage(
        await ApiHelper.getThumbnail(response["Index"].toString()),
        response["Index"],
        response["Stars"],
        response["Filter"],
        response["Gain"],
        response["Offset"],
        response["Median"],
        response["RmsText"],
        response["HFR"],
        response["ExposureTime"],
        response["StDev"],
        response["Mean"],
        DateTime.parse(response["Date"]),
        double.parse(response["Temperature"]),
        response["CameraName"],
        response["TelescopeName"],
        response["FocalLength"],
      );
      ref.read(capturedImagesProvider.notifier).state = [...ref.read(capturedImagesProvider), image];
    }
  }

  @override
  void initState() {
    super.initState();

    ApiHelper.addListener(socketRecieved);
  }

  @override
  void dispose() {
    ApiHelper.removeListener(socketRecieved);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final images = ref.watch(capturedImagesProvider);

    return Scaffold(
      body: RefreshIndicator.adaptive(
        key: _refreshIndicatorKey,
        onRefresh: () => ref.refresh(refreshImageProvider.future),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: axisWidth, // maybe make it adjustable with a slider?
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 10,
          ), 
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(image: images[index])));
              },
              child: Hero(
                tag: images[index].index,
                child: Image(image: images[index].thumbnail.image),
              ),
            );
          },
        ),
      ),
      floatingActionButton: isOnDesktopAndWeb ?
        FloatingActionButton.extended(
        onPressed: () => _refreshIndicatorKey.currentState?.show(), 
        label: const Text("Refresh"), 
        icon: const Icon(Icons.refresh_outlined),
      ) : null,
      /* extendBody: false,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
        child: SizedBox.shrink(
          child: Slider(
            value: axisWidth, 
            min: 100, 
            max: 700, 
            onChanged: (newPos) {
              setState(() => axisWidth = newPos);
            }
          ),
        ),
      ), */
    );
  }
}