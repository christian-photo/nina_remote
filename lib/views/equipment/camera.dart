import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/core/api/nina_event.dart';
import 'package:nina_remote/state_manager.dart';
import 'package:nina_remote/util.dart';

class CameraInfo {
  final String name;
  final bool isExposing;
  final double coolerPower;
  final bool dewHeaterOn;
  final double temperature;
  final bool connected;
  final DateTime lastExposure;
  final int battery;
  final int offset;
  final int gain;

  CameraInfo(this.name, this.isExposing, this.coolerPower, this.dewHeaterOn, this.temperature, this.connected, this.lastExposure, this.battery, this.offset, this.gain);

  static CameraInfo empty() => CameraInfo("No name", false, double.nan, false, double.nan, false, DateTime.now(), -1, -1, -1);
  
  static CameraInfo fromJson(String responseString) {
    Map<String, dynamic> json = jsonDecode(responseString);
    json = json["Response"];

    if (!json["Connected"]) {
      return empty();
    }

    return CameraInfo(
      json['DisplayName'] ?? 'No name',
      json['IsExposing'] ?? false,
      double.parse(json['CoolerPower']),
      json['DewHeaterOn'] ?? false,
      double.parse(json['Temperature']),
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

class _CameraViewState extends ConsumerState<CameraView> with AutomaticKeepAliveClientMixin{

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Timer? _timer;

  void cameraRecieved(Map<String, dynamic> response) async {
    response = response["Response"];
    if (response["Event"] == "CAMERA-CONNECTION") {
      CameraInfo oldInfo = await ref.read(cameraInfoProvider.future);
      Future.delayed(const Duration(milliseconds: 100));
      CameraInfo newInfo = await ref.refresh(cameraInfoProvider.future);
      if (oldInfo.connected != newInfo.connected) {
        if (newInfo.connected) {
          addEvent(NINAEvent("${newInfo.name} Connected", DateTime.parse(response["Time"]), color: Colors.green), ref);
        }
        else {
          addEvent(NINAEvent("${oldInfo.name} Disconnected", DateTime.parse(response["Time"]), color: Colors.red), ref);
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    ApiHelper.addListener(cameraRecieved);
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => ref.refresh(cameraInfoProvider.future));
  }

  @override
  void dispose() {
    _timer?.cancel();
    ApiHelper.removeListener(cameraRecieved);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = ref.watch(cameraInfoProvider);

    return switch (provider) {
      AsyncData(:final value) => Scaffold(
        body: RefreshIndicator.adaptive(
          key: _refreshIndicatorKey,
          onRefresh: () => ref.refresh(cameraInfoProvider.future),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Camera name: ${value.name}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Exposing?  "),
                    Icon(value.isExposing ? Icons.check : Icons.close),
                  ],
                ),
                Text("Cooler power: ${value.coolerPower}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Dew Heater on?  "),
                    Icon(value.dewHeaterOn ? Icons.check : Icons.close),
                  ],
                ),
                Text("Temperature: ${value.temperature}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Connected?  "),
                    Icon(value.connected ? Icons.check : Icons.close),
                  ],
                ),
                Text("Last Exposure: ${DateFormat('HH:mm:ss').format(value.lastExposure)}"),
                Text("Battery: ${value.battery}"),
                Text("Offset: ${value.offset}"),
                Text("Gain: ${value.gain}"),
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
      ),
      _ => const Center(
        child: CircularProgressIndicator(),
      ),
    };
  }
}