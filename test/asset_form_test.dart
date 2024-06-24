import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_store/screens/asset_form.dart';
import 'package:asset_store/models/asset.dart';

void main() {
  testWidgets('AssetForm saves asset on submit', (WidgetTester tester) async {
    mockAddAsset(Asset asset) async {}

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssetForm(addAsset: mockAddAsset),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Laptop');
    await tester.enterText(find.byType(TextFormField).at(1), 'Technology');
    await tester.enterText(find.byType(TextFormField).at(2), '2023-01-15');
    await tester.enterText(find.byType(TextFormField).at(3), '1200.0');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please enter a name'), findsNothing);
    expect(find.text('Please enter a category'), findsNothing);
    expect(find.text('Please enter a purchase date'), findsNothing);
    expect(find.text('Please enter a cost'), findsNothing);
  });
}
