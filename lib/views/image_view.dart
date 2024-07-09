import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/state_manager.dart';
import 'package:nina_remote/util.dart';
import 'package:nina_remote/views/detail_image_viewer.dart';

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
  final DateTime date;

  CapturedImage(this.thumbnail, this.index, this.stars, this.filter, this.rotatorPosition, this.median, this.rms, this.rmsText, this.hfr, this.exposureTime, this.stDev, this.mean, this.date);
}

class ImageView extends ConsumerStatefulWidget {
  const ImageView({super.key});

  @override
  ConsumerState<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends ConsumerState<ImageView> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  double axisWidth = 300;

  @override
  Widget build(BuildContext context) {

    final provider = ref.watch(capturedImageProvider);

    return switch (provider) {
      AsyncData(:final value) => Scaffold(
        body: RefreshIndicator.adaptive(
          key: _refreshIndicatorKey,
          onRefresh: () => ref.refresh(capturedImageProvider.future),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: axisWidth, // maybe make it adjustable with a slider?
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 10,
            ), 
            itemCount: value.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(image: value[index])));
                },
                child: Hero(
                  tag: "clicked-image",
                  child: Image(image: value[index].thumbnail.image),
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
      ),
      _ => const Center(
        child: CircularProgressIndicator(),
      ),
    };
  }
}