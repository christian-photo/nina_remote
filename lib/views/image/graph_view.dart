import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Graph extends StatelessWidget {
  const Graph({super.key, required this.data, required this.topMargin, List<Color>? gradient}) : gradientColors = gradient ?? const [Colors.cyan, Colors.blue];

  final List<double> data;
  final int topMargin;

  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: topMargin.toDouble(),
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => const FlLine(
            color: Colors.grey,
            strokeWidth: 1
          ),
        ),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: 0,
        maxY: data.isNotEmpty ? (data.reduce(max) + topMargin).roundToDouble() : 10,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length, 
              (index) {
                return FlSpot(index.toDouble(), data[index]);
              },
            ),
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
          ),
        ],
      ),
    );
  }
}