import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nina_remote/state_manager.dart';

class GraphView extends ConsumerStatefulWidget {
  const GraphView({super.key});

  @override
  ConsumerState<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends ConsumerState<GraphView> {
  @override
  Widget build(BuildContext context) {

    final provider = ref.watch(capturedImagesProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            LineChart(
              LineChartData()
            )
          ],
        ),
      )
    );
  }
}