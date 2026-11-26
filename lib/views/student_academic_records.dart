import 'package:flutter/material.dart';
import '../models/academic_record.dart';
import '../repositories/academic_record_repository.dart';

class StudentAcademicRecords extends StatefulWidget {
  final int studentId;

  const StudentAcademicRecords({super.key, required this.studentId});

  @override
  State<StudentAcademicRecords> createState() => _StudentAcademicRecordsState();
}

class _StudentAcademicRecordsState extends State<StudentAcademicRecords> {
  final AcademicRecordRepository repository = AcademicRecordRepository();

  late Future<List<AcademicRecord>> recordsFuture;

  @override
  void initState() {
    super.initState();
    recordsFuture = repository.getStudentRecords(widget.studentId);
  }

  @override
  void didUpdateWidget(covariant StudentAcademicRecords oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.studentId != widget.studentId) {
      recordsFuture = repository.getStudentRecords(widget.studentId);
    }
  }

  void refreshRecords() {
    setState(() {
      recordsFuture = repository.getStudentRecords(widget.studentId);
    });
  }

  Widget summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget recordCard(AcademicRecord record) {
    final MaterialColor color = record.grade == null
        ? Colors.grey
        : record.isPassed
        ? Colors.green
        : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 6)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.subjectCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              record.subjectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            infoRow(Icons.menu_book, 'Units: ${record.units}'),

            infoRow(Icons.calendar_today, record.dayOfWeek),

            infoRow(
              Icons.access_time,
              '${record.startTime} - ${record.endTime}',
            ),

            infoRow(Icons.meeting_room, 'Room: ${record.room}'),

            const Divider(),

            Text(
              record.grade == null
                  ? 'Grade: Not Yet Graded'
                  : 'Grade: ${record.grade!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record.remarks,
                style: TextStyle(
                  color: color.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Academic Records',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            IconButton(
              tooltip: 'Refresh Academic Records',
              onPressed: refreshRecords,
              icon: const Icon(Icons.refresh, color: Colors.deepPurple),
            ),
          ],
        ),

        const SizedBox(height: 12),

        FutureBuilder<List<AcademicRecord>>(
          future: recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  const Text('Unable to load academic records.'),

                  ElevatedButton(
                    onPressed: refreshRecords,
                    child: const Text('Retry'),
                  ),
                ],
              );
            }

            final records = snapshot.data ?? <AcademicRecord>[];

            if (records.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.menu_book, size: 48, color: Colors.deepPurple),

                      SizedBox(height: 12),

                      Text('No enrolled subjects.'),
                    ],
                  ),
                ),
              );
            }

            final totalUnits = records.fold<int>(
              0,
              (sum, record) => sum + record.units,
            );

            final gradedRecords = records
                .where((record) => record.grade != null)
                .toList();

            final totalGrade = gradedRecords.fold<double>(
              0,
              (sum, record) => sum + record.grade!,
            );

            final average = gradedRecords.isEmpty
                ? null
                : totalGrade / gradedRecords.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        summaryItem(
                          'Subjects',
                          '${records.length}',
                          Colors.deepPurple,
                        ),

                        summaryItem(
                          'Total Units',
                          '$totalUnits',
                          Colors.deepOrange,
                        ),

                        summaryItem(
                          'Average Grade',
                          average == null ? '—' : average.toStringAsFixed(2),
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ...records.map(recordCard),
              ],
            );
          },
        ),
      ],
    );
  }
}
