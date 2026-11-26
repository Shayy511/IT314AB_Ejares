import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../viewmodels/schedule_viewmodel.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Schedule? schedule;

  const ScheduleFormScreen({super.key, this.schedule});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController roomController;
  late TextEditingController capacityController;

  int? selectedSubjectId;

  String selectedDay = 'Monday';

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool saving = false;

  bool get isEditing => widget.schedule != null;

  final days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();

    final schedule = widget.schedule;

    selectedSubjectId = schedule?.subjectId;
    selectedDay = schedule?.dayOfWeek ?? 'Monday';

    roomController = TextEditingController(text: schedule?.room ?? '');

    capacityController = TextEditingController(
      text: schedule?.capacity.toString() ?? '',
    );

    if (schedule != null) {
      startTime = parseTime(schedule.startTime);
      endTime = parseTime(schedule.endTime);
    }
  }

  TimeOfDay parseTime(String value) {
    final parts = value.split(':');

    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  int toMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  @override
  void dispose() {
    roomController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> pickTime(bool isStart) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart
          ? startTime ?? const TimeOfDay(hour: 8, minute: 0)
          : endTime ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isStart) {
        startTime = selected;
      } else {
        endTime = selected;
      }
    });
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> saveSchedule() async {
    if (saving || !_formKey.currentState!.validate()) {
      return;
    }

    if (startTime == null || endTime == null) {
      showMessage('Select the start and end times.');
      return;
    }

    if (toMinutes(endTime!) <= toMinutes(startTime!)) {
      showMessage('End time must be after start time.');
      return;
    }

    final vm = context.read<ScheduleViewModel>();

    setState(() => saving = true);

    try {
      await vm.saveSchedule(
        Schedule(
          scheduleId: widget.schedule?.scheduleId,
          subjectId: selectedSubjectId!,
          dayOfWeek: selectedDay,
          startTime: formatTime(startTime!),
          endTime: formatTime(endTime!),
          room: roomController.text.trim(),
          capacity: int.parse(capacityController.text.trim()),
        ),
      );

      if (!mounted) return;

      showMessage(
        vm.errorMessage != null
            ? 'Schedule saved, but list reload failed.'
            : isEditing
            ? 'Schedule updated successfully.'
            : 'Schedule added successfully.',
      );

      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        showMessage('Unable to save schedule. Check the information.');
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScheduleViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 480,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 76,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    isEditing ? 'Edit Schedule' : 'Add Schedule',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Fill in the class schedule details.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  DropdownButtonFormField<int>(
                    initialValue:
                        vm.subjects.any((s) => s.subjectId == selectedSubjectId)
                        ? selectedSubjectId
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: vm.subjects.map((subject) {
                      return DropdownMenuItem<int>(
                        value: subject.subjectId!,
                        child: Text(
                          '${subject.subjectCode} - '
                          '${subject.subjectName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: saving
                        ? null
                        : (value) {
                            setState(() {
                              selectedSubjectId = value;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'Select a subject';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(),
                    ),
                    items: days.map((day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                selectedDay = value;
                              });
                            }
                          },
                  ),

                  const SizedBox(height: 16),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    leading: const Icon(Icons.access_time),
                    title: const Text('Start Time'),
                    subtitle: Text(
                      startTime?.format(context) ?? 'Select start time',
                    ),
                    onTap: saving ? null : () => pickTime(true),
                  ),

                  const SizedBox(height: 16),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    leading: const Icon(Icons.access_time),
                    title: const Text('End Time'),
                    subtitle: Text(
                      endTime?.format(context) ?? 'Select end time',
                    ),
                    onTap: saving ? null : () => pickTime(false),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: roomController,
                    enabled: !saving,
                    decoration: const InputDecoration(
                      labelText: 'Room',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final room = value?.trim() ?? '';

                      if (room.isEmpty) {
                        return 'This field is required';
                      }

                      if (room.length > 50) {
                        return 'Maximum 50 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: capacityController,
                    enabled: !saving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Capacity',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final capacity = int.tryParse(value?.trim() ?? '');

                      if (capacity == null ||
                          capacity <= 0 ||
                          capacity > 2147483647) {
                        return 'Enter a valid capacity';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  if (saving)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: vm.isSaving || vm.isLoading
                            ? null
                            : saveSchedule,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          isEditing ? 'Save Changes' : 'Add Schedule',
                        ),
                      ),
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
