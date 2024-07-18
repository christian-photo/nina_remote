import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationView extends StatefulWidget {
  ApplicationView({super.key});

  bool shouldPause = true;

  @override
  State<ApplicationView> createState() => _ApplicationViewState();
}

class _ApplicationViewState extends State<ApplicationView> {

  late ImageProvider _image = Image.asset('assets/images/image-placeholder.bmp').image;
  late bool _shouldCapture = true;

  Future getNewImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _shouldCapture = prefs.getBool('automatic-screen-capture') ?? true;
    if (widget.shouldPause || !_shouldCapture) {
      return;
    }
    await setNewImage();
  }

  Future setNewImage() async {
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
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(image: _image,),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await setNewImage();
                }, 
                child: const Text("New Screenshot"),
              ),
            ),
          ); // TODO: Add ability to switch views in NINA
        }
        else {
          return const Center(child: CircularProgressIndicator(),);
        }
      }
    );
  }
}