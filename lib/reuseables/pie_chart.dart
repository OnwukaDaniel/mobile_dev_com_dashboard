import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_dev_com_dashboard/reuseables/pie_indicators.dart';
import 'package:mobile_dev_com_dashboard/reuseables/resuable_text.dart';

class CustomPieGraph extends StatelessWidget {
  final List<PieIndicators> indicatorList;
  final CustomText legendText;
  final CustomText centerText;
  final double centerSpaceRadius;
  final List<PieChartSectionData> employmentStaDataList;

  const CustomPieGraph({
    Key? key,
    required this.indicatorList,
    this.legendText = const CustomText(text: '',),
    this.centerText = const CustomText(text: '',),
    this.centerSpaceRadius = 0.0,
    required this.employmentStaDataList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            legendText,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    width: width.toDouble(),
                    height: 350,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(child: centerText),
                        PieChart(
                          PieChartData(
                            centerSpaceRadius: centerSpaceRadius,
                            startDegreeOffset: 180,
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 1,
                            sections: employmentStaDataList,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: indicatorList,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
