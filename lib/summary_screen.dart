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
  bool _combinedBar = true; // true = Bar, false = Line for the combined chart

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 700 ? 680.0 : width * 0.98;

    // Data
    final stepsVal = widget.steps.toDouble();
    final waterVal = widget.water;
    final sleepVal = widget.sleep;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Summary'),
        centerTitle: true,
        leading: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => themeProvider.toggleTheme(),
            style: TextButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text("Toggle Theme", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _userCard(context),

                const SizedBox(height: 16),

                // 1) Steps-only bar chart
                _chartCard(
                  title: 'Steps',
                  child: _buildSingleBarChart(label: 'Steps', value: stepsVal),
                ),

                const SizedBox(height: 16),

                // 2) Water-only bar chart
                _chartCard(
                  title: 'Water (L)',
                  child: _buildSingleBarChart(label: 'Water (L)', value: waterVal),
                ),

                const SizedBox(height: 16),

                // 3) Sleep-only bar chart
                _chartCard(
                  title: 'Sleep (hrs)',
                  child: _buildSingleBarChart(label: 'Sleep (hrs)', value: sleepVal),
                ),

                const SizedBox(height: 16),

                // 4) Combined chart with toggle
                _chartCard(
                  title: 'Combined',
                  headerTrailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Bar'),
                      Switch(
                        value: !_combinedBar, // switch shows Line when ON
                        activeColor: Colors.teal,
                        onChanged: (v) => setState(() => _combinedBar = !v),
                      ),
                      const Text('Line'),
                    ],
                  ),
                  child: _combinedBar
                      ? _buildCombinedBarChart(stepsVal, waterVal, sleepVal)
                      : _buildCombinedLineChart(stepsVal, waterVal, sleepVal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====== UI Helpers ======

  Widget _userCard(BuildContext context) {
    return Card(
      elevation: 3,
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
    );
  }

  Widget _chartCard({
    required String title,
    required Widget child,
    Widget? headerTrailing,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (headerTrailing != null) headerTrailing,
              ],
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 1.6,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== Charts ======

  Widget _buildSingleBarChart({required String label, required double value}) {
    // single bar at x=0 with bottom title "label"
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 38),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (x, meta) {
                if (x.toInt() == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label, style: const TextStyle(fontSize: 12)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 26,
                borderRadius: BorderRadius.circular(6),
                color: Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedBarChart(double steps, double water, double sleep) {
    final labels = ['Steps', 'Water (L)', 'Sleep (hrs)'];
    final values = [steps, water, sleep];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (x, meta) {
                final i = x.toInt();
                if (i >= 0 && i < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i], style: const TextStyle(fontSize: 12)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                width: 22,
                borderRadius: BorderRadius.circular(6),
                color: Colors.teal,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCombinedLineChart(double steps, double water, double sleep) {
    final labels = ['Steps', 'Water (L)', 'Sleep (hrs)'];
    final values = [steps, water, sleep];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (x, meta) {
                final i = x.toInt();
                if (i >= 0 && i < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i], style: const TextStyle(fontSize: 12)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            color: Colors.teal,
            dotData: FlDotData(show: true),
            spots: [
              for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
            ],
          ),
        ],
        minX: 0,
        maxX: 2,
      ),
    );
  }
}
