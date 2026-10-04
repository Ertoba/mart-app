import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MILI product video Vimeo reconciliation', () {
    const List<String> detectionFiles = <String>[
      'lib/common/widgets/image_viewer_screen.dart',
      'lib/features/item/widgets/details_web_view_widget.dart',
      'lib/features/item/widgets/item_image_view_widget.dart',
      'lib/features/item/widgets/item_media_carousel_new_widget.dart',
      'lib/features/item/widgets/item_media_dialog.dart',
    ];

    test('all current product media surfaces recognise Vimeo', () {
      for (final String path in detectionFiles) {
        final String source = File(path).readAsStringSync();

        expect(
          source,
          contains('vimeo.com'),
          reason: '$path must recognise vimeo.com',
        );

        expect(
          source,
          contains('player.vimeo.com'),
          reason: '$path must recognise player.vimeo.com',
        );
      }
    });

    test('main product media view has Vimeo playback', () {
      final String source = File(
        'lib/features/item/widgets/item_image_view_widget.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          "import 'package:flutter_inappwebview/flutter_inappwebview.dart';",
        ),
      );

      expect(
        source,
        contains('_isVimeoVideo'),
      );

      expect(
        source,
        contains('InAppWebView('),
      );

      expect(
        source,
        contains('WebUri(vimeoUrl)'),
      );
    });

    test('bottom sheet keeps MILI Vimeo-specific player path', () {
      final String source = File(
        'lib/common/widgets/item_new_bottom_sheet.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('isVimeo'),
      );

      expect(
        source,
        contains('header-vimeo-'),
      );
    });

    test('V4.2 carousel preserves YouTube and direct video support', () {
      final String source = File(
        'lib/features/item/widgets/item_media_carousel_new_widget.dart',
      ).readAsStringSync();

      expect(source, contains('youtube.com'));
      expect(source, contains('youtu.be'));
      expect(source, contains('.mp4'));
      expect(source, contains('.webm'));
      expect(source, contains('isVimeoUrl'));
    });

    test('product video model fields remain present', () {
      final String source = File(
        'lib/features/item/domain/models/item_model.dart',
      ).readAsStringSync();

      expect(source, contains('videoEmbedUrl'));
      expect(source, contains('videoLink'));
      expect(source, contains('videoFullUrl'));
      expect(source, contains('videoPreviewUrl'));
      expect(source, contains('videoThumbnailUrl'));
    });

    test('Vimeo state setup remains inside media player State', () {
      final String source = File(
        'lib/features/item/widgets/item_image_view_widget.dart',
      ).readAsStringSync();

      final int stateIndex = source.indexOf(
        'class _ItemMediaVideoViewState extends State<_ItemMediaVideoView>',
      );

      final int fieldIndex = source.indexOf(
        'bool _isVimeoVideo = false;',
      );

      final int setupIndex = source.indexOf(
        '_isVimeoVideo = true;',
      );

      final int youtubeInitIndex = source.indexOf(
        'final String? videoId = YoutubePlayer.convertUrlToId(url);',
      );

      expect(stateIndex, greaterThanOrEqualTo(0));
      expect(fieldIndex, greaterThan(stateIndex));
      expect(setupIndex, greaterThan(stateIndex));
      expect(youtubeInitIndex, greaterThan(setupIndex));
    });

  });
}
