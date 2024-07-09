import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/api_helper.dart';
import 'package:nina_remote/util.dart';

class CapturedImage {
  final Image thumbnail;
  final int index;
  final int stars;
  final String filter;
  final double rotatorPosition;
  final double median;
  final double rms;
  final String rmsText;
  final double hfr;
  final double exposureTime;
  final double stDev;
  final double mean;

  CapturedImage(this.thumbnail, this.index, this.stars, this.filter, this.rotatorPosition, this.median, this.rms, this.rmsText, this.hfr, this.exposureTime, this.stDev, this.mean);
}

class ImageView extends ConsumerStatefulWidget {
  const ImageView({super.key});

  @override
  ConsumerState<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends ConsumerState<ImageView> {

  List<CapturedImage> images = [];

  Future fetchThumbnailsAndInfo() async {

    List<Image> thumbnails = []; // TODO: implement lazy loading using the grid builder

    int diff = await ApiHelper.getImageCount() - images.length;
    int startImage = 0;
    if (diff > 0 && images.isNotEmpty) {
      startImage = images.length;
      for (int i = 0; i < diff; i++) {
        thumbnails.add(await ApiHelper.getThumbnail((startImage + i).toString()));
        print("Got $i");
      }
    }
    else if (diff == 0) {
      return;
    }
    else {
      thumbnails = await ApiHelper.getThumbnails();
      print("Got all");
    }
    
    var infos = jsonDecode(await ApiHelper.getHistory())["Response"];

    for (int i = startImage; i < startImage + diff; i++) {
      dynamic info = infos[i];
      images.add(
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
          info["Mean"] ?? double.nan
        )
      );
    }
  }

  late final Future fetching;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    fetching = fetchThumbnailsAndInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetching,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            body: RefreshIndicator.adaptive(
              key: _refreshIndicatorKey,
              onRefresh: () => fetchThumbnailsAndInfo(),
              child: GridView.builder(
                
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300, // maybe make it adjustable with a slider?
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 10,
                ), 
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // TODO: open viewer page with image details
                    },
                    child: Image(image: images[index].thumbnail.image),
                  );
                }
              ), // TODO: Show thumbnails of all images (hero widget)
            ),
            floatingActionButton: isOnDesktopAndWeb ?
              FloatingActionButton.extended(
              onPressed: () => _refreshIndicatorKey.currentState?.show(), 
              label: const Text("Refresh"), 
              icon: const Icon(Icons.refresh_outlined),
            ) : null
          );
        }
      }
    );
  }
}