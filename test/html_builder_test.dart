import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:model_viewer_plus/src/html_builder.dart' show HTMLBuilder;

void main() {
  group('HTMLBuilder', () {
    test('supports the src and backgroundColor attributes', () {
      final String html = HTMLBuilder.build(
        src: 'src.glb',
        htmlTemplate: '<!-- body -->',
        backgroundColor: const Color(0xFFABCDEF),
      );
      expect(
        html,
        '<model-viewer src="src.glb" style="background-color: rgba(171, 205, 239, 255); ">\n</model-viewer>\n',
      );
    });
  });
}
