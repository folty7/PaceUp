import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/goal.dart';

class EditGoalModal extends StatefulWidget {
  final Goal goal;

  const EditGoalModal({super.key, required this.goal});

  @override
  State<EditGoalModal> createState() => _EditGoalModalState();
}

class _EditGoalModalState extends State<EditGoalModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _distanceController;
  late TextEditingController _paceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _distanceController = TextEditingController(text: widget.goal.targetDistance.toString());
    _paceController = TextEditingController(text: widget.goal.targetPace.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    _paceController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final updatedGoal = widget.goal.copyWith(
        name: _nameController.text,
        targetDistance: double.parse(_distanceController.text),
        targetPace: double.parse(_paceController.text),
      );

      Navigator.pop(context, updatedGoal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upraviť cieľ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Názov cieľa',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Zadaj názov cieľa' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'Cieľová vzdialenosť (km)',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                    suffixText: 'km',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Zadaj vzdialenosť';
                    final distance = double.tryParse(value);
                    if (distance == null || distance <= 0) return 'Zadaj platnú vzdialenosť';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paceController,
                  decoration: const InputDecoration(
                    labelText: 'Cieľové tempo (min/km)',
                    prefixIcon: Icon(Icons.speed),
                    border: OutlineInputBorder(),
                    suffixText: 'min/km',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Zadaj tempo';
                    final pace = double.tryParse(value);
                    if (pace == null || pace <= 0) return 'Zadaj platné tempo';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
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
                      child: const Text('Uložiť'),
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
