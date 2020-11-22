import 'dart:collection';
import 'dart:math' as math;
import 'package:bpm_measure_app/adjustable_bpm_measure_widget.dart';
import 'package:bpm_measure_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BpmMeasureWidget extends StatefulWidget {
  BpmMeasureWidget({Key key}) : super(key: key);
  @override _BpmMeasureWidgetState createState() => _BpmMeasureWidgetState();
}

class _BpmMeasureWidgetState extends State<BpmMeasureWidget> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentBPM = 0;

  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      clicks.clear();
      recalculateCurrentBPM();
    };
  }
  AnimationController _animationController;
  Animation _animation;
  @override void initState() {
    // clicks.addFirst(DateTime.now().millisecondsSinceEpoch);

    super.initState();
    _animationController = AnimationController(vsync:this,duration: Duration(milliseconds: 100));
    _animation = Tween(begin: 5.0,end: 20.0).animate(_animationController)..addListener((){
      setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
  }
  @override void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<BpmSettingsData>(context, listen: false).bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: click,
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            print("swipe left");
          }
        },
        child:Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              var size = math.min(constraints.maxWidth, constraints.maxHeight);
              size = size * 0.666666;
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Provider.of<BpmSettingsData>(context, listen: false).bgColor,
                    boxShadow: [BoxShadow(
                        color: Provider.of<BpmSettingsData>(context, listen: false).fgColor,
                        blurRadius: _animation.value,
                        spreadRadius: _animation.value
                    )]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$_currentBPM',
                      style: TextStyle(color: Provider.of<BpmSettingsData>(context, listen: false).fgColor, fontWeight: FontWeight.bold, fontSize: 111),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Queue<int> clicks = Queue();
  void recalculateCurrentBPM() {
    _animationController.forward().then((value) => _animationController.reverse());
    int numFullyWeightedClicks = Provider.of<BpmSettingsData>(context, listen: false).numFullyWeightedClicks;
    double baseForWeightExponential = Provider.of<BpmSettingsData>(context, listen: false).baseForWeightExponential;

    setState(() {
      if(clicks.length < 2) {
        _currentBPM = 0;
      } else {
        double weightedSum = 0;
        double weightSum = 0;

        int lastClick = clicks.first;
        int i=1;
        for(var click in clicks.skip(1)) {
          int clickDelay = (lastClick-click).abs();
          lastClick = click;

          int expI = i - numFullyWeightedClicks;
          double weight = expI < 0 ? 1 : math.pow(baseForWeightExponential, expI);
          weightedSum += clickDelay * weight;
          weightSum += weight;
          i++;
          print("weight: $weight");
        }

        int weightedAverageClickDelay = (weightedSum/weightSum).round();
        _currentBPM = ((1000*60)/weightedAverageClickDelay).round();
      }
    });
  }

  void click() {
    int numClicksKept = Provider.of<BpmSettingsData>(context, listen: false).numClicksKept;
    int now = DateTime.now().millisecondsSinceEpoch;
    if(clicks.length > numClicksKept)
      clicks.removeLast();
    clicks.addFirst(now);

    recalculateCurrentBPM();
  }
}