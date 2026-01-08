import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/goal.dart';

class AddGoalModal extends StatefulWidget {
  const AddGoalModal({super.key});

  @override
  State<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends State<AddGoalModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _paceController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = _selectedDate.toString().split(' ')[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    _paceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _selectedDate.toString().split(' ')[0];
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        targetDistance: double.parse(_distanceController.text),
        targetPace: double.parse(_paceController.text),
        createdAt: _selectedDate.toString().split(' ')[0], // YYYY-MM-DD from picker
      );

      Navigator.pop(context, goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nadpis
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pridať nový cieľ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Názov cieľa
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Názov cieľa',
                    hintText: 'napr. Jarný maratón 2025',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Zadaj názov cieľa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cieľová vzdialenosť
                TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'Cieľová vzdialenosť (km)',
                    hintText: 'napr. 42.2',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                    suffixText: 'km',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Zadaj vzdialenosť';
                    }
                    final distance = double.tryParse(value);
                    if (distance == null || distance <= 0) {
                      return 'Zadaj platnú vzdialenosť';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cieľové tempo
                TextFormField(
                  controller: _paceController,
                  decoration: const InputDecoration(
                    labelText: 'Cieľové tempo (min/km)',
                    hintText: 'napr. 5.5',
                    prefixIcon: Icon(Icons.speed),
                    border: OutlineInputBorder(),
                    suffixText: 'min/km',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Zadaj tempo';
                    }
                    final pace = double.tryParse(value);
                    if (pace == null || pace <= 0) {
                      return 'Zadaj platné tempo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dátum začiatku
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Dátum začiatku',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),

                // Tlačidlá
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Zrušiť'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Pridať'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
