import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/DataModel.dart';
import '../reuseables/asset_chart.dart';
import '../reuseables/bar_chart.dart';
import '../reuseables/pie_chart.dart';
import '../reuseables/pie_indicators.dart';
import '../reuseables/resuable_text.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DataModel> data = [];
  final Color dark = const Color(0xff602bfa);
  final Color normal = const Color(0xff64caad);
  final Color light = const Color(0xfff2f2ff);

  final List<Color> ngoColor = [
    const Color(0xFFADA5C2),
    const Color(0xFF039CDD),
    const Color(0xFF602BF8),
  ];

  final List<Color> empColor = [
    const Color(0xFF723EFF),
    const Color(0xFFDC950A),
    const Color(0xFF3EBFF6),
    const Color(0xFFFDE567),
    const Color(0xFF039CDD),
    const Color(0xFF000000),
  ];

  List<BarChartGroupData> barLga = [];
  List<BarChartGroupData> barOccupation = [];
  List<BarChartGroupData> barAgeAtBereavement = [];

  List<String> lgaLegend = [];
  List<String> spouseBerLegend = [];
  List<String> occupationLegend = [];

  List<String> lgas = [];
  List<String> nogList = [];
  List<String> spouseBerList = [];
  List<String> occupationList = [];
  List<String> employmentStatList = [];

  Map<String, int> lgaMap = {};
  Map<String, int> empMap = {};
  Map<String, int> nogShipMap = {};
  Map<String, int> spouseBerMap = {};
  Map<String, int> occupationMap = {};

  List<PieIndicators> nogInd = [];
  List<PieIndicators> empInd = [];

  List<PieChartSectionData> ngoChartList = [];
  List<PieChartSectionData> empChartList = [];

  double localGovtMax = 1;
  double occupationTypeMax = 1;
  double spouseBerMax = 1;
  int touchedIndex = -1;

  Future<dynamic> readJson() async {
    double w = window.physicalSize.width;
    final String response = await rootBundle.loadString("assets/data.json");
    List<dynamic> j = json.decode(response);
    data = j.map((e) => DataModel.fromJson(e as Map<String, dynamic>)).toList();
    data.sort((a, b) => b.lga!.compareTo(a.lga!));

    for (DataModel x in data) {
      lgas.add(x.lga!);
      nogList.add(x.ngoMembership!);
      employmentStatList.add(x.employmentStatus!);
      var lonelyYears = smartDate(x.husbandBereavementDate!, x.dob!);
      spouseBerList.add(lonelyYears);
      occupationList.add(x.occupation);
    }

    // SORT FOR SPOUSE BEREAVEMENT AGE RAGE (Important)
    spouseBerList.sort((a, b) => b.compareTo(a));

    lgaMap = lgas.fold<Map<String, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });

    nogShipMap = nogList.fold<Map<String, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });

    empMap = employmentStatList.fold<Map<String, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });

    spouseBerMap = spouseBerList.fold<Map<String, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });

    occupationMap = occupationList.fold<Map<String, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });

    var countNgo = 0;
    for (String x in nogShipMap.keys) {
      ngoChartList.add(PieChartSectionData(
        color: ngoColor[countNgo],
        showTitle: false,
        value: (nogShipMap[x]!.toDouble() / nogShipMap.length) * 360,
        radius: w / 8,
      ));
      nogInd.add(
        PieIndicators(
            textWidget: Text(
              x,
              style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip),
            ),
            color: ngoColor[countNgo]),
      );
      countNgo++;
    }

    var countEmp = 0;
    for (String x in empMap.keys) {
      empChartList.add(PieChartSectionData(
        color: empColor[countEmp],
        showTitle: false,
        value: (empMap[x]!.toDouble() / empMap.length) * 360,
        radius: ((w / 8) - 50),
      ));
      empInd.add(
        PieIndicators(
            textWidget: Text(
              x,
              style: const TextStyle(fontSize: 12, overflow: TextOverflow.clip),
            ),
            color: empColor[countEmp]),
      );
      countEmp++;
    }

    localGovtMax = lgaMap.values.toList().reduce(max).toDouble();
    spouseBerMax = spouseBerMap.values.toList().reduce(max).toDouble();
    occupationTypeMax = occupationMap.values.toList().reduce(max).toDouble();

    for (String x in lgaMap.keys) {
      BarChartRodData rod = BarChartRodData(
        toY: localGovtMax + 50,
        rodStackItems: [
          BarChartRodStackItem(0, lgaMap[x]!.toDouble(), dark),
          BarChartRodStackItem(lgaMap[x]!.toDouble(), localGovtMax + 50, light),
        ],
        borderRadius: BorderRadius.zero,
      );
      barLga.add(
        BarChartGroupData(x: lgaLegend.length, barsSpace: 4, barRods: [rod]),
      );
      lgaLegend.add(x);
    }

    for (String x in spouseBerMap.keys.toList().reversed) {
      BarChartRodData rod = BarChartRodData(
        width: 18,
        toY: spouseBerMax + 50,
        rodStackItems: [
          BarChartRodStackItem(0, spouseBerMap[x]!.toDouble(), dark),
          BarChartRodStackItem(
              spouseBerMap[x]!.toDouble(), spouseBerMax + 50, light)
        ],
        borderRadius: BorderRadius.zero,
      );
      barAgeAtBereavement.add(
        BarChartGroupData(
            x: spouseBerLegend.length, barsSpace: 8, barRods: [rod]),
      );
      var xx = "";
      if (x == "20") {
        xx = "<20";
      } else {
        xx = x;
      }
      spouseBerLegend.add(xx);
    }

    for (String x in occupationMap.keys) {
      BarChartRodData rod = BarChartRodData(
        width: 18,
        toY: occupationTypeMax + 50,
        rodStackItems: [
          BarChartRodStackItem(0, occupationMap[x]!.toDouble(), dark),
          BarChartRodStackItem(
            occupationMap[x]!.toDouble(),
            occupationTypeMax + 50,
            light,
          ),
        ],
        borderRadius: BorderRadius.zero,
      );
      barOccupation.add(
        BarChartGroupData(
            x: occupationLegend.length, barsSpace: 4, barRods: [rod]),
      );
      occupationLegend.add(x);
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

    FlTitlesData ageAtBereavementTile = FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 65,
          getTitlesWidget: ((value, meta) {
            const style = TextStyle(color: Colors.black, fontSize: 8);
            return SideTitleWidget(
              space: 4,
              axisSide: meta.axisSide,
              child: Column(
                children: [
                  const RotatedBox(quarterTurns: 1, child: Text(" - ")),
                  Text(spouseBerLegend[value.toInt()], style: style),
                ],
              ),
            );
          }),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 500,
          getTitlesWidget: (double value, TitleMeta meta) {
            const style = TextStyle(color: Color(0xff939393), fontSize: 10);
            return SideTitleWidget(
              space: 0,
              axisSide: meta.axisSide,
              child: Text("${meta.formattedValue}-", style: style),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

    FlTitlesData occupationTile = FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 95,
          getTitlesWidget: ((v, meta) {
            const style = TextStyle(color: Colors.black, fontSize: 8);
            return SideTitleWidget(
              space: 4,
              axisSide: meta.axisSide,
              child: Column(
                children: [
                  const RotatedBox(quarterTurns: 1, child: Text(" - ")),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(occupationLegend[v.toInt()], style: style),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 500,
          getTitlesWidget: (double value, TitleMeta meta) {
            const style = TextStyle(color: Color(0xff939393), fontSize: 10);
            return SideTitleWidget(
              space: 0,
              axisSide: meta.axisSide,
              child: Text("${meta.formattedValue}-", style: style),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

    FlTitlesData lgaTile = FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 85,
          getTitlesWidget: (double value, TitleMeta meta) {
            const style = TextStyle(color: Colors.black, fontSize: 10);
            return SideTitleWidget(
              space: 36.0,
              axisSide: meta.axisSide,
              angle: 98.96,
              child: Text("${lgaLegend[value.toInt()]} - ", style: style),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 200,
          getTitlesWidget: (double value, TitleMeta meta) {
            const style = TextStyle(color: Color(0xff939393), fontSize: 10);
            return SideTitleWidget(
              angle: 98.96,
              space: 15,
              axisSide: meta.axisSide,
              child: Column(
                children: [
                  const RotatedBox(quarterTurns: 1, child: Text("-")),
                  Text(meta.formattedValue, style: style),
                ],
              ),
            );
          },
        ),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          const LineChartSample2(),
          AssetChat(
            legendText: const CustomText(
              text: "TOTAL NUMBER OF WIDOWS REGISTERED",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            countText: CustomText(
              text: "${data.length}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30,
                letterSpacing: -1.0,
              ),
              padding: EdgeInsets.only(bottom: ch / 4),
            ),
            iconPath: "assets/icons/people_icons.png",
            wavePath: "assets/icons/wave_graph1.png",
          ),
          AssetChat(
            legendText: const CustomText(
              text: "SELECT LOCAL GOVERNMENT",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            countText: CustomText(
              text: "${lgaMap.length}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30,
                letterSpacing: -1.0,
              ),
              padding: EdgeInsets.only(bottom: ch / 4),
            ),
            iconPath: "assets/icons/healthy_community.png",
            wavePath: "assets/icons/wave_graph.png",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Material(
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
                            groupsSpace: 8,
                            barGroups: barLga,
                            titlesData: lgaTile,
                            barTouchData: barTouchData,
                            gridData: gridData,
                            borderData: borderData,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomPieGraph(
            centerSpaceRadius: 50,
            indicatorList: empInd,
            employmentStaDataList: empChartList,
            centerText: const CustomText(
              text: "WIDOWS\nEMPLOYMENT\n STATUS",
              padding: EdgeInsets.only(right: 16, left: 16),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          CustomPieGraph(
            indicatorList: nogInd,
            legendText: const CustomText(
              text: "WIDOWS AFFILIATION TO NGO",
              padding: EdgeInsets.only(top: 34, right: 16, left: 16),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            employmentStaDataList: ngoChartList,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "WIDOWS AGE AT SPOUSE BEREAVEMENT",
                    padding: EdgeInsets.only(top: 34, right: 16, left: 16),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 42.0, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 18,
                          color: dark,
                        ),
                        const CustomText(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          text: "Age range",
                        ),
                      ],
                    ),
                  ),
                  CustomBarChart(
                    groupsSpace: 10,
                    gridData: gridData,
                    borderData: borderData,
                    barGroups: barAgeAtBereavement,
                    barTouchData: barTouchData,
                    titlesData: ageAtBereavementTile,
                    alignment: BarChartAlignment.spaceAround,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "WIDOWS TYPE OF OCCUPATION",
                    padding: EdgeInsets.only(top: 34, right: 16, left: 16),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  CustomBarChart(
                    groupsSpace: 10,
                    gridData: gridData,
                    borderData: borderData,
                    barGroups: barOccupation,
                    barTouchData: barTouchData,
                    titlesData: occupationTile,
                    alignment: BarChartAlignment.spaceAround,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarTouchData barTouchData = BarTouchData(
    enabled: false,
  );

  FlGridData gridData = FlGridData(
    show: false,
    drawVerticalLine: false,
  );

  FlBorderData borderData = FlBorderData(
    show: false,
  );

  String smartDate(String input, String dob) {
    List<String> months = [
      "january",
      "february",
      "march",
      "april",
      "may",
      "june",
      "july",
      "august",
      "september",
      "october",
      "november",
      "december",
    ];
    var dateOdBirth = DateTime.parse(dob);

    var list = input.toLowerCase().replaceAll(",", "").split(" ");
    var year = int.parse(list.last);
    var month = months.indexOf(list[1]);
    var day = int.parse(list[0]);
    var d = DateTime(year, month, day);
    var difference = d.difference(dateOdBirth);
    var lonelyYears = difference.inDays / 365;

    if (lonelyYears < 20) {
      return "20";
    } else if (lonelyYears > 19 && lonelyYears < 25) {
      return "20-24";
    } else if (lonelyYears > 24 && lonelyYears < 30) {
      return "25-29";
    } else if (lonelyYears > 29 && lonelyYears < 35) {
      return "30-34";
    } else if (lonelyYears > 34 && lonelyYears < 40) {
      return "35-39";
    } else if (lonelyYears > 39 && lonelyYears < 45) {
      return "40-44";
    } else if (lonelyYears > 44 && lonelyYears < 50) {
      return "45-49";
    } else if (lonelyYears > 49 && lonelyYears < 55) {
      return "50-54";
    } else if (lonelyYears > 54 && lonelyYears < 60) {
      return "55-59";
    } else if (lonelyYears >= 60) {
      return "60+";
    }
    return "";
  }
}

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});
  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color(0xff5f29f8),
    const Color(0xffa08ae1),
    const Color(0xffffffff),
  ];

  List<int> get showIndexes => const [1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {

    final lineChartBarData = [
      LineChartBarData(
        showingIndicators: showIndexes,
        color: const Color(0xff5f29f8),
        spots: const [
          FlSpot(0, 3),
          FlSpot(2.6, 2),
          FlSpot(4.9, 5),
          FlSpot(6.8, 3.1),
          FlSpot(8, 4),
          FlSpot(9.5, 3),
          FlSpot(11, 4),
        ],
        isCurved: false,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            getDotPainter: (flSpot, value, lineChartBarData, value2) {
              return FlDotCirclePainter(
                radius: 3,
                strokeWidth: 3,
                strokeColor: const Color(0xff5f29f8),
                color: Colors.white,
              );
            }),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors),
        ),
      )
    ];

    final tooltipsOnBar = lineChartBarData[0];

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: LineChart(
              LineChartData(
                showingTooltipIndicators: showIndexes.map((index) {
                  return ShowingTooltipIndicators([
                    LineBarSpot(
                      tooltipsOnBar,
                      lineChartBarData.indexOf(tooltipsOnBar),
                      tooltipsOnBar.spots[index],
                    ),
                  ]);
                }).toList(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                      return lineBarsSpot.map((lineBarSpot) {
                        return LineTooltipItem(
                          lineBarSpot.y.toString(),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: leftTitleWidgets,
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: 6,
                lineBarsData: lineChartBarData,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
