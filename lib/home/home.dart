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

  bool show_me = false;

  List<Color> gradientColors = [
    const Color(0xff7948ff),
    const Color(0xffa08ae1),
    const Color(0xffffffff),
  ];

  List<int> showIndexes = [];

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
  List<LineChartBarData> lineChartBarData = [];

  List<String> lgaLegend = [];
  List<String> spouseBerLegend = [];
  List<String> occupationLegend = [];
  List<String> widowYearsLegend = [];

  List<String> lgas = [];
  List<String> nogList = [];
  List<String> spouseBerList = [];
  List<String> occupationList = [];
  List<String> employmentStatList = [];
  List<String> widowYearsList = [];

  Map<String, int> lgaMap = {};
  Map<String, int> empMap = {};
  Map<String, int> nogShipMap = {};
  Map<String, int> widowYearsMap = {};
  Map<String, int> spouseBerMap = {};
  Map<String, int> occupationMap = {};

  List<PieIndicators> nogInd = [];
  List<PieIndicators> empInd = [];

  List<PieChartSectionData> ngoChartList = [];
  List<PieChartSectionData> empChartList = [];

  List<FlSpot> widowYearsChartList = [];

  double localGovtMax = 1;
  double widowYearsMax = 1;
  double occupationTypeMax = 1;
  double spouseBerMax = 1;
  int lgaTouchedIndex = -1;

  Future<dynamic> readJson() async {
    double w = window.physicalSize.width;
    final String response = await rootBundle.loadString("assets/data.json");
    List<dynamic> j = json.decode(response);
    data = j.map((e) => DataModel.fromJson(e as Map<String, dynamic>)).toList();
    data.sort((a, b) {
      var bList = b.husbandBereavementDate!.toLowerCase()
          .replaceAll(",", "")
          .split(" ");
      var aList = a.husbandBereavementDate!.toLowerCase()
          .replaceAll(",", "")
          .split(" ");
      return bList.last.compareTo(aList.last);
    });

    for (DataModel x in data) {
      lgas.add(x.lga!);
      nogList.add(x.ngoMembership!);
      employmentStatList.add(x.employmentStatus!);
      var lonelyYears = smartDate(x.husbandBereavementDate!, x.dob!);
      spouseBerList.add(lonelyYears);
      occupationList.add(x.occupation);
      var widowYears = widowTIme(x.husbandBereavementDate!);
      widowYearsList.add(widowYears);
    }

    // SORT FOR SPOUSE BEREAVEMENT AGE RAGE (Important)
    lgas.sort((a, b) => b.compareTo(a));
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

    widowYearsMap = widowYearsList.fold<Map<String, int>>({}, (map, element) {
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
    widowYearsMax = widowYearsMap.values.toList().reduce(max).toDouble();

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

    for (String x in widowYearsMap.keys) {
      var len = widowYearsChartList.length;
      widowYearsChartList
          .add(FlSpot((len + 2).toDouble(), widowYearsMap[x]!.toDouble()));
      widowYearsLegend.add(x);
    }

    setState(() {
      if (widowYearsChartList.isNotEmpty) {
        show_me = true;
      } else {
        show_me = false;
      }
    });
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

    lineChartBarData.add(LineChartBarData(
      show: show_me,
      spots: widowYearsChartList,
      showingIndicators: showIndexes,
      color: const Color(0xff5f29f8),
      isCurved: false,
      barWidth: 4,
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
    ));

    final tooltipsOnBar = lineChartBarData[0];
    showIndexes
        .addAll([for (var i = 0; i <= widowYearsChartList.length - 1; i++) i]);

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

    FlTitlesData widowsTile = FlTitlesData(
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
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: Color(0xff68737d),
                fontSize: 10,
              );
              var r =
              [for (var i = 0; i <= widowYearsChartList.length; i++) i];

              if(r.contains((value - 1).toInt())){
                return SideTitleWidget(
                  space: 4,
                  axisSide: meta.axisSide,
                  child: Column(
                    children: [
                      const RotatedBox(quarterTurns: 1, child: Text("- ")),
                      Text(widowYearsLegend[(value).toInt() - 2], style:
                      style),
                    ],
                  ),
                );
              } else {
                return SideTitleWidget(
                    axisSide: meta.axisSide, child: const Text(""));
              }
            }),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          SizedBox(
              width: width.toDouble(),
              height: 280,
              child: const BarChartSample5()),
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
                            gridData: gridData,
                            borderData: borderData,
                            barTouchData: BarTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,
                              touchCallback: (event, barTouchResponse) {
                                if (!event.isInterestedForInteractions ||
                                    barTouchResponse == null ||
                                    barTouchResponse.spot == null) {
                                  print("object***************** ${event.isInterestedForInteractions}");
                                  return;
                                }
                                final rodIndex = barTouchResponse.spot!
                                    .touchedRodDataIndex;
                                lgaTouchedIndex =
                                    barTouchResponse.spot!
                                        .touchedBarGroupIndex;
                                print("object***************** $lgaTouchedIndex");
                              }
                              ),
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
          Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "YEARS SPENT AS A WIDOW",
                    padding: EdgeInsets.only(right: 16, left: 16, top: 20),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: cw,
                    height: ch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
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
                          gridData: FlGridData(show: false),
                          lineTouchData: LineTouchData(
                            getTouchLineEnd: (data, index) => 0,
                            getTouchedSpotIndicator:
                                (barData, List<int> spotIndexes) {
                              return spotIndexes.map((spotIndex) {}).toList();
                            },
                            enabled: false,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: const Color(0xff602bf8),
                              tooltipRoundedRadius: 5,
                              tooltipPadding: const EdgeInsets.all(4),
                              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                                return lineBarsSpot.map((lineBarSpot) {
                                  return LineTooltipItem(
                                    lineBarSpot.y.toInt().toString(),
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          titlesData: widowsTile,
                          borderData: FlBorderData(show: false),
                          minX: 2,
                          maxX: (widowYearsChartList.length + 1).toDouble(),
                          minY: 0,
                          maxY: widowYearsMax * 2,
                          lineBarsData: lineChartBarData,
                        ),
                      ),
                    ),
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

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(widowYearsLegend[value.toInt()], style: style),
    );
  }

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

  String widowTIme(String input) {
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
    var now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day);

    var list = input.toLowerCase().replaceAll(",", "").split(" ");
    var year = int.parse(list.last);
    var month = months.indexOf(list[1]);
    var day = int.parse(list[0]);
    var dateBereavement = DateTime(year, month, day);
    var difference = d.difference(dateBereavement);
    var lonelyYears = difference.inDays / 365;

    if (lonelyYears >= 1 && lonelyYears < 4) {
      return "1-3";
    } else if (lonelyYears >= 4 && lonelyYears < 7) {
      return "4-7";
    } else if (lonelyYears >= 7 && lonelyYears < 8) {
      return "7-8";
    } else if (lonelyYears >= 8 && lonelyYears < 11) {
      return "7-8";
    } else if (lonelyYears >= 11 && lonelyYears < 16) {
      return "11-15";
    } else if (lonelyYears >= 16 && lonelyYears < 21) {
      return "16-20";
    } else if (lonelyYears >= 21 && lonelyYears < 26) {
      return "21-25";
    } else if (lonelyYears >= 26 && lonelyYears < 30) {
      return "26-29";
    } else if (lonelyYears > 30) {
      return "30+";
    }
    return lonelyYears.toString();
  }
}

class BarChartSample5 extends StatefulWidget {
  const BarChartSample5({super.key});

  @override
  State<StatefulWidget> createState() => BarChartSample5State();
}

class BarChartSample5State extends State<BarChartSample5> {
  static const double barWidth = 22;
  static const shadowOpacity = 0.2;
  static const mainItems = <int, List<double>>{
    0: [2, 3, 2.5, 8],
    1: [-1.8, -2.7, -3, -6.5],
    2: [1.5, 2, 3.5, 6],
    3: [1.5, 1.5, 4, 6.5],
    4: [-2, -2, -5, -9],
    5: [-1.2, -1.5, -4.3, -10],
    6: [1.2, 4.8, 5, 5],
  };
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mon';
        break;
      case 1:
        text = 'Tue';
        break;
      case 2:
        text = 'Wed';
        break;
      case 3:
        text = 'Thu';
        break;
      case 4:
        text = 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget topTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mon';
        break;
      case 1:
        text = 'Tue';
        break;
      case 2:
        text = 'Wed';
        break;
      case 3:
        text = 'Thu';
        break;
      case 4:
        text = 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 10);
    String text;
    if (value == 0) {
      text = '0';
    } else {
      text = '${value.toInt()}0k';
    }
    return SideTitleWidget(
      angle: 45,
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget rightTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 10);
    String text;
    if (value == 0) {
      text = '0';
    } else {
      text = '${value.toInt()}0k';
    }
    return SideTitleWidget(
      angle: 45,
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  BarChartGroupData generateGroup(
      int x,
      double value1,
      double value2,
      double value3,
      double value4,
      ) {
    final isTop = value1 > 0;
    final sum = value1 + value2 + value3 + value4;
    final isTouched = touchedIndex == x;
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: sum,
          width: barWidth,
          borderRadius: isTop
              ? const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          )
              : const BorderRadius.only(
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          rodStackItems: [
            BarChartRodStackItem(
              0,
              value1,
              const Color(0xff2bdb90),
              BorderSide(
                color: Colors.white,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1,
              value1 + value2,
              const Color(0xffffdd80),
              BorderSide(
                color: Colors.white,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1 + value2,
              value1 + value2 + value3,
              const Color(0xffff4d94),
              BorderSide(
                color: Colors.white,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1 + value2 + value3,
              value1 + value2 + value3 + value4,
              const Color(0xff19bfff),
              BorderSide(
                color: Colors.white,
                width: isTouched ? 2 : 0,
              ),
            ),
          ],
        ),
        BarChartRodData(
          toY: -sum,
          width: barWidth,
          color: Colors.transparent,
          borderRadius: isTop
              ? const BorderRadius.only(
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          )
              : const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          rodStackItems: [
            BarChartRodStackItem(
              0,
              -value1,
              const Color(0xff2bdb90)
                  .withOpacity(isTouched ? shadowOpacity * 2 : shadowOpacity),
              const BorderSide(color: Colors.transparent),
            ),
            BarChartRodStackItem(
              -value1,
              -(value1 + value2),
              const Color(0xffffdd80)
                  .withOpacity(isTouched ? shadowOpacity * 2 : shadowOpacity),
              const BorderSide(color: Colors.transparent),
            ),
            BarChartRodStackItem(
              -(value1 + value2),
              -(value1 + value2 + value3),
              const Color(0xffff4d94)
                  .withOpacity(isTouched ? shadowOpacity * 2 : shadowOpacity),
              const BorderSide(color: Colors.transparent),
            ),
            BarChartRodStackItem(
              -(value1 + value2 + value3),
              -(value1 + value2 + value3 + value4),
              const Color(0xff19bfff)
                  .withOpacity(isTouched ? shadowOpacity * 2 : shadowOpacity),
              const BorderSide(color: Colors.transparent),
            ),
          ],
        ),
      ],
    );
  }

  bool isShadowBar(int rodIndex) => rodIndex == 1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: const Color(0xff020227),
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: 20,
              minY: -20,
              groupsSpace: 12,
              barTouchData: BarTouchData(
                handleBuiltInTouches: false,
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    setState(() {
                      touchedIndex = -1;
                    });
                    return;
                  }
                  final rodIndex = barTouchResponse.spot!.touchedRodDataIndex;
                  if (isShadowBar(rodIndex)) {
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
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: topTitles,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: bottomTitles,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: leftTitles,
                    interval: 5,
                    reservedSize: 42,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: rightTitles,
                    interval: 5,
                    reservedSize: 42,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                checkToShowHorizontalLine: (value) => value % 5 == 0,
                getDrawingHorizontalLine: (value) {
                  if (value == 0) {
                    return FlLine(
                      color: const Color(0xff363753),
                      strokeWidth: 3,
                    );
                  }
                  return FlLine(
                    color: const Color(0xff2a2747),
                    strokeWidth: 0.8,
                  );
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: mainItems.entries
                  .map(
                    (e) => generateGroup(
                  e.key,
                  e.value[0],
                  e.value[1],
                  e.value[2],
                  e.value[3],
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}