import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:sixam_mart/util/images.dart';

void main() {
  test('uploaded Star dotLottie archive decodes with the app player', () async {
    final bytes = await File(Images.starLottie).readAsBytes();

    final composition = await LottieComposition.decodeZip(
      bytes,
      filePicker: (files) => files.firstWhere(
        (file) =>
            file.name.startsWith('animations/') &&
            file.name.endsWith('.json'),
      ),
    );

    expect(composition, isNotNull);
    expect(composition!.bounds.width, 400);
    expect(composition.bounds.height, 400);
    expect(composition.frameRate, 30);
  });
}
