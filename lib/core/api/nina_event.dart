import 'package:flutter/material.dart';

class NINAEvent {
  final String name;
  final DateTime timestamp;
  final Color color;

  NINAEvent(this.name, this.timestamp, {this.color = Colors.blue});
}