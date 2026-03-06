import 'package:flutter_test/flutter_test.dart';

import 'package:student_grading_cal/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GradeCalculatorApp());
    expect(find.text('Student Grading System'), findsOneWidget);
    expect(find.text('Automated Grade Calculator'), findsOneWidget);
  });
}
