import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class EditActivityModal extends StatefulWidget {
  final Activity activity;

  const EditActivityModal({super.key, required this.activity});

  @override
  State<EditActivityModal> createState() => _EditActivityModalState();
}

class _EditActivityModalState extends State<EditActivityModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _distanceController;
  late TextEditingController _durationController;
  late TextEditingController _dateController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController(text: widget.activity.distance.toString());
    _durationController = TextEditingController(text: widget.activity.duration.toString());
    _selectedDate = DateTime.parse(widget.activity.date);
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate));
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      final distance = double.parse(_distanceController.text);
      final duration = int.parse(_durationController.text);
      final pace = duration / distance;

      // Preserve time from original, update date from picker
      final original = DateTime.parse(widget.activity.date);
      final dateWithTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        original.hour,
        original.minute,
        original.second,
      );

      final updatedActivity = widget.activity.copyWith(
        distance: distance,
        duration: duration,
        date: dateWithTime.toIso8601String(),
        pace: double.parse(pace.toStringAsFixed(2)),
      );

      Navigator.pop(context, updatedActivity);
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
                      'Upraviť aktivitu',
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
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Dátum',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) => value == null || value.isEmpty ? 'Vyber dátum' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'Vzdialenosť (km)',
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
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Trvanie (min)',
                    prefixIcon: Icon(Icons.timer),
                    border: OutlineInputBorder(),
                    suffixText: 'min',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Zadaj trvanie';
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) return 'Zadaj platné trvanie';
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
                      onPressed: _saveActivity,
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
