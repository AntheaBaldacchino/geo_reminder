import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/reminders_provider.dart';



class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '200');

  double? _lat;
  double? _lng;
  bool _loadingLocation = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings( accuracy : LocationAccuracy.high, distanceFilter: 0, 
        ),
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  String _id() => DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a location first')),
      );
      return;
    }

    final radius = double.parse(_radiusCtrl.text.trim());

    final reminder = Reminder(
      id: _id(),
      title: _titleCtrl.text.trim(),
      latitude: _lat!,
      longitude: _lng!,
      radiusMeters: radius,
      createdAt: DateTime.now(),
    );

    await context.read<RemindersProvider>().addReminder(reminder);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Buy milk when near store',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _radiusCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Radius (meters)',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 50) return 'Min 50m';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadingLocation ? null : _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: Text(_loadingLocation
                    ? 'Getting location...'
                    : 'Use current location'),
              ),
              const SizedBox(height: 8),
              Text(
                _lat == null
                    ? 'Location: not set'
                    : 'Location: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
