import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'html_builder.dart';
import 'model_viewer_plus.dart';
import 'shim/dart_ui_web_fake.dart'
    if (dart.library.ui_web) 'dart:ui_web'
    as ui_web;
import 'shim/dart_web_fake.dart'
    if (dart.library.js_interop) 'package:web/web.dart'
    as web;
import 'shim/dart_web_fake.dart' if (dart.library.js_interop) 'dart:js_interop';

class ModelViewerState extends State<ModelViewer> {
  bool _isLoading = true;
  final String _uniqueViewType = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    unawaited(generateModelViewerHtml());
  }

  /// To generate the HTML code for using the model viewer.
  Future<void> generateModelViewerHtml() async {
    final String htmlTemplate = await rootBundle.loadString(
      'packages/model_viewer_plus/assets/template.html',
    );

    final String html = _buildHTML(htmlTemplate);

    ui_web.platformViewRegistry.registerViewFactory(
      'model-viewer-html-$_uniqueViewType',
      (viewId) {
        final element = web.HTMLHtmlElement()
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%'
          ..innerHTML = html.toJS;
        return element;
      },
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(final BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading Model Viewer...',
        ),
      );
    } else {
      return HtmlElementView(viewType: 'model-viewer-html-$_uniqueViewType');
    }
  }

  String _buildHTML(final String htmlTemplate) {
    if (widget.src.startsWith('file://')) {
      // Local file URL can't be used in Flutter web.
      debugPrint("file:// URL scheme can't be used in Flutter web.");
      throw ArgumentError("file:// URL scheme can't be used in Flutter web.");
    }

    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate.replaceFirst(
        '<script type="module" src="model-viewer.min.js" defer></script>',
        '',
      ),
      // Attributes
      src: widget.src,
      alt: widget.alt,
      poster: widget.poster,
      loading: widget.loading,
      reveal: widget.reveal,
      withCredentials: widget.withCredentials,
      // AR Attributes
      ar: widget.ar,
      arModes: widget.arModes,
      // arScale: widget.arScale,
      // arPlacement: widget.arPlacement,
      iosSrc: widget.iosSrc,
      xrEnvironment: widget.xrEnvironment,
      // Staing & Cameras Attributes
      cameraControls: widget.cameraControls,
      disablePan: widget.disablePan,
      disableTap: widget.disableTap,
      touchAction: widget.touchAction,
      disableZoom: widget.disableZoom,
      orbitSensitivity: widget.orbitSensitivity,
      autoRotate: widget.autoRotate,
      autoRotateDelay: widget.autoRotateDelay,
      rotationPerSecond: widget.rotationPerSecond,
      interactionPrompt: widget.interactionPrompt,
      interactionPromptStyle: widget.interactionPromptStyle,
      interactionPromptThreshold: widget.interactionPromptThreshold,
      cameraOrbit: widget.cameraOrbit,
      cameraTarget: widget.cameraTarget,
      fieldOfView: widget.fieldOfView,
      maxCameraOrbit: widget.maxCameraOrbit,
      minCameraOrbit: widget.minCameraOrbit,
      maxFieldOfView: widget.maxFieldOfView,
      minFieldOfView: widget.minFieldOfView,
      interpolationDecay: widget.interpolationDecay,
      // Lighting & Env Attributes
      skyboxImage: widget.skyboxImage,
      environmentImage: widget.environmentImage,
      exposure: widget.exposure,
      shadowIntensity: widget.shadowIntensity,
      shadowSoftness: widget.shadowSoftness,
      // Animation Attributes
      animationName: widget.animationName,
      animationCrossfadeDuration: widget.animationCrossfadeDuration,
      autoPlay: widget.autoPlay,
      // Materials & Scene Attributes
      variantName: widget.variantName,
      orientation: widget.orientation,
      scale: widget.scale,

      // CSS Styles
      backgroundColor: widget.backgroundColor,

      // Annotations CSS
      minHotspotOpacity: widget.minHotspotOpacity,
      maxHotspotOpacity: widget.maxHotspotOpacity,

      // Others
      innerModelViewerHtml: widget.innerModelViewerHtml,
      relatedCss: widget.relatedCss,
      relatedJs: widget.relatedJs,
      id: widget.id,
      debugLogging: widget.debugLogging,
    );
  }
}
