// 1️⃣ Standard Flutter imports
import 'package:flutter/material.dart';
import 'camera_feed_widget.dart';

// 2️⃣ Web-specific imports for platform views
import 'dart:ui' as ui;              // for ui.platformViewRegistry
import 'dart:html' as html;          // for HtmlElement references

void main() {
  // 3️⃣ Register your `<video id="webcam">` element so Flutter can embed it.
  //    The viewType 'webcamVideo' must match the one you use in HtmlElementView.
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    'webcamVideo',
    (int viewId) => html.document
        .getElementById('webcam') as html.VideoElement,
  );                                   

  // 4️⃣ Then bootstrap your Flutter app as usual.
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: CameraFeedWidget(),
    ),
  ));
}
