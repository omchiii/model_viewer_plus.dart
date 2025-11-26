## 1.10.0

### Changed
- Update dependencies
- Remove Flutter deprecated methods
- Update Dart to ^3.10.0
- Upgrade `<model-viewer>` to 4.1.0

## 1.9.3

### Changed
- Update dependencies
- Update model-viewer to 4.0.0


## 1.9.2

### Changed
-Add explicit data URI compatibility and fix said compatibility for mobile


## 1.9.1

### Changed
- Update dependencies(remove `webview_flutter_android` and `webview_flutter_wkwebview`)

## 1.9.0

### Changed
- Replace `dart:html` to `package:web` for wasm support

## 1.8.0

### Changed
- Upgrade `<model-viewer>` to 3.5.0
- Updates examples
- Updates minimum supported SDK version to Flutter 3.22/Dart 3.4

## 1.7.1

### Changed
- Update dependencies

## 1.7.0

### Changed
- Fake for web implementation for Flutter 3.13
### Fixed
- Links for images in README

## 1.6.1

### Changed
- Specify platforms
### Fixed
- Error with replaceAll on empty string

## 1.6.0

### Changed
- Align Dart 3 and Flutter 3.10.0 for `platformViewRegistry`
- Update example
- Update license
- Add topics

## 1.5.1

### Changed
- Upgrade dependencies(webview_flutter, android_intent_plus) and align min Flutter SDK to 3.3.0
- Upgrade `<model-viewer>` to v3.2.0
### Fixed
- Fix analysis issues

## 1.5.0

### Removed
- **BREAKING** [#49 Add button with hotspot attributes to allowed elements](https://github.com/omchiii/model_viewer_plus.dart/pull/49), because you can customize them now
### Added
- Allowing customize NodeValidator on Web platform by using `overwriteNodeValidatorBuilder`
- New example, `example\lib\materials_and_scene\change_color.dart`
### Fixed
- Lints
- Upgrade Dart SDK in the example folder to 2.12.0 to "Running with sound null safety"

## 1.4.0

### Changed
- Upgrade `assets/model-viewer.min.js` to v2.1.1 and implements all attributes
- Examples support Android API 33
- Dependencies upgrade

## 1.3.4

### Changed
- [#49 Add button with hotspot attributes to allowed elements](https://github.com/omchiii/model_viewer_plus.dart/pull/49)

## 1.3.3

### Changed
- Fix: `Removing disallowed element <SCRIPT> from [object DocumentFragment]`, in `lib\src\model_viewer_plus_web.dart`
- Update `example\lib\loading\display_poster.dart`
- Update `README.md`, due to `<model-viewer>` upgrades to 2.0.0 and we have not keep up with it's latest version. So, Flutter Web users should replace `src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"` with `src="./assets/packages/model_viewer_plus/assets/model-viewer.min.js"` to use the js file in our package

### Added
- Add a new example: `example\lib\loading\render_scale.dart`

## 1.3.2

### Changed
- Update `html_builder.dart`:
- Fix `min-camera-orbit`, `max-field-of-view`, `min-field-of-view`

## 1.3.1

### Changed
- Upgrade dependencies

## 1.3.0

### Changed
- `lib\html_builder.dart`: fix typos and uncomment `debugPrint` for more debug info
- `lib\model_viewer_plus_mobile.dart`: uncomment `debugPrint` for more debug info
- `lib\model_viewer_plus_web.dart`: unique viewType to fix [#29](https://github.com/omchiii/model_viewer_plus.dart/issues/29)
- Update `assets/model-viewer.min.js` to v1.20.0

## 1.2.0

### Added
- More examples in `example/lib`
### Changed
- `lib\html_builder.dart`, `lib\model_viewer_plus_mobile.dart`, `lib\model_viewer_plus_web.dart`, `lib\model_viewer_plus.dart`: implement all the attributes of `<model-viewer>` v1.11.1
- ModelViewer.arSacle from `final String? arScale` to `final ArScale? arScale`, which may be a breaking change
- Update `assets/model-viewer.min.js` to v1.11.1
- Update example dir's gradle version to 7.0.

## 1.1.5

### Changed
- `lib/src/model_viewer_plus_mobile.dart`
  - Fix [#11](https://github.com/omchiii/model_viewer_plus.dart/issues/11), add `gestureRecognizers`
  - A less elegant solution of [#8](https://github.com/omchiii/model_viewer_plus.dart/issues/8), open usdz file by [url_launcher](https://pub.dev/packages/url_launcher) in SFSafariViewController

## 1.1.4

### Changed
- `/lib/src/model_viewer_plus_mobile.dart`, update according to the [newest document](https://developers.google.com/ar/develop/scene-viewer#3d-or-ar). Fix [#9](https://github.com/omchiii/model_viewer_plus.dart/issues/9).
  - Insted of `com.google.ar.core`, now we use `com.google.android.googlequicksearchbox`. This should support the widest possible range of devices.
  - Mode defaults to `ar_preferred`. Scene Viewer launches in AR native mode as the entry mode. If Google Play Services for AR isn't present, Scene Viewer gracefully falls back to 3D mode as the entry mode.
- Add `arModes` to example, closer to [modelviewer.dev](https://modelviewer.dev)'s offical example.
- Update `example\android\app\build.gradle` `compileSdkVersion` to 31
- Update `android_intent_plus` to `3.1.1`
- Update `webview_flutter` to `3.0.1`
### Removed
- `/lib/src/http_proxy.dart`: empty file

## 1.1.3

### Changed
- `ModelViewer`'s default `backgroundColor` from `Colors.white` to `Colors.transparent`, due to [#12](https://github.com/omchiii/model_viewer_plus.dart/issues/12)
- `proxy`'s null check fix and `setState() {}` for it, due to [#10](https://github.com/omchiii/model_viewer_plus.dart/issues/10)

## 1.1.2

### Added
- `/lib/src/shim/` with `dart_html_fake.dart` and `dart_ui_fake.dart`. Fixing `ERROR: The name platformViewRegistry' is being referenced through the prefix 'ui', but it isn't defined in any of the libraries imported using that prefix.` and `INFO: Avoid using web-only libraries outside Flutter web plugin` to improve the [score on pub.dev](https://pub.dev/packages/model_viewer_plus/score).
### Changed
- example's `/etc/assets` -> `/assets`

## 1.1.1

### Added
- `/assets/model-viewer.min.js` (v1.10.1, which is actually identical to v1.10.0)
### Changed
- Updated the Screenshot
- README Update

## 1.1.0

### Added
- Web Support

## 0.8.1

### Fixed
- Set `android:usesCleartextTraffic="true"` for Android 9+ in the example app to fix `net::ERR_CLEARTEXT_NOT_PERMITTED`. ([#7])
- Improved the reliability of the `localhost` HTTP proxy
### Added
- Documented `android:usesCleartextTraffic="true"` in the README. ([#7])
### Changed
- Defaulted the background color to white when not specified. ([#7])

## 0.8.0

### Changed
- Required [flutter_android](https://pub.dev/packages/flutter_android) 0.8.0
### Added
- Support for loading bundled asset files
- Support for loading local files from `file://` URLs
- Implemented a `localhost` HTTP server and proxy

## 0.7.0

### Changed
- Required [flutter_android](https://pub.dev/packages/flutter_android) for launching the Scene Viewer. ([#4])
- Upgraded to model-viewer.js [1.1.0](https://github.com/google/model-viewer/releases/tag/v1.1.0)
- Launching the Scene Viewer on Android now works. (Fixes [#4])
- Improved error logging in case of loading errors

## 0.6.0

- Escaped HTML attributes on the `<model-viewer>` web component
