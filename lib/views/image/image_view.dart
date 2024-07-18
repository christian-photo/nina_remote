import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/state_manager.dart';
import 'package:nina_remote/util.dart';
import 'package:nina_remote/views/image/detail_image_viewer.dart';
import 'package:nina_remote/views/image/graph_view.dart';

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
      body: SingleChildScrollView(
        child: RefreshIndicator.adaptive(
          key: _refreshIndicatorKey,
          onRefresh: () => ref.refresh(refreshImageProvider.future),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: axisWidth, // maybe make it adjustable with a slider?
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 10,
                  ), 
                  shrinkWrap: true,
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
                const SizedBox(height: 50,),
                const Divider(),
                const SizedBox(height: 50,),
                GridView(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: axisWidth * 2,
                  ),
                  shrinkWrap: true, 
                  children: [
                    Column(
                      children: [
                        Text("HFR", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall,),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 40.0, 0.0),
                          child: SizedBox(
                            height: 250.0, 
                            child: Graph(data: getHfr(images), gradient: const [Colors.red, Colors.orange], topMargin: 1,)
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Median", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall,),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 40.0, 0.0),
                          child: SizedBox(
                            height: 250.0, 
                            child: Graph(data: getMean(images), gradient: const [Colors.red, Colors.orange], topMargin: 1000,)
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Mean", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall,),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 40.0, 0.0),
                          child: SizedBox(
                            height: 250.0, 
                            child: Graph(data: getMedian(images), gradient: const [Colors.red, Colors.orange], topMargin: 1000,)
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Stars", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall,),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 40.0, 0.0),
                          child: SizedBox(
                            height: 250.0, 
                            child: Graph(data: getStars(images), gradient: const [Colors.red, Colors.orange], topMargin: 500,)
                          ),
                        ),
                      ]
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isOnDesktopAndWeb ?
        FloatingActionButton.extended(
          heroTag: "test",
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

  List<double> getHfr(List<CapturedImage> images) {
    List<double> hfr = [];
    for (var image in images) {
      hfr.add((image.hfr * 1000).roundToDouble() / 1000);
    }
    return hfr;
  }

  List<double> getMean(List<CapturedImage> images) {
    List<double> hfr = [];
    for (var image in images) {
      hfr.add((image.mean * 1000).roundToDouble() / 1000);
    }
    return hfr;
  }

  List<double> getMedian(List<CapturedImage> images) {
    List<double> hfr = [];
    for (var image in images) {
      hfr.add((image.median * 1000).roundToDouble() / 1000);
    }
    return hfr;
  }

  List<double> getStars(List<CapturedImage> images) {
    List<double> stars = [];
    for (var image in images) {
      stars.add(image.stars.toDouble());
    }
    return stars;
  }
}