import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';

import 'model_viewer_plus.dart';
import 'model_viewer_plus_mobile.dart';
import 'model_viewer_plus_windows.dart';

class ModelViewerState extends State<ModelViewer> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return WindowsModelViewer(widget: widget);
    } else {
      return MobileModelViewer(widget: widget);
    }
  }
}

class WindowsModelViewer extends StatefulWidget {
  const WindowsModelViewer({required this.widget, super.key});

  final ModelViewer widget;

  @override
  ModelViewerWindowsState createState() => ModelViewerWindowsState();
}

class MobileModelViewer extends StatefulWidget {
  const MobileModelViewer({required this.widget, super.key});

  final ModelViewer widget;

  @override
  ModelViewerMobileState createState() => ModelViewerMobileState();
}
