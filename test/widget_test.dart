import 'package:flutter_test/flutter_test.dart';
import 'package:coworkhub/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}