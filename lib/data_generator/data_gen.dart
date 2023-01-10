import 'dart:convert';

import 'package:flutter/services.dart';

class DataGenerator {
  Future<dynamic> readJson() async {
    final String response = await rootBundle.loadString("assets/data.json");
    return json.decode(response);
  }
}
