import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'summary_screen.dart';
import 'theme_provider.dart';
import 'history_screen.dart';

class HealthFormScreen extends StatefulWidget {
  const HealthFormScreen({super.key});

  @override
  State<HealthFormScreen> createState() => _HealthFormScreenState();
}

class _HealthFormScreenState extends State<HealthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final stepsController = TextEditingController();
  final waterController = TextEditingController();
  final sleepController = TextEditingController();

  Future<void> _saveData(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> entries = prefs.getStringList('history') ?? <String>[];
    entries.add(jsonEncode(entry));
    await prefs.setStringList('history', entries);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final entry = {
      'name': nameController.text.trim(),
      'age': int.tryParse(ageController.text.trim()) ?? 0,
      'steps': int.tryParse(stepsController.text.trim()) ?? 0,
      'water': double.tryParse(waterController.text.trim()) ?? 0.0,
      'sleep': double.tryParse(sleepController.text.trim()) ?? 0.0,
      'date': DateTime.now().toIso8601String(),
    };

    await _saveData(entry);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          name: entry['name'] as String,
          age: entry['age'] as int,
          steps: entry['steps'] as int,
          water: (entry['water'] as num).toDouble(),
          sleep: (entry['sleep'] as num).toDouble(),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType inputType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    stepsController.dispose();
    waterController.dispose();
    sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 600 ? 550.0 : width * 0.94;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Health Input'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => themeProvider.toggleTheme(),
            child: const Text("Toggle Theme", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            child: const Text("View History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Track your daily health below:',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(label: 'Name', controller: nameController, inputType: TextInputType.name),
                  _buildTextField(label: 'Age', controller: ageController, inputType: TextInputType.number),
                  _buildTextField(
                      label: 'Steps Walked Today', controller: stepsController, inputType: TextInputType.number),
                  _buildTextField(
                      label: 'Water Intake (L)',
                      controller: waterController,
                      inputType: const TextInputType.numberWithOptions(decimal: true)),
                  _buildTextField(
                      label: 'Hours of Sleep',
                      controller: sleepController,
                      inputType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
