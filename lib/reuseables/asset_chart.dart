import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_dev_com_dashboard/reuseables/resuable_text.dart';

class AssetChat extends StatelessWidget {
  final CustomText legendText;
  final CustomText countText;
  final String iconPath;
  final String wavePath;

  const AssetChat(
      {Key? key,
      required this.legendText,
      required this.countText,
      required this.wavePath,
      required this.iconPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();

    int w = 360;
    int h = 150;

    double aspectRatio = w / h;
    double rootAspectRatio = sqrt(aspectRatio);

    double cw = width * rootAspectRatio;
    double ch = cw / aspectRatio;
    return SizedBox(
      width: cw,
      height: ch,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Material(
          elevation: 10,
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(18.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: legendText,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Image.asset(
                      width: 25,
                      height: 20,
                      fit: BoxFit.fill,
                      iconPath,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child:
                    Align(alignment: Alignment.bottomCenter, child: countText),
              ),
              Image.asset(width: cw, height: ch, fit: BoxFit.fill, wavePath),
            ],
          ),
        ),
      ),
    );
  }
}
