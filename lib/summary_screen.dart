import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SummaryScreen extends StatefulWidget {
  final String name;
  final int age;
  final int steps;
  final double water;
  final double sleep;

  const SummaryScreen({
    super.key,
    required this.name,
    required this.age,
    required this.steps,
    required this.water,
    required this.sleep,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool showBarChart = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final data = [
      {"label": "Steps", "value": widget.steps.toDouble()},
      {"label": "Water (L)", "value": widget.water},
      {"label": "Sleep (hrs)", "value": widget.sleep},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Summary'),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Back", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        actions: [
          TextButton(
            onPressed: () => themeProvider.toggleTheme(),
            child: const Text("Toggle Theme", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        widget.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text("Age: ${widget.age}", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Text("Steps: ${widget.steps}", style: Theme.of(context).textTheme.bodyLarge),
                      Text("Water: ${widget.water} L", style: Theme.of(context).textTheme.bodyLarge),
                      Text("Sleep: ${widget.sleep} hrs", style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chart Type: "),
                  Switch(
                    value: showBarChart,
                    activeColor: Colors.teal,
                    onChanged: (val) => setState(() => showBarChart = val),
                  ),
                  Text(showBarChart ? "Bar" : "Line"),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.5,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                  child: showBarChart
                      ? _buildBarChart(data)
                      : _buildLineChart(data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChart _buildBarChart(List<Map<String, dynamic>> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index]["label"]!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value["value"]!,
                color: Colors.teal,
                width: 20,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  LineChart _buildLineChart(List<Map<String, dynamic>> data) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index]["label"]!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value["value"]!);
            }).toList(),
            dotData: FlDotData(show: true),
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}
