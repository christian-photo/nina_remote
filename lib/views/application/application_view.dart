import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nina_remote/core/api/api_helper.dart';

class ApplicationView extends StatefulWidget {
  ApplicationView({super.key});

  bool shouldPause = true;

  @override
  State<ApplicationView> createState() => _ApplicationViewState();
}

class _ApplicationViewState extends State<ApplicationView> {

  late ImageProvider _image;

  Future getNewImage() async {
    if (widget.shouldPause) {
      return;
    }
    Image screen = await ApiHelper.getScreenshot();
    setState(() {
      _image = screen.image;
    });
  }

  Future? imageFuture;

  @override
  void initState() {
    super.initState();
    imageFuture = getNewImage();
    Timer.periodic(const Duration(seconds: 2), (timer) => getNewImage());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Image(image: _image,); // TODO: Add ability to switch views in NINA
        }
        else {
          return const Center(child: CircularProgressIndicator(),);
        }
      }
    );
  }
}