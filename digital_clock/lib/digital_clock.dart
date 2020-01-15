// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.blueGrey[100],
  _Element.text: Colors.black,
  _Element.shadow: Colors.cyan,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.blueGrey[200],
  _Element.shadow: Color(0xFF174EA6),
};


class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  double opacityLevel = 1.0;
  
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';

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
  
   void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0.8 ? 1.0 : 0.8);
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
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
    _changeOpacity();
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'h').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);

    // Golden Ratio Rectangles
    final rect1 = Rect.fromCenter(center: Offset(484,484), width: 966, height: 966);
    final rect2 = Rect.fromCenter(center: Offset(0,299), width: 598, height: 598);
    final rect3 = Rect.fromCenter(center: Offset(0,0), width: 370, height: 370);

    var defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'JosefinSans',
      fontWeight: FontWeight.w600,
      height: 0.9,
      fontSize: 10,
      // fontStyle: FontStyle.italic,
    
      shadows: [
        Shadow(
          blurRadius: 2,
          color: colors[_Element.shadow],
          offset: Offset(0.2, 0.2),
        ),
        
      ],
    );
    final weatherInfo = DefaultTextStyle(
      style: defaultStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature, style: TextStyle(fontSize: 30)),
          // Text(_temperatureRange),
          Text(_location,  style: TextStyle(fontSize: 20)),
        ],
      ),
    );



    return Stack(
      children: <Widget>[
        Container(
          
          color: colors[_Element.background]
          
        ),
        Positioned(
          width: 483,
          height: 483,
          bottom: 0,
          left: 12,
          child: CustomPaint(
            // child: Text(hour, style: defaultStyle.apply(fontSizeFactor: 50)),
            child: FittedBox(
          
              child: Text(
                hour, 
                style: defaultStyle.apply(
                  decoration: TextDecoration.underline, 
                  decorationColor: Colors.blueGrey[400],
                  // decorationStyle: TextDecorationStyle.wavy)
                ),
              ),
            ),
            painter: _SwirlPainter(
              lineWidth: 10,
              startAngle: math.pi,
              sweepAngle: math.pi/2,
              rect: rect1,
              color: Color(0xFFD4AF00),
            ),
          ),
        ),
        Positioned(
          width: 299,
          height: 299,
          top: 0,
          right: 12,
          child: CustomPaint(
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                minute,
                style: defaultStyle.apply(
                  decoration: TextDecoration.underline, 
                  decorationColor: Colors.blueGrey[400],
                  // decorationStyle: TextDecorationStyle.dotted
                ),
              ),
            ),
            painter: _SwirlPainter(
              lineWidth: 9.2,
              startAngle: math.pi*3/2,
              sweepAngle: math.pi/2,
              rect: rect2,
              color: Color(0xFFD4AF00),
            ),
          ),
        ),
        Positioned(
          width: 185,
          height: 185,
          bottom: 0,
          right: 12,
          child: CustomPaint(
            child: FittedBox(
              fit: BoxFit.fill,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 900),
                opacity: opacityLevel,
                curve: Curves.easeOutQuart,
                child: Text(second, style: defaultStyle)
              )
            ),
            painter: _SwirlPainter(
              lineWidth: 8.4,
              startAngle: 0,
              sweepAngle: math.pi/2,
              rect: rect3,
              color: Color(0xFFD4AF00),
            ),
          ),
        ),
        Positioned(
          width: 114,
          height: 114,
          bottom: 0,
          right: 197,
          child: Container(
            child: weatherInfo,
          )
        ),
        Positioned(
          width: 71,
          height: 71,
          bottom: 114,
          left: 495,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.wb_sunny,
              color: Colors.yellow,
            ),
          ),
        ),
      ],
    );
  }
}



class _SwirlPainter extends CustomPainter {

  _SwirlPainter({
    @required this.lineWidth,
    @required this.startAngle,
    @required this.sweepAngle,
    @required this.color,
    @required this.rect,
  })  : assert(lineWidth != null),
        assert(color != null);

  double lineWidth;
  Color color;
  double startAngle;
  double sweepAngle;
  Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final useCenter = false;

    final linePaint = Paint()
      // ..blendMode = 
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      


  
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, linePaint);
  
    
  }
  @override
  bool shouldRepaint(_SwirlPainter oldDelegate) {
    return oldDelegate.lineWidth != lineWidth ||
        oldDelegate.color != color;
  }
}