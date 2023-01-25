import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBarChart extends StatefulWidget {
  final FlTitlesData titlesData;
  final FlGridData gridData;
  final FlBorderData borderData;
  final BarChartAlignment alignment;
  final double groupsSpace;
  final double smallWidth;
  final double largeWidth;
  final Map<String, int> map;
  final double typeMax;

  const CustomBarChart({
    Key? key,
    required this.smallWidth,
    required this.map,
    required this.largeWidth,
    required this.typeMax,
    required this.titlesData,
    required this.gridData,
    required this.borderData,
    this.alignment = BarChartAlignment.center,
    this.groupsSpace = 10.0,
  }) : super(key: key);

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  final Color dark = const Color(0xff602bfa);
  final Color normal = const Color(0xff64caad);
  final Color light = const Color(0xfff2f2ff);

  int touchedIndex = -1;
  double typeMax = 1;
  List<BarChartGroupData> barGroup = [];
  List<String> legend = [];

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    double barWidth = 18;
    double barHeight = 0;
    legend.clear();
    barGroup.clear();

    typeMax = widget.map.values.toList().reduce(max).toDouble();

    var count = 0;
    for (String x in widget.map.keys) {
      if (count == touchedIndex) {
        barWidth = widget.largeWidth;
      } else {
        barWidth = widget.smallWidth;
      }
      barHeight= widget.map[x]!.toDouble();
      BarChartRodData rod = BarChartRodData(
        width: barWidth,
        toY: typeMax + 50,
        rodStackItems: [
          BarChartRodStackItem(0, widget.map[x]!.toDouble(), dark),
          BarChartRodStackItem(barHeight, typeMax + 50, light),
        ],
        borderRadius: BorderRadius.zero,
      );
      barGroup.add(
        BarChartGroupData(x: legend.length, barsSpace: 4, barRods: [rod]),
      );
      legend.add(x);
      count++;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: SizedBox(
        width: width.toDouble(),
        height: 280,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: BarChart(
            BarChartData(
              alignment: widget.alignment,
              groupsSpace: widget.groupsSpace,
              titlesData: widget.titlesData,
              barGroups: barGroup,
              gridData: widget.gridData,
              borderData: widget.borderData,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    tooltipBgColor: Colors.white,
                    getTooltipItem: (groupData, int1, rodData, int2){
                      return BarTooltipItem(
                          rodData.rodStackItems.first.toY.toString(),
                          const TextStyle()
                      );
                    }
                ),
                handleBuiltInTouches: true,
                allowTouchBarBackDraw: true,
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    setState(() {
                      touchedIndex = -1;
                    });
                    return;
                  }
                  setState(() {
                    touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
