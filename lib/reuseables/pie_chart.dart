import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_dev_com_dashboard/reuseables/pie_indicators.dart';
import 'package:mobile_dev_com_dashboard/reuseables/resuable_text.dart';

class CustomPieGraph extends StatefulWidget {
  final List<PieIndicators> indicatorList;
  final CustomText legendText;
  final CustomText centerText;
  final double centerSpaceRadius;
  final List<PieChartSectionData> employmentStaDataList;
  final double smallRadius;
  final double largeRadius;
  final Map<String, int> map;
  final List<Color> sectionColor;
  final List<PieChartSectionData> chartList;

  const CustomPieGraph({
    Key? key,
    required this.indicatorList,
    required this.smallRadius,
    required this.largeRadius,
    required this.chartList,
    required this.employmentStaDataList,
    required this.sectionColor,
    this.legendText = const CustomText(
      text: '',
    ),
    this.centerText = const CustomText(
      text: '',
    ),
    this.centerSpaceRadius = 0.0,
    this.map = const {},
  }) : super(key: key);

  @override
  State<CustomPieGraph> createState() => _CustomPieGraphState();
}

class _CustomPieGraphState extends State<CustomPieGraph> {
  int touchedIndex = -1;
  double radius = 0;
  bool isTouched = false;

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();

    widget.chartList.clear();
    radius = width / 8;
    var countNgo = 0;
    for (String x in widget.map.keys) {
      var sectionValue = (widget.map[x]!.toDouble() / widget.map.length) * 360;
      if (countNgo == touchedIndex) {
        radius = widget.largeRadius;
      } else {
        radius = widget.smallRadius;
      }
      widget.chartList.add(PieChartSectionData(
        color: widget.sectionColor[countNgo],
        showTitle: false,
        value: sectionValue,
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
      ));
      countNgo++;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.legendText,
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
                        Positioned(child: widget.centerText),
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            centerSpaceRadius: widget.centerSpaceRadius,
                            startDegreeOffset: 180,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 1,
                            sections: widget.employmentStaDataList,
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
                    children: widget.indicatorList,
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
