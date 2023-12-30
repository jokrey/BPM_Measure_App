import 'package:bpm_measure_app/bpm_measure_widget.dart';
import 'package:bpm_measure_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BpmSettingsData extends ChangeNotifier {
  int _numClicksKept = 3;
  int get numClicksKept => _numClicksKept;
  set numClicksKept(int numClicksKept) {
    _numClicksKept = numClicksKept;
    notifyListeners();
  }

  int _numFullyWeightedClicks = 2;
  int get numFullyWeightedClicks => _numFullyWeightedClicks;
  set numFullyWeightedClicks(int numFullyWeightedClicks) {
    _numFullyWeightedClicks = numFullyWeightedClicks;
    notifyListeners();
  }

  num _baseForWeightExponential = 0.5;
  num get baseForWeightExponential => _baseForWeightExponential;
  set baseForWeightExponential(num baseForWeightExponential) {
    _baseForWeightExponential = baseForWeightExponential;
    notifyListeners();
  }

  Color _fgColor = Color.fromARGB(255, 140, 0, 0);
  Color get fgColor => _fgColor;
  set fgColor(Color fgColor) {
    _fgColor = fgColor;
    notifyListeners();
  }

  Color _bgColor = Color.fromARGB(255, 8, 15, 15);
  Color get bgColor => _bgColor;
  set bgColor(Color bgColor) {
    _bgColor = bgColor;
    notifyListeners();
  }

  void saveInSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('_numClicksKept', _numClicksKept);
    prefs.setInt('_numFullyWeightedClicks', _numFullyWeightedClicks);
    prefs.setDouble('_baseForWeightExponential', _baseForWeightExponential.toDouble());
    prefs.setInt('_fgColor', _fgColor.value);
    prefs.setInt('_bgColor', _bgColor.value);

    print("saved in shared");
  }
  void readFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _numClicksKept = prefs.getInt('_numClicksKept') ?? 3;
    _numFullyWeightedClicks = prefs.getInt('_numFullyWeightedClicks') ?? 2;
    _baseForWeightExponential = prefs.getDouble('_baseForWeightExponential') ?? 0.5;
    _fgColor = Color(prefs.getInt('_fgColor') ?? Color.fromARGB(255, 140, 0, 0).value);
    _bgColor = Color(prefs.getInt('_bgColor') ?? Color.fromARGB(255, 8, 15, 15).value);

    print("read from shared");
  }
}


class PageViewDemo extends StatefulWidget {
  @override _PageViewDemoState createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> with WidgetsBindingObserver {
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    settings.readFromSharedPreferences();
  }

  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive: case AppLifecycleState.paused: case AppLifecycleState.detached:
        settings.saveInSharedPreferences();
        break;
    }
  }

  @override void dispose() {
    settings.saveInSharedPreferences();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  final settings = BpmSettingsData();

  @override Widget build(BuildContext context) {
    var pageView = PageView(
      onPageChanged: (newPage) => FocusScope.of(context).unfocus(),
      controller: _controller,
      children: [
        BpmMeasureWidget(),
        BpmSettingsWidget(),
      ],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: settings,
        ),
      ],
      child: WillPopScope(
        onWillPop: () {
          if (_controller.page! < 0.5)
            return _controller.nextPage(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeOut,
            ).then((value) => true);
          else
            return _controller.previousPage(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeOut,
            ).then((value) => true);
        },
        child: pageView,
      ),
    );
  }
}


class BpmSettingsWidget extends StatefulWidget {
  BpmSettingsWidget({Key? key}) : super(key: key);
  @override _BpmSettingsWidgetState createState() => _BpmSettingsWidgetState();
}

class _BpmSettingsWidgetState extends State<BpmSettingsWidget> {
  @override Widget build(BuildContext context) {
    Color fgColor = Provider.of<BpmSettingsData>(context, listen: false).fgColor;
    Color bgColor = Provider.of<BpmSettingsData>(context, listen: false).bgColor;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          'Settings:',
          style: TextStyle(color: fgColor, fontWeight: FontWeight.bold, fontSize: 44),
        ),
      ),
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: Provider.of<BpmSettingsData>(context, listen: false)._numClicksKept.toString()),
              maxLines: 1,
              onChanged: (text) {
                if(text.isNotEmpty)
                  Provider.of<BpmSettingsData>(context, listen: false)._numClicksKept = text.isEmpty ? 1 : int.parse(text);
              },
              style: new TextStyle(color: fgColor),
              decoration: new InputDecoration(
                  labelStyle: new TextStyle(color: fgColor),
                  hintStyle: new TextStyle(color: fgColor.withOpacity(0.7)),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding:  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  labelText:"Number of Recorded Clicks: ",
                  hintText: "Please enter a number"),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: Provider.of<BpmSettingsData>(context, listen: false).numFullyWeightedClicks.toString()),
              maxLines: 1,
              onChanged: (text) {
                Provider.of<BpmSettingsData>(context, listen: false).numFullyWeightedClicks = text.isEmpty ? 1 : int.parse(text);
              },
              style: new TextStyle(color: fgColor),
              decoration: new InputDecoration(
                  labelStyle: new TextStyle(color: fgColor),
                  hintStyle: new TextStyle(color: fgColor.withOpacity(0.7)),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding:  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  labelText:"Number of Fully Weighted Clicks: ",
                  hintText: "Please enter a number"),
            ),
            TextField(
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              controller: TextEditingController(text: Provider.of<BpmSettingsData>(context, listen: false).baseForWeightExponential.toString()),
              maxLines: 1,
              onChanged: (text) {
                Provider.of<BpmSettingsData>(context, listen: false).baseForWeightExponential = text.isEmpty ? 1 : int.parse(text);
              },
              style: new TextStyle(color: fgColor),
              decoration: new InputDecoration(
                  labelStyle: new TextStyle(color: fgColor),
                  hintStyle: new TextStyle(color: fgColor.withOpacity(0.7)),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding:  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  labelText:"Base of exponential for weighted clicks: ",
                  hintText: "Please enter a number"),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: fgColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: bgColor)
                  )
                ),
                child: Text(
                  "Click to choose foreground color",
                  style: TextStyle(
                    color: bgColor
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Pick a color!'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: fgColor,
                          onColorChanged: (color) {
                            Provider.of<BpmSettingsData>(context, listen: false).fgColor = color;
                          },
                          showLabel: true,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Got it'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: fgColor)
                  ),
                ),
                child: Text(
                  "Click to choose background color",
                  style: TextStyle(
                    color: fgColor,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Pick a color!'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: bgColor,
                          onColorChanged: (color) {
                            Provider.of<BpmSettingsData>(context, listen: false).bgColor = color;
                          },
                          showLabel: true,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Got it'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}