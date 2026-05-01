import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class ModuleIconImage extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final BoxFit fit;

  const ModuleIconImage({
    super.key,
    required this.image,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Theme.of(context).primaryColor,
        BlendMode.srcIn,
      ),
      child: CustomImage(image: image, height: height, width: width, fit: fit),
    );
  }
}
