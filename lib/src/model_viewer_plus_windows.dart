import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io'
    show File, HttpResponse, HttpServer, HttpStatus, InternetAddress;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart' as p;

import 'html_builder.dart';
import 'model_viewer_plus.dart';
import 'model_viewer_plus_io.dart';

class ModelViewerWindowsState extends State<WindowsModelViewer> {
  HttpServer? _proxy;
  late String _proxyURL;
  bool _isInitialized = false;

  ModelViewer get modelWidget => widget.widget;

  @override
  void initState() {
    super.initState();
    unawaited(_initProxy().then((_) => setState(() => _isInitialized = true)));
  }

  @override
  void dispose() {
    if (_proxy != null) {
      unawaited(_proxy!.close(force: true));
      _proxy = null;
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (_proxy == null || !_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading Model Viewer',
        ),
      );
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_proxyURL)),
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        disableContextMenu: true,
        supportZoom: false,
        javaScriptEnabled: true,
      ),
      onWebViewCreated: (controller) {
        // Add JavaScript channels if provided
        if (modelWidget.javascriptChannels != null) {
          for (final channel in modelWidget.javascriptChannels!) {
            controller.addJavaScriptHandler(
              handlerName: channel.name,
              callback: (args) {
                final message = args.isNotEmpty ? args[0].toString() : '';
                channel.onMessageReceived(message);
              },
            );
          }
        }

        debugPrint('ModelViewer initializing... <$_proxyURL>');
      },
      onLoadStop: (controller, url) {
        debugPrint('ModelViewer loaded: $url');
      },
      onConsoleMessage: (controller, consoleMessage) {
        if (modelWidget.debugLogging) {
          debugPrint('Console: ${consoleMessage.message}');
        }
      },
    );
  }

  String _buildHTML(String htmlTemplate) {
    String src;
    if (modelWidget.src.startsWith('data:')) {
      src = modelWidget.src;
    } else {
      src = '/model';
    }
    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate,
      src: src,
      alt: modelWidget.alt,
      poster: modelWidget.poster,
      loading: modelWidget.loading,
      reveal: modelWidget.reveal,
      withCredentials: modelWidget.withCredentials,
      ar: modelWidget.ar,
      arModes: modelWidget.arModes,
      arScale: modelWidget.arScale,
      arPlacement: modelWidget.arPlacement,
      iosSrc: modelWidget.iosSrc,
      xrEnvironment: modelWidget.xrEnvironment,
      cameraControls: modelWidget.cameraControls,
      disablePan: modelWidget.disablePan,
      disableTap: modelWidget.disableTap,
      touchAction: modelWidget.touchAction,
      disableZoom: modelWidget.disableZoom,
      orbitSensitivity: modelWidget.orbitSensitivity,
      autoRotate: modelWidget.autoRotate,
      autoRotateDelay: modelWidget.autoRotateDelay,
      rotationPerSecond: modelWidget.rotationPerSecond,
      interactionPrompt: modelWidget.interactionPrompt,
      interactionPromptStyle: modelWidget.interactionPromptStyle,
      interactionPromptThreshold: modelWidget.interactionPromptThreshold,
      cameraOrbit: modelWidget.cameraOrbit,
      cameraTarget: modelWidget.cameraTarget,
      fieldOfView: modelWidget.fieldOfView,
      maxCameraOrbit: modelWidget.maxCameraOrbit,
      minCameraOrbit: modelWidget.minCameraOrbit,
      maxFieldOfView: modelWidget.maxFieldOfView,
      minFieldOfView: modelWidget.minFieldOfView,
      interpolationDecay: modelWidget.interpolationDecay,
      skyboxImage: modelWidget.skyboxImage,
      environmentImage: modelWidget.environmentImage,
      exposure: modelWidget.exposure,
      shadowIntensity: modelWidget.shadowIntensity,
      shadowSoftness: modelWidget.shadowSoftness,
      animationName: modelWidget.animationName,
      animationCrossfadeDuration: modelWidget.animationCrossfadeDuration,
      autoPlay: modelWidget.autoPlay,
      variantName: modelWidget.variantName,
      orientation: modelWidget.orientation,
      scale: modelWidget.scale,
      backgroundColor: modelWidget.backgroundColor,
      minHotspotOpacity: modelWidget.minHotspotOpacity,
      maxHotspotOpacity: modelWidget.maxHotspotOpacity,
      innerModelViewerHtml: modelWidget.innerModelViewerHtml,
      relatedCss: modelWidget.relatedCss,
      relatedJs: modelWidget.relatedJs,
      id: modelWidget.id,
      debugLogging: modelWidget.debugLogging,
    );
  }

  Future<void> _initProxy() async {
    _proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    final String host = _proxy!.address.address;
    final int port = _proxy!.port;
    _proxyURL = 'http://$host:$port/';

    _proxy!.listen((request) async {
      final Uri url = Uri.parse(modelWidget.src);
      final HttpResponse response = request.response;

      switch (request.uri.path) {
        case '/':
        case '/index.html':
          final String htmlTemplate = await rootBundle.loadString(
            'packages/model_viewer_plus/assets/template.html',
          );
          final Uint8List html = utf8.encode(_buildHTML(htmlTemplate));
          response
            ..statusCode = HttpStatus.ok
            ..headers.add('Content-Type', 'text/html;charset=UTF-8')
            ..headers.add('Content-Length', html.length.toString())
            ..add(html);
          await response.close();
        case '/model-viewer.min.js':
          final Uint8List code = await _readAsset(
            'packages/model_viewer_plus/assets/model-viewer.min.js',
          );
          response
            ..statusCode = HttpStatus.ok
            ..headers.add(
              'Content-Type',
              'application/javascript;charset=UTF-8',
            )
            ..headers.add('Content-Length', code.lengthInBytes.toString())
            ..add(code);
          await response.close();
        case '/model':
          if (url.isAbsolute && !url.isScheme('file')) {
            await response.redirect(url);
          } else {
            final Uint8List data = await (url.isScheme('file')
                ? _readFile(url.path)
                : _readAsset(url.path));
            response
              ..statusCode = HttpStatus.ok
              ..headers.add('Content-Type', 'application/octet-stream')
              ..headers.add('Content-Length', data.lengthInBytes.toString())
              ..headers.add('Access-Control-Allow-Origin', '*')
              ..add(data);
            await response.close();
          }
        case '/favicon.ico':
          final Uint8List text = utf8.encode(
            "Resource '${request.uri}' not found",
          );
          response
            ..statusCode = HttpStatus.notFound
            ..headers.add('Content-Type', 'text/plain;charset=UTF-8')
            ..headers.add('Content-Length', text.length.toString())
            ..add(text);
          await response.close();
        default:
          if (request.uri.isAbsolute) {
            debugPrint('Redirect: ${request.uri}');
            await response.redirect(request.uri);
          } else if (request.uri.hasAbsolutePath) {
            final List<String> pathSegments = [...url.pathSegments]
              ..removeLast();
            final String tryDestination = p.joinAll([
              url.origin,
              ...pathSegments,
              request.uri.path.replaceFirst('/', ''),
            ]);
            debugPrint('Try: $tryDestination');
            await response.redirect(Uri.parse(tryDestination));
          } else {
            debugPrint('404 with ${request.uri}');
            final Uint8List text = utf8.encode(
              "Resource '${request.uri}' not found",
            );
            response
              ..statusCode = HttpStatus.notFound
              ..headers.add('Content-Type', 'text/plain;charset=UTF-8')
              ..headers.add('Content-Length', text.length.toString())
              ..add(text);
            await response.close();
          }
      }
    });
  }

  Future<Uint8List> _readAsset(final String key) async {
    final ByteData data = await rootBundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> _readFile(final String path) async {
    return File(path).readAsBytes();
  }
}
