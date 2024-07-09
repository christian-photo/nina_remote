import 'package:flutter/material.dart';
import 'package:nina_remote/api_helper.dart';
import 'package:nina_remote/views/equipment_view.dart';
import 'package:nina_remote/views/image_view.dart';

import 'main.dart';

class HomeViewPage extends StatefulWidget {
  const HomeViewPage({super.key, required this.ip, required this.port});

  final String ip;
  final String port;

  @override
  State<HomeViewPage> createState() => __HomeViewPagStateState();
}

class __HomeViewPagStateState extends State<HomeViewPage> {

  late final Future connectFuture;

  Future connect() async {
    if (!await ApiHelper.connect()) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ConnectPage()));
      }
    }
  }

  late final List<Widget> views;
  int viewIndex = 0;

  @override
  void initState() {
    super.initState();

    connectFuture = connect();

    views = [const EquipmentView(), const ImageView(), const Text("hio0ihids0fhsdifh0sh"), const Text("Timeline view")];

    viewIndex = 0;
  }

  @override
  void dispose() {
    ApiHelper.disconnect();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: connectFuture,
      builder: (context, snapshot) {
        return SafeArea(
          child: Scaffold(
            body: snapshot.connectionState == ConnectionState.waiting ? const Center(
              child: CircularProgressIndicator(),
            ) :
            Row(
              children: [
                NavigationRail(
                  selectedIndex: viewIndex,
                  labelType: NavigationRailLabelType.selected,
                  onDestinationSelected: (value) {
                    setState(() {
                      viewIndex = value;
                    });
                  },
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.camera_alt_outlined), label: Text("Equipment")),
                    NavigationRailDestination(icon: Icon(Icons.image_outlined), label: Text("Image")),
                    NavigationRailDestination(icon: Icon(Icons.video_camera_back_outlined), label: Text("Application")),
                    NavigationRailDestination(icon: Icon(Icons.timeline_outlined), label: Text("Timeline")),
                  ],
                ),
                Expanded(child: views[viewIndex]),
              ],
            ),
          ),
        );
      }
    );
  }
}