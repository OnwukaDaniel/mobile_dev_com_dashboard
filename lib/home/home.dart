import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/DataModel.dart';
import '../reuseables/asset_chart.dart';
import '../reuseables/resuable_text.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DataModel> _data = [];
  int selectedState = 0;
  final Color dark = const Color(0xff602bfa);
  final Color normal = const Color(0xff64caad);
  final Color light = const Color(0xfff2f2ff);
  int countX = 0;

  List<BarChartGroupData> barLga = [];
  List<String> barLgaLegend = [];

  Future<dynamic> readJson() async {
    final String response = await rootBundle.loadString("assets/data.json");
    List<dynamic> list = json.decode(response);
    _data =
        list.map((e) => DataModel.fromJson(e as Map<String, dynamic>)).toList();
    _data.sort((a, b) => b.lga!.compareTo(a.lga!));
    int count = 0;
    double countRodValue = 0;
    String currentLga = "";
    for (DataModel i in _data) {
      if (i.lga == currentLga || count == 0) {
        countRodValue++;
      } else {
        BarChartRodData rod = BarChartRodData(
          toY: 10000,
          rodStackItems: [
            BarChartRodStackItem(0, countRodValue, dark),
            BarChartRodStackItem(countRodValue, 10000, light),
          ],
          borderRadius: BorderRadius.zero,
        );
        barLga.add(
          BarChartGroupData(x: barLga.length, barsSpace: 4, barRods: [rod]),
        );
        barLgaLegend.add(currentLga);
        countRodValue++;
      }
      selectedState++;
      count++;
      currentLga = i.lga!;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();

    int w = 360;
    int h = 150;

    double aspectRatio = w / h;
    double rootAspectRatio = sqrt(aspectRatio);

    double cw = width * rootAspectRatio;
    double ch = cw / aspectRatio;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          AssetChat(
            legendText: const CustomText(
              text: "TOTAL NUMBER OF WIDOWS REGISTERED",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            countText: CustomText(
              text: "${_data.length}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30,
                letterSpacing: -1.0,
              ),
              padding: EdgeInsets.only(bottom: ch / 4),
            ),
            iconPath: "assets/icons/people_icons.png",
          ),
          AssetChat(
            legendText: const CustomText(
              text: "SELECT LOCAL GOVERNMENT",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            countText: CustomText(
              text: "$selectedState",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30,
                letterSpacing: -1.0,
              ),
              padding: EdgeInsets.only(bottom: ch / 4),
            ),
            iconPath: "assets/icons/healthy_community.png",
          ),
          Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: "WIDOWS REGISTERED BY LOCAL GOVERNMENT",
                  padding: EdgeInsets.only(top: 34, right: 16, left: 16),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: width.toDouble(),
                  height: 350,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.center,
                          barTouchData: BarTouchData(
                            enabled: false,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10000 / 17,
                                reservedSize: 85,
                                getTitlesWidget: bottomTitles,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 1500,
                                getTitlesWidget: leftTitles,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: false,
                            checkToShowHorizontalLine: (value) =>
                                value % 10 == 0,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: const Color(0xffe7e8ec),
                              strokeWidth: 1,
                            ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          groupsSpace: 8,
                          barGroups: barLga,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.black, fontSize: 10);
    print("Value ********************************* ${meta.formattedValue}");
    return SideTitleWidget(
      space: 36.0,
      axisSide: meta.axisSide,
      angle: 98.96,
      child: Text("${barLgaLegend[value.toInt()]} - ", style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    countX++;
    const style = TextStyle(
      color: Color(
        0xff939393,
      ),
      fontSize: 10,
    );
    return SideTitleWidget(
      angle: 98.96,
      space: 15,
      axisSide: meta.axisSide,
      child: Column(
        children: [
          const RotatedBox(
            quarterTurns: 1,
            child: Text("-"),
          ),
          Text(
            meta.formattedValue,
            style: style,
          ),
        ],
      ),
    );
  }
}
