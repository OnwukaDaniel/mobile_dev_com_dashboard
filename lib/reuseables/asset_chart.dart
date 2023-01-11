import 'dart:math';

import 'package:flutter/material.dart';

class AssetChat extends StatelessWidget {
  AssetChat(
      {Key? key,
      required this.legendText,
      required this.countText,
      required this.iconPath})
      : super(key: key);
  String legendText = "";
  String countText = "";
  String iconPath = "";

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
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 10,
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Text(legendText),
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
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    countText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      letterSpacing: -2.5,
                    ),
                  ),
                ),
              ),
              Image.asset(
                width: cw,
                height: ch,
                fit: BoxFit.fill,
                "assets/icons/wave_graph.png",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
