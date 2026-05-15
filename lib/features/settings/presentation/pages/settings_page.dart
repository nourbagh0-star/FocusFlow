import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:focus_flow/app/di/injection.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_state.dart';
import 'package:focus_flow/features/timer/domain/usecases/export_sessions_csv.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) => ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Daily focus goal'),
              subtitle: Text('${state.settings.dailyGoal} sessions'),
              onTap: () => _showDailyGoalDialog(context),
            ),
          ),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) => ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Daily reminder'),
              subtitle: Text(state.settings.notificationTime ?? 'Off'),
              onTap: () => _pickReminderTime(context),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export sessions to CSV'),
            subtitle: const Text('Save and share your full history'),
            onTap: () => _exportCsv(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Theme'),
            subtitle: Text('Light'),
            enabled: false,
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('FocusFlow v0.1.0'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDailyGoalDialog(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    var value = cubit.state.settings.dailyGoal;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily focus goal'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$value sessions / day',
                  style: Theme.of(ctx).textTheme.titleMedium),
              Slider(
                value: value.toDouble(),
                min: 1,
                max: 16,
                divisions: 15,
                label: '$value',
                onChanged: (v) => setState(() => value = v.round()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              cubit.setDailyGoal(value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final granted = await sl<NotificationService>().requestPermissions();
    if (!granted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Notification permission denied')),
      );
      return;
    }

    if (!context.mounted) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await cubit.setNotificationTime(formatted);
  }

  Future<void> _exportCsv(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final csv = await sl<ExportSessionsCsv>()();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/focusflow_sessions.csv');
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'FocusFlow Sessions',
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}

