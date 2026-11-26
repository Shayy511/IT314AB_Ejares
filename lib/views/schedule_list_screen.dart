import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../viewmodels/schedule_viewmodel.dart';
import 'schedule_form_screen.dart';

class ScheduleListScreen extends StatelessWidget {
  const ScheduleListScreen({super.key});

  static const accents = [
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  void showForm(BuildContext context, {Schedule? schedule}) {
    final vm = context.read<ScheduleViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: ScheduleFormScreen(schedule: schedule),
        ),
      ),
    );
  }

  Future<void> deleteSchedule(BuildContext context, Schedule schedule) async {
    final vm = context.read<ScheduleViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text(
          'Are you sure you want to delete the '
          '${schedule.subjectCode} schedule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await vm.deleteSchedule(schedule.scheduleId!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage != null
                ? 'Schedule deleted, but reload failed.'
                : 'Schedule deleted successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete schedule. '
            'It may have related enrollment records.',
          ),
        ),
      );
    }
  }

  String displayTime(BuildContext context, String value) {
    final parts = value.split(':');

    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    ).format(context);
  }

  Widget infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScheduleViewModel>();
    final busy = vm.isLoading || vm.isSaving;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Schedule Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4527A0), Color(0xFFD84315)],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload schedules',
            onPressed: busy ? null : vm.loadSchedules,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy || vm.errorMessage != null
            ? null
            : () => showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0), Color(0xFFEDE7F6)],
          ),
        ),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 5,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 65,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Class Schedules',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text('${vm.schedules.length} schedules'),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(child: buildScheduleList(context, vm, busy)),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleList(
    BuildContext context,
    ScheduleViewModel vm,
    bool busy,
  ) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: vm.loadSchedules,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 12),
            Text('No schedules available.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: vm.schedules.length,
      itemBuilder: (context, index) {
        final schedule = vm.schedules[index];

        final color = accents[index % accents.length];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Colors.white,
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 7)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color.shade100,
                  child: Icon(Icons.calendar_month, color: color.shade700),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.subjectCode ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color.shade700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        schedule.subjectName ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const Divider(),

                      infoRow(Icons.calendar_today, schedule.dayOfWeek, color),

                      infoRow(
                        Icons.access_time,
                        '${displayTime(context, schedule.startTime)}'
                        ' - '
                        '${displayTime(context, schedule.endTime)}',
                        color,
                      ),

                      infoRow(
                        Icons.meeting_room,
                        'Room: ${schedule.room}',
                        color,
                      ),

                      infoRow(
                        Icons.people,
                        'Capacity: ${schedule.capacity}',
                        color,
                      ),
                      infoRow(
                        Icons.person,
                        'Enrolled: ${schedule.enrolledStudents}',
                        color,
                      ),

                      infoRow(
                        Icons.event_available,
                        'Available Slots: ${schedule.availableSlots}',
                        schedule.availableSlots > 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    IconButton(
                      tooltip: 'Edit Schedule',
                      onPressed: busy
                          ? null
                          : () => showForm(context, schedule: schedule),
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    ),

                    IconButton(
                      tooltip: 'Delete Schedule',
                      onPressed: busy
                          ? null
                          : () => deleteSchedule(context, schedule),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
