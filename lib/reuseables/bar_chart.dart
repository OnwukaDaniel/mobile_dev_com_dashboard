import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBarChart extends StatelessWidget {
  final FlTitlesData titlesData;
  final List<BarChartGroupData> barGroups;
  final BarTouchData barTouchData;
  final FlGridData gridData;
  final FlBorderData borderData;
  final BarChartAlignment alignment;
  final double groupsSpace;

  const CustomBarChart({
    Key? key,
    required this.titlesData,
    required this.barGroups,
    required this.barTouchData,
    required this.gridData,
    required this.borderData,
    this.alignment = BarChartAlignment.center,
    this.groupsSpace = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();

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
              alignment: alignment,
              groupsSpace: groupsSpace,
              titlesData: titlesData,
              barGroups: barGroups,
              barTouchData: barTouchData,
              gridData: gridData,
              borderData: borderData,
            ),
          ),
        ),
      ),
    );
  }
}
