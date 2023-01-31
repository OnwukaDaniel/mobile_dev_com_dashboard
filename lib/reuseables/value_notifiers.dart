import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

ValueNotifier<int> widowsCountVn = ValueNotifier(0);
ValueNotifier<int> lgaCountVn = ValueNotifier(0);
ValueNotifier<List<BarChartGroupData>> lgaGroupDataVn = ValueNotifier([]);
ValueNotifier<Map<String, int>> employmentMapVn = ValueNotifier({});
ValueNotifier<Map<String, int>> ngoMapVn = ValueNotifier({});
ValueNotifier<List<LineChartBarData>> lineChartDataVn = ValueNotifier([]);
ValueNotifier<Map<String, int>> spouseBerDataVn = ValueNotifier({});
ValueNotifier<Map<String, int>> occupationDataVn = ValueNotifier({});