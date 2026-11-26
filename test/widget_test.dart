import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/models/grade.dart';

void main() {
  test('Grade of 92 should be Passed', () {
    const grade = Grade(enrollmentId: 1, grade: 92);

    expect(grade.isPassed, true);
    expect(grade.remarks, 'Passed');
  });

  test('Grade of 70 should be Failed', () {
    const grade = Grade(enrollmentId: 1, grade: 70);

    expect(grade.isPassed, false);
    expect(grade.remarks, 'Failed');
  });

  test('Grade of 75 should be Passed', () {
    const grade = Grade(enrollmentId: 1, grade: 75);

    expect(grade.isPassed, true);
  });
}
