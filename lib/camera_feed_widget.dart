import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'vision_service.dart';

class CameraFeedWidget extends StatefulWidget {
  const CameraFeedWidget({Key? key}) : super(key: key);
  @override
  State<CameraFeedWidget> createState() => _CameraFeedWidgetState();
}

class _CameraFeedWidgetState extends State<CameraFeedWidget> {
  late html.VideoElement _videoElement;
  late html.CanvasElement _canvasElement;
  Timer? _frameTimer;
  List<dynamic> _detectedObjects = [];

  @override
  void initState() {
    super.initState();
    _initWebcam();
  }

  void _initWebcam() {
    // 1. Grab HTML elements
    _videoElement = html.document.getElementById('webcam') as html.VideoElement;
    _canvasElement = html.document.getElementById('snapshotCanvas') as html.CanvasElement;

    // 2. Request webcam stream :contentReference[oaicite:7]{index=7}
    html.window.navigator.mediaDevices!
        .getUserMedia({'video': true})
        .then((stream) {
      _videoElement.srcObject = stream;
      _videoElement.play();

      // 3. Start periodic detection every 500ms :contentReference[oaicite:8]{index=8}
      _frameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
        final base64 = _captureFrameAsBase64();
        final annotations = await detectObjects(base64);
        setState(() { _detectedObjects = annotations; });
      });
    }).catchError((e) {
      print('Webcam error: $e');
    });
  }

  String _captureFrameAsBase64() {
    final ctx = _canvasElement.context2D;
    ctx.drawImage(_videoElement, 0, 0);
    final dataUrl = _canvasElement.toDataUrl('image/jpeg');
    return dataUrl.split(',').last; // jsonEncode-ready JPEG :contentReference[oaicite:9]{index=9}
  }

  @override
  void dispose() {
    _frameTimer?.cancel(); // stop the timer :contentReference[oaicite:10]{index=10}
    final stream = _videoElement.srcObject as html.MediaStream;
    stream.getTracks().forEach((t) => t.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 640,
        height: 480,
        child: Stack(
          children: [
            // 1️⃣ Embed the live <video>
            HtmlElementView(viewType: 'webcamVideo'),

            // 2️⃣ Overlay bounding boxes
            CustomPaint(
              painter: _ObjectPainter(_detectedObjects),
              child: Container(), // fills the area :contentReference[oaicite:11]{index=11}
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectPainter extends CustomPainter {
  final List<dynamic> objects;
  _ObjectPainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var obj in objects) {
      final verts = (obj['boundingPoly']['normalizedVertices'] as List)
          .map((v) => Offset(v['x'] * size.width, v['y'] * size.height))
          .toList();
      final rect = Rect.fromLTRB(
        verts[0].dx, verts[0].dy, verts[2].dx, verts[2].dy,
      );
      canvas.drawRect(rect, paint); // draw box
      final label = obj['name'] as String;
      final tp = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, rect.topLeft);     // draw label :contentReference[oaicite:12]{index=12}
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
