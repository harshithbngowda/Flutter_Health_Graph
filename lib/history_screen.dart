import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'summary_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> entries = prefs.getStringList('history') ?? <String>[];
    setState(() {
      _history = entries.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Back", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      body: _history.isEmpty
          ? const Center(child: Text("No history available"))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final entry = _history[index];
                final date = DateTime.tryParse(entry['date'] ?? '') ?? DateTime.now();
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(entry['name']),
                    subtitle: Text(
                        "Steps: ${entry['steps']} | Water: ${entry['water']}L | Sleep: ${entry['sleep']} hrs"),
                    trailing: Text("${date.day}/${date.month}/${date.year}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SummaryScreen(
                            name: entry['name'],
                            age: entry['age'],
                            steps: entry['steps'],
                            water: (entry['water'] as num).toDouble(),
                            sleep: (entry['sleep'] as num).toDouble(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
