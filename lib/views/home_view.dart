import 'package:flutter/material.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/views/application/application_view.dart';
import 'package:nina_remote/views/equipment/equipment_view.dart';
import 'package:nina_remote/views/image/image_view.dart';
import 'package:nina_remote/views/settings_view.dart';
import 'package:nina_remote/views/timeline/timeline_view.dart';
import 'package:nina_remote/widgets/app_notification.dart';
import 'package:websocket_universal/websocket_universal.dart';

import '../main.dart';

class HomeViewPage extends StatefulWidget {
  const HomeViewPage({super.key, required this.ip, required this.port});

  final String ip;
  final String port;

  @override
  State<HomeViewPage> createState() => _HomeViewPagStateState();
}

class _HomeViewPagStateState extends State<HomeViewPage> {

  late final Future connectFuture;

  Future connect() async {
    if (await ApiHelper.connect()) {
      ApiHelper.socket?.socketHandlerStateStream.listen((event) {
        if (event.status == SocketStatus.disconnected) {
          if (mounted) {
            showNotification(context, NotificationType.error, "Socket disconnected!", 5000);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ConnectPage()));
          }
        }
      });
    }
    else {
      if (mounted) {
        showNotification(context, NotificationType.error, "Failed to connect!", 5000);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ConnectPage()));
      }
    }
  }

  late final List<Widget> views;
  int viewIndex = 0;

  final EquipmentView _equipmentView = const EquipmentView();
  final ImageView _imageView = const ImageView();
  final TimelineView _timelineView = const TimelineView();
  final ApplicationView _applicationView = ApplicationView();
  final SettingsView _settingsView = const SettingsView();

  @override
  void initState() {
    super.initState();

    connectFuture = connect();

    views = [_equipmentView, _imageView, _applicationView, _timelineView, _settingsView];

    viewIndex = 0;
  }

  @override
  void dispose() {
    ApiHelper.disconnect();

    super.dispose();
  }

  void changePage(int value) {
  if (value != viewIndex && viewIndex == 2) {
      _applicationView.shouldPause = true;
    }
    else if (value == 2 && viewIndex != 2) {
      _applicationView.shouldPause = false;
    }
    setState(() {
      viewIndex = value;
    });
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
                    changePage(value);
                  },
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        onPressed: () {
                          ApiHelper.disconnect();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ConnectPage()));
                        }, 
                        icon: const Icon(Icons.logout_outlined, color: Colors.red,),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.camera_alt_outlined), label: Text("Equipment")),
                    NavigationRailDestination(icon: Icon(Icons.image_outlined), label: Text("Image")),
                    NavigationRailDestination(icon: Icon(Icons.video_camera_back_outlined), label: Text("Application")),
                    NavigationRailDestination(icon: Icon(Icons.timeline_outlined), label: Text("Timeline")),
                    NavigationRailDestination(icon: Icon(Icons.settings_outlined), label: Text("Settings")),
                  ],
                ),
                Expanded(
                  child: IndexedStack(
                    index: viewIndex,
                    children: views,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}