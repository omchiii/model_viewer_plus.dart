import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io'
    show File, HttpResponse, HttpServer, HttpStatus, InternetAddress, Platform;

import 'package:android_intent_plus/android_intent.dart' as android_intent;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as android;
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'
    as ios;

import 'html_builder.dart';
import 'model_viewer_plus.dart';
import 'model_viewer_plus_io.dart';

class ModelViewerMobileState extends State<MobileModelViewer> {
  HttpServer? _proxy;
  WebViewController? _webViewController;
  late String _proxyURL;

  ModelViewer get modelWidget => widget.widget;

  @override
  void initState() {
    super.initState();
    unawaited(_initProxy().then((_) => _initController()));
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
    if (_proxy == null || _webViewController == null) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading Model Viewer',
        ),
      );
    }
    return WebViewWidget(
      controller: _webViewController!,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
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
      // AR Attributes
      ar: modelWidget.ar,
      arModes: modelWidget.arModes,
      arScale: modelWidget.arScale,
      arPlacement: modelWidget.arPlacement,
      iosSrc: modelWidget.iosSrc,
      xrEnvironment: modelWidget.xrEnvironment,
      // Cameras Attributes
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
      // Lighting & Env Attributes
      skyboxImage: modelWidget.skyboxImage,
      environmentImage: modelWidget.environmentImage,
      exposure: modelWidget.exposure,
      shadowIntensity: modelWidget.shadowIntensity,
      shadowSoftness: modelWidget.shadowSoftness,
      // Animation Attributes
      animationName: modelWidget.animationName,
      animationCrossfadeDuration: modelWidget.animationCrossfadeDuration,
      autoPlay: modelWidget.autoPlay,
      // Materials & Scene Attributes
      variantName: modelWidget.variantName,
      orientation: modelWidget.orientation,
      scale: modelWidget.scale,
      // CSS Styles
      backgroundColor: modelWidget.backgroundColor,
      // Annotations CSS
      minHotspotOpacity: modelWidget.minHotspotOpacity,
      maxHotspotOpacity: modelWidget.maxHotspotOpacity,
      // Others
      innerModelViewerHtml: modelWidget.innerModelViewerHtml,
      relatedCss: modelWidget.relatedCss,
      relatedJs: modelWidget.relatedJs,
      id: modelWidget.id,
      debugLogging: modelWidget.debugLogging,
    );
  }

  Future<void> _initController() async {
    late final PlatformWebViewControllerCreationParams params;
    if (Platform.isAndroid) {
      params = android.AndroidWebViewControllerCreationParams();
    } else if (Platform.isIOS) {
      params = ios.WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final webViewController = WebViewController.fromPlatformCreationParams(
      params,
    );
    await webViewController.setBackgroundColor(Colors.transparent);
    await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    await webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) async {
          debugPrint('ModelViewer wants to load: ${request.url}');
          if (Platform.isIOS && request.url == modelWidget.iosSrc) {
            await launchUrl(
              Uri.parse(request.url.trimLeft()),
              mode: LaunchMode.inAppWebView,
            );
            return NavigationDecision.prevent;
          }
          if (!Platform.isAndroid) {
            return NavigationDecision.navigate;
          }
          if (!request.url.startsWith('intent://')) {
            return NavigationDecision.navigate;
          }
          try {
            // Original, just keep as a backup
            // See: https://developers.google.com/ar/develop/java/scene-viewer
            // final intent = android_content.AndroidIntent(
            //   action: "android.intent.action.VIEW", // Intent.ACTION_VIEW
            //   data: "https://arvr.google.com/scene-viewer/1.0",
            //   arguments: <String, dynamic>{
            //     'file': widget.src,
            //     'mode': 'ar_preferred',
            //   },
            //   package: "com.google.ar.core",
            //   flags: <int>[
            //     Flag.FLAG_ACTIVITY_NEW_TASK
            //   ], // Intent.FLAG_ACTIVITY_NEW_TASK,
            // );

            final String fileURL;
            if ([
              'http',
              'https',
              'data',
            ].contains(Uri.parse(modelWidget.src).scheme)) {
              fileURL = modelWidget.src;
            } else {
              fileURL = p.joinAll([_proxyURL, 'model']);
            }
            final intent = android_intent.AndroidIntent(
              action: 'android.intent.action.VIEW',
              // Intent.ACTION_VIEW
              // See https://developers.google.com/ar/develop/scene-viewer#3d-or-ar
              // data should be something like "https://arvr.google.com/scene-viewer/1.0?file=https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Avocado/glTF/Avocado.gltf"
              data: Uri(
                scheme: 'https',
                host: 'arvr.google.com',
                path: '/scene-viewer/1.0',
                queryParameters: {'mode': 'ar_preferred', 'file': fileURL},
              ).toString(),
              // package changed to com.google.android.googlequicksearchbox
              // to support the widest possible range of devices
              package: 'com.google.android.googlequicksearchbox',
              arguments: <String, dynamic>{
                'browser_fallback_url':
                    'market://details?id=com.google.android.googlequicksearchbox',
              },
            );
            await intent.launch().onError((error, stackTrace) {
              debugPrint('ModelViewer Intent Error: $error');
            });
          } on Object catch (error) {
            debugPrint('ModelViewer failed to launch AR: $error');
          }
          return NavigationDecision.prevent;
        },
      ),
    );
    modelWidget.javascriptChannels?.forEach((element) {
      unawaited(
        webViewController.addJavaScriptChannel(
          element.name,
          onMessageReceived: element.onMessageReceived,
        ),
      );
    });

    debugPrint('ModelViewer initializing... <$_proxyURL>');
    modelWidget.onWebViewCreated?.call(webViewController);
    await webViewController.loadRequest(Uri.parse(_proxyURL));
    setState(() => _webViewController = webViewController);
  }

  Future<void> _initProxy() async {
    _proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    setState(() {
      final String host = _proxy!.address.address;
      final int port = _proxy!.port;
      _proxyURL = 'http://$host:$port/';
    });

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
            // Some gltf models need other resources from the origin
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
            break;
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
