import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/views/image/image_view.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.image});

  final CapturedImage image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Hero(
                    tag: image.index,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(image: image.thumbnail.image),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.adaptive.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text("Exposure time: ${image.exposureTime}"),
            Text(image.rmsText),
            Text("HFR: ${image.hfr}"),
            Text("Stars: ${image.stars}"),
            Text("Filter: ${image.filter}"),
            Text("Date: ${DateFormat('HH:mm:ss').format(image.date)}"),
            Text("Mean: ${image.mean}"),
            Text("Median: ${image.median}"),
            Text("StDev: ${image.stDev}"),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhotoViewer(index: image.index)));
          }, 
          child: const Text("Open fullres image"),
        ),
      ),
    );
  }
}

class FullPhotoViewer extends StatefulWidget {
  const FullPhotoViewer({super.key, required this.index});

  final int index;

  @override
  State<FullPhotoViewer> createState() => _FullPhotoViewerState();
}

class _FullPhotoViewerState extends State<FullPhotoViewer> {

  late final Future imageDownload;
  late final Image image;

  final PhotoViewController controller = PhotoViewController();

  @override
  void initState() {
    super.initState();

    imageDownload = loadImage();
  }

  Future loadImage() async {
    image = await ApiHelper.getImage(widget.index.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageDownload,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          return ScrollDetector(
            onPointerScroll: (event) {
              double currentScale = controller.scale!;
              double newScale = currentScale + event.scrollDelta.dy * -0.001;
              if (newScale > 0.46) {
                controller.scale = newScale;
              }
            },
            child: Stack(
              children: [
                PhotoView(
                  enablePanAlways: true,
                  enableRotation: false,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  controller: controller,
                  filterQuality: FilterQuality.high,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.index),
                  imageProvider: image.image,
                ),
                IconButton(
                  icon: Icon(Icons.adaptive.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class ScrollDetector extends StatelessWidget {
  final void Function(PointerScrollEvent event) onPointerScroll;
  final Widget child;

  const ScrollDetector({super.key, required this.onPointerScroll, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) onPointerScroll(pointerSignal);
      },
      child: child,
    );
  }
}