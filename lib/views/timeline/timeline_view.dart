import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/state_manager.dart';
import 'package:nina_remote/views/timeline/event_tile.dart';

class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({super.key});

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {

  @override
  Widget build(BuildContext context) {

    final events = ref.watch(eventsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(child: Text("Timeline", style: Theme.of(context).textTheme.headlineMedium,)),
            ...List.generate(events.length, (index) {
              return EventTile(event: events[index], first: index == 0, last: events.length - 1 == index,);
            }),
          ],
        ),
      )
    );
  }
}