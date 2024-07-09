import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/api_helper.dart';
import 'package:nina_remote/util.dart';

class CameraInfo {
  final String name;
  final bool isExposing;
  final String coolerPower;
  final bool dewHeaterOn;
  final String temperature;
  final bool connected;
  final DateTime lastExposure;
  final int battery;
  final int offset;
  final int gain;

  CameraInfo(this.name, this.isExposing, this.coolerPower, this.dewHeaterOn, this.temperature, this.connected, this.lastExposure, this.battery, this.offset, this.gain);

  static CameraInfo empty() => CameraInfo("No name", false, "-1", false, "no temperature", false, DateTime.now(), -1, -1, -1);
  
  static CameraInfo fromJson(String responseString) {
    Map<String, dynamic> json = jsonDecode(responseString);
    json = json["Response"];
    return CameraInfo(
      json['DisplayName'] ?? 'No name',
      json['IsExposing'] ?? false,
      json['CoolerPower'] ?? "-1",
      json['DewHeaterOn'] ?? false,
      json['Temperature'] ?? "no temperature",
      json['Connected'] ?? false,
      DateTime.parse(json['ExposureEndTime'] ?? '1970-01-01T00:00:00Z'),
      json['Battery'] ?? -1,
      json['Offset'] ?? -1,
      json['Gain'] ?? -1
    );
  }
}

class CameraView extends ConsumerStatefulWidget {
  const CameraView({super.key});

  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView> {

  late Future fetching;
  CameraInfo currentInfo = CameraInfo.empty();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Future fetch() async {
    try {
      String responseString = await ApiHelper.getEquipment("camera");

      setState(() {
        currentInfo = CameraInfo.fromJson(responseString);
      });
    }
    catch (e) {
      print(e);
      // TODO: show error using local notification
    }
    return;
  }

  @override
  void initState() {
    super.initState();

    fetching = fetch();
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
        }
        else {
          return Scaffold(
            body: RefreshIndicator.adaptive(
              key: _refreshIndicatorKey,
              onRefresh: () => fetch(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Camera name: ${currentInfo.name}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Exposing?  "),
                        Icon(currentInfo.isExposing ? Icons.check : Icons.close),
                      ],
                    ),
                    Text("Cooler power: ${currentInfo.coolerPower}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Dew Heater on?  "),
                        Icon(currentInfo.dewHeaterOn ? Icons.check : Icons.close),
                      ],
                    ),
                    Text("Temperature: ${currentInfo.temperature}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Connected?  "),
                        Icon(currentInfo.connected ? Icons.check : Icons.close),
                      ],
                    ),
                    Text("Last Exposure: ${currentInfo.lastExposure}"),
                    Text("Battery: ${currentInfo.battery}"),
                    Text("Offset: ${currentInfo.offset}"),
                    Text("Gain: ${currentInfo.gain}"),
                  ],
                ),
              ), 
            ),
            floatingActionButton: isOnDesktopAndWeb ?
              FloatingActionButton.extended(
              onPressed: () => _refreshIndicatorKey.currentState?.show(), 
              label: const Text("Refresh"), 
              icon: const Icon(Icons.refresh_outlined),
            ) : null
          );
        }
      },
    );
  }
}