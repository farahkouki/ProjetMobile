import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:volontariat_app/main.dart';

void main() {
  testWidgets('App boots', (tester) async {
    await tester.pumpWidget(const VolontariatApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
