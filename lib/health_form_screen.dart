import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Validators
  final _intRegex = RegExp(r'^[0-9]+$');
  final _decimalRegex = RegExp(r'^[0-9]+([.][0-9]+)?$');

  String? _validateInt(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Enter $field';
    if (!_intRegex.hasMatch(value.trim())) return '$field must be a whole number';
    return null;
  }

  String? _validateDecimal(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Enter $field';
    if (!_decimalRegex.hasMatch(value.trim())) return '$field must be a number (e.g. 2 or 2.5)';
    return null;
  }

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
      'age': int.parse(ageController.text.trim()),
      'steps': int.parse(stepsController.text.trim()),
      'water': double.parse(waterController.text.trim()),
      'sleep': double.parse(sleepController.text.trim()),
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
    required List<TextInputFormatter> inputFormatters,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator,
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
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text("Toggle Theme", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text("View History", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  // Name (free text — you didn't require numeric validation for this one)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter Name' : null,
                    ),
                  ),
                  // Age (int)
                  _buildTextField(
                    label: 'Age',
                    controller: ageController,
                    inputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (v) => _validateInt(v, 'Age'),
                  ),
                  // Steps (int)
                  _buildTextField(
                    label: 'Steps Walked Today',
                    controller: stepsController,
                    inputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (v) => _validateInt(v, 'Steps'),
                  ),
                  // Water (decimal)
                  _buildTextField(
                    label: 'Water Intake (L)',
                    controller: waterController,
                    inputType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (v) => _validateDecimal(v, 'Water Intake'),
                  ),
                  // Sleep (decimal)
                  _buildTextField(
                    label: 'Hours of Sleep',
                    controller: sleepController,
                    inputType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (v) => _validateDecimal(v, 'Hours of Sleep'),
                  ),
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
