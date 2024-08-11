import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:teacher_attendance_app/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}