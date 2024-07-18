import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/core/api/api_helper.dart';
import 'package:nina_remote/core/api/nina_event.dart';
import 'package:nina_remote/state_manager.dart';

class TimelineOnlyEvents extends ConsumerStatefulWidget {
  const TimelineOnlyEvents({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TimelineOnlyEvents> createState() => _TimelineOnlyEventsState();
}

class _TimelineOnlyEventsState extends ConsumerState<TimelineOnlyEvents> {

  void timelineRecieved(Map<String, dynamic> responseJson) {
    responseJson = responseJson["Response"];

    if (responseJson["Event"] == "NINA-ADV-SEQ-START") {
      addEvent(NINAEvent("Advanced Sequence Started", DateTime.now(), color: Colors.blue), ref);
    }
    else if (responseJson["Event"] == "NINA-ADV-SEQ-STOP") {
      addEvent(NINAEvent("Advanced Sequence Stopped", DateTime.now(), color: Colors.orange), ref);
    }
    else if (responseJson["Event"] == "NINA-ERROR-AF") {
      addEvent(NINAEvent("Autofocus failed!", DateTime.now(), color: Colors.red), ref);
    }
    
  }

  @override
  void initState() {
    super.initState();

    ApiHelper.addListener(timelineRecieved);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}