/*
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.40.0
  http: ^0.13.3
*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int daysToShow = 30; // Similar al useState en tu App.js

  // Añadir tus funciones de llamada a la API aquí

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualización de Datos de Acciones'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Slider(
              min: 5,
              max: 30,
              value: daysToShow.toDouble(),
              onChanged: (double value) {
                setState(() {
                  daysToShow = value.toInt();
                });
              },
            ),
            Text('Días mostrados: $daysToShow'),
            BarChartSample1(daysToShow: daysToShow),
          ],
        ),
      ),
    );
  }
}

class BarChartSample1 extends StatefulWidget {
  final int daysToShow;

  BarChartSample1({required this.daysToShow});

  @override
  _BarChartSample1State createState() => _BarChartSample1State();
}

class _BarChartSample1State extends State<BarChartSample1> {
  late List<double> prices;
  late List<String> dates;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiKey = 'TuAPIKey';
    const String symbol = 'IBM';
    final String apiUrl = 'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final series = data['Time Series (Daily)'] as Map<String, dynamic>;
      final sortedKeys = series.keys.toList()..sort();
      final reversedKeys = sortedKeys.reversed.toList().take(widget.daysToShow);

      setState(() {
        dates = reversedKeys.toList();
        prices = reversedKeys.map((date) => double.parse(series[date]['4. close'])).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator()
        : Container(
            height: 400,
            child: BarChart(
              BarChartData(
                barGroups: prices.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(y: entry.value, colors: [Colors.blue]),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
  }

  @override
  void didUpdateWidget(covariant BarChartSample1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysToShow != widget.daysToShow) {
      fetchData();
    }
  }
}
