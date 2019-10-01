import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

class Sign extends StatefulWidget {
  @override
  _SignState createState() => _SignState();
}




class _SignState extends State<Sign> {

  GlobalKey<SignatureState> signatureKey = GlobalKey();
  var signature;
  String _platformVersion = 'Unknown';


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }


  initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await SimplePermissions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
    print(_platformVersion);
  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Signature(key: signatureKey),
      persistentFooterButtons: <Widget>[
        FlatButton(
          child: Text('Clear'),
          onPressed: () {
            signatureKey.currentState.clearPoints();
          },
        ),
        FlatButton(
          child: Text('Save'),
          onPressed: () {
            // Future will resolve later
            // so setState @image here and access in #showImage
            // to avoid @null Checks
            setRenderedImage(context);
          },
        )
      ],
    );
  }

  setRenderedImage(BuildContext context) async {
    ui.Image renderedImage = await signatureKey.currentState.rendered;

    setState(() {
      signature = renderedImage;
    });

    showImage(context);
  }

  Future<Null> showImage(BuildContext context) async {
    var pngBytes = await signature.toByteData(format: ui.ImageByteFormat.png);
//    if(!(await checkPermission())) await requestPermission();

//    Directory directory = await getExternalStorageDirectory();
//    String path = directory.path;
//    print(path);
//
//    await Directory('$path/$directoryName').create(recursive: true);
//    File('$path/$directoryName/${formattedDate()}.png')
//        .writeAsBytesSync(pngBytes.buffer.asInt8List());

    return showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Please check your device\'s Signature folder',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.1
              ),
            ),
            content: Image.memory(Uint8List.view(pngBytes.buffer)),
          );
        }
    );
  }

//  String formattedDate() {
//    DateTime dateTime = DateTime.now();
//    String dateTimeString = 'Signature_' +
//        dateTime.year.toString() +
//        dateTime.month.toString() +
//        dateTime.day.toString() +
//        dateTime.hour.toString() +
//        ':' + dateTime.minute.toString() +
//        ':' + dateTime.second.toString() +
//        ':' + dateTime.millisecond.toString() +
//        ':' + dateTime.microsecond.toString();
//    return dateTimeString;
//  }

//  requestPermission() async {
//    bool result = (await SimplePermissions.requestPermission(_permission)) as bool;
//    return result;
//  }
//
//  checkPermission() async {
//    bool result = await SimplePermissions.checkPermission(_permission);
//    return result;
//  }
//
//  getPermissionStatus() async {
//    final result = await SimplePermissions.getPermissionStatus(_permission);
//    print("permission status is " + result.toString());
//  }

}



class Signature extends StatefulWidget {
  Signature({Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignatureState();
  }
}

class SignatureState extends State<Signature> {
  // [SignatureState] responsible for receives drag/touch events by draw/user
  // @_points stores the path drawn which is passed to
  // [SignaturePainter]#contructor to draw canvas
  List<Offset> _points = <Offset>[];

  Future<ui.Image> get rendered {
    // [CustomPainter] has its own @canvas to pass our
    // [ui.PictureRecorder] object must be passed to [Canvas]#contructor
    // to capture the Image. This way we can pass @recorder to [Canvas]#contructor
    // using @painter[SignaturePainter] we can call [SignaturePainter]#paint
    // with the our newly created @canvas
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    SignaturePainter painter = SignaturePainter(points: _points);
    var size = context.size;
    painter.paint(canvas, size);
    return recorder.endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox _object = context.findRenderObject();
              Offset _locationPoints = _object.localToGlobal(details.globalPosition);
              _points = new List.from(_points)..add(_locationPoints);
            });
          },
          onPanEnd: (DragEndDetails details) {
            setState(() {
              _points.add(null);
            });
          },
          child: CustomPaint(
            painter: SignaturePainter(points: _points),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  // clearPoints method used to reset the canvas
  // method can be called using
  //   key.currentState.clearPoints();
  void clearPoints() {
    setState(() {
      _points.clear();
    });
  }
}


class SignaturePainter extends CustomPainter {

  List<Offset> points = <Offset>[];

  SignaturePainter({this.points});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 5.0;

    for(int i=0; i < points.length - 1; i++) {
      if(points[i] != null && points[i+1] != null) {
        canvas.drawLine(points[i], points[i+1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }

}