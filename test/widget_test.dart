import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_firebase/widgets/custom_input.dart';

void main() {
  testWidgets('CustomInput renders label and hint', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomInput(
            controller: TextEditingController(),
            label: 'Email',
            hint: 'contoh@email.com',
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('contoh@email.com'), findsOneWidget);
  });
}
