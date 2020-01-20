import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  other,
  location,
}

final _lightTheme = {
  _Element.background: Color(0xFF01A79B),
 // _Element.text: Color(0xFF657786),
  _Element.other: Colors.white,
  _Element.location: Color(0xFF657786)
};

final _darkTheme = {
  _Element.background: Color(0xFF2E2E2E),
  _Element.text: Color(0xFF657786),
  _Element.other: Color(0xFFE44162),
  _Element.location: Color(0xFFE44162)
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  var _condition = '';
  double _temperature;
  var _formatedTemp = '';
  var _unit = '';
  var _location = '';
  bool _is24format = false;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
      _condition = widget.model.weatherString;
      _temperature = widget.model.temperature;
      _unit = widget.model.unitString;
      _formatedTemp = _temperature.round().toString() + _unit;
      _location = widget.model.location;
      _is24format = widget.model.is24HourFormat;
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.

      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final rawHour = DateFormat('HH').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final seconds = DateFormat('s').format(_dateTime);
    final tempSize = MediaQuery.of(context).size.width / 7.0;
    final iconSize = MediaQuery.of(context).size.width / 5;

    final customTextStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Roboto-Light',
    );
    final weatherStyle = TextStyle(
      color: colors[_Element.other],
      fontFamily: 'Meteocons',
      fontSize: 4.5,
    );
    final tempStyle = TextStyle(
      color: colors[_Element.other],
      fontFamily: 'Roboto-Light',
      fontSize: tempSize,
    );
    final separatorStyle = TextStyle(
      color: changeColor(int.parse(seconds)),
      height: 1.0,
    );

    return Container(
     color: colors[_Element.background],
      child: Row(
        children: <Widget>[
         Expanded(
           // child: DefaultTextStyle(
            //  style: customTextStyle,
            child:   Padding(
                padding: EdgeInsets.all(10),
                child: FittedBox(
                  alignment: Alignment.center,
                 // fit: BoxFit.fitWidth,
                  child: Column(
                    //mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      getFormat(_is24format, _dateTime),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(hour,style: TextStyle(color: Colors.white,fontSize: 10),),
                            Text(
                              ":",
                              style: separatorStyle,
                            ),
                            Text(minute,style: TextStyle(color: Colors.white,fontSize: 10)),
                          ],
                        ),
                      ),
                      Column(
                mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                     Text(
                        _location,
                       // maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 2,
                          color: Colors.white,
                        ),
                      ),   
                      ],),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                     getWeather(_condition, int.parse(rawHour)),
                     style: weatherStyle,
                   ),
                  
                    Text("   "+
                     _formatedTemp,
                  style: TextStyle(color: Colors.white,fontSize: 2),
                            ),
                          ],
                        ),
                      // Text(
                      //   _location,
                      //   maxLines: 2,
                      //   softWrap: true,
                      //   style: TextStyle(
                      //     fontSize: 10,
                      //     color: colors[_Element.location],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          //),
          // Container(
          //   width: MediaQuery.of(context).size.width * 0.4218759,
          //   color: colors[_Element.background],
          //   child: Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         Text(
          //           getWeather(_condition, int.parse(rawHour)),
          //           style: weatherStyle,
          //         ),
          //         Text(
          //           _formatedTemp,
                    
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
      
    );
  }
}

String getWeather(String weather, int hour) {
  bool isDay = false;
  if (hour >= 6 && hour < 19) {
    //day
    isDay = true;
  } else {
    //night
    isDay = false;
  }

  if (weather == 'cloudy') {
    if (isDay)
      return 'C';
    else
      return 'I';
  } else if (weather == 'foggy') {
    if (isDay)
      return 'F';
    else
      return 'K';
  } else if (weather == 'rainy') {
    return 'R';
  } else if (weather == 'snowy') {
    return 'S';
  } else if (weather == 'sunny') {
    if (isDay)
      return 'S';
    else
      return 'C';
  } else if (weather == 'thunderstorm') {
    return 'T';
  } else if (weather == 'windy') {
    return 'W';
  }
}

Color changeColor(int second) {
  if (second % 2 == 0) {
    return Color(0xFF657786);
  } else {
    return Colors.white;
  }
}

Text getFormat(bool _is24Format, DateTime _dateTime) {
  if (_is24Format) {
    return Text(
      '',
      style: TextStyle(fontSize: 0),
    );
  } else {
    var ampm = DateFormat('a').format(_dateTime);
    return Text(
      ampm,
      textAlign: TextAlign.end,
      style: TextStyle(
        fontSize: 5,
      ),
    );
  }
}