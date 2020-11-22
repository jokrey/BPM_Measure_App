import 'package:bpm_measure_app/adjustable_bpm_measure_widget.dart';
import 'package:bpm_measure_app/bpm_measure_widget.dart';
import 'package:bpm_measure_app/util.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BpmMeasureApp());
}

class BpmMeasureApp extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPM Measure',
      theme: ThemeData(),
      home: PageViewDemo(),
    );
  }
}