import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminders_provider.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RemindersProvider>();
    final items = provider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Reminders'),
        actions: [
          IconButton(
            tooltip: 'Refresh location',
            onPressed: () => provider.refreshLocationAndCheck(),
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('No reminders yet'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final r = items[i];
                final dist = provider.distanceTo(r);

                return Dismissible(
                  key: ValueKey(r.id),
                  onDismissed: (_) => provider.deleteReminder(r),
                  child: ListTile(
                    title: Text(r.title),
                    subtitle: Text(
                      dist == null
                          ? 'Tap locate to calculate distance'
                          : 'Distance: ${dist.toStringAsFixed(0)} m • Radius: ${r.radiusMeters.toStringAsFixed(0)} m',
                    ),
                    trailing: Icon(
                      r.notified
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
