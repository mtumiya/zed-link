// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zed_link/main.dart';

void main() {
  testWidgets('App launches with login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZedLinkApp());

    // Verify that login screen is shown
    expect(find.text('Zed Link'), findsOneWidget);
    expect(find.text('Lusaka Order & Courier Platform'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });
}
