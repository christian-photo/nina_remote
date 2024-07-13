import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/state_manager.dart';
import 'package:nina_remote/util.dart';

class TelescopeInfo {
  final String name;
  final bool connected;
  final String declinationString;
  final String rightAscensionString;
  final bool parked;
  final String timeToMeridianFlip;
  final bool isSlewing;
  final bool isTracking;

  const TelescopeInfo(this.name, this.connected, this.declinationString, this.rightAscensionString, this.parked, this.timeToMeridianFlip, this.isSlewing, this.isTracking);

  static TelescopeInfo empty() => const TelescopeInfo("No name", false, "No declination", "No right ascension", false, "No time to meridian flip", false, false);

  static TelescopeInfo fromJson(String responseString) {
    Map<String, dynamic> json = jsonDecode(responseString);
    json = json["Response"];
    if (!json["Connected"]) {
      return empty();
    }
    return TelescopeInfo(
      json['DisplayName'] ?? 'No name',
      json['Connected'] ?? false,
      json['DeclinationString'] ?? 'No declination',
      json['RightAscensionString'] ?? 'No right ascension',
      json['AtPark'] ?? false,
      json['TimeToMeridianFlipString'] ?? 'No time to meridian flip',
      json['Slewing'] ?? false,
      json['TrackingEnabled'] ?? false
    );
  }
}

class TelescopeView extends ConsumerStatefulWidget {
  const TelescopeView({super.key});

  @override
  ConsumerState<TelescopeView> createState() => _TelescopeViewState();
}

class _TelescopeViewState extends ConsumerState<TelescopeView> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Timer? _timer;

  void telescopeRecieved(Map<String, dynamic> response) {
    response = response["Response"];
    if (response["Event"] == "TELESCOPE-CONNECTION") {
      Future.delayed(const Duration(milliseconds: 100));
      _refreshIndicatorKey.currentState?.show();
    }
  }

  @override
  void initState() {
    super.initState();
    
    ApiHelper.addListener(telescopeRecieved);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => ref.refresh(telescopeInfoProvider.future));
  }

  @override
  void dispose() {
    ApiHelper.removeListener(telescopeRecieved);
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(telescopeInfoProvider);

    return switch (provider) {
      AsyncData(:final value) => Scaffold(
        body: RefreshIndicator.adaptive(
          key: _refreshIndicatorKey,
          onRefresh: () => ref.refresh(telescopeInfoProvider.future),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Telescope name: ${value.name}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Parked?  "),
                    Icon(value.parked ? Icons.check : Icons.close),
                  ],
                ),
                Text("RA: ${value.rightAscensionString}"),
                Text("Dec: ${value.declinationString}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Connected?  "),
                    Icon(value.connected ? Icons.check : Icons.close),
                  ],
                ),
                Text("Time to meridian flip: ${value.timeToMeridianFlip}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Slewing?  "),
                    Icon(value.isSlewing ? Icons.check : Icons.close),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Tracking?  "),
                    Icon(value.isTracking ? Icons.check : Icons.close),
                  ],
                ),
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