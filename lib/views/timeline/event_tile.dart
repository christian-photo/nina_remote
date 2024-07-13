import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nina_remote/core/api/nina_event.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, required this.first, required this.last});

  final NINAEvent event;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.3,
      beforeLineStyle: LineStyle(color: Colors.white.withOpacity(0.7)),
      indicatorStyle: IndicatorStyle(
        indicatorXY: 0.3,
        drawGap: true,
        width: 30,
        height: 30,
        color: event.color,
      ),
      isLast: last,
      isFirst: first,
      startChild: Center(
        child: Container(
          alignment: const Alignment(0.0, -0.50),
          child: Text(
            DateFormat('HH:mm').format(event.timestamp),
          ),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              event.name,
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}