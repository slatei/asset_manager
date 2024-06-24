# Testing

Writing tests for your Flutter application ensures that your app's functionality is correct and that changes don't break existing features. Flutter provides robust support for writing unit tests, widget tests, and integration tests. For testing state management and Firestore integration, we'll focus on unit tests and widget tests.

## Step 1: Setup Your Test Environment

First, add the necessary dependencies to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  fake_cloud_firestore: ^3.0.1
  firebase_auth_mocks: ^0.14.0
```

## Step 2: Write Unit Tests for `AssetState`

We'll use `cloud_firestore_mocks` and `firebase_auth_mocks` to mock Firestore and Firebase Auth for testing purposes.

**test/asset_state_test.dart**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:provider/provider.dart';

import 'package:asset_store/state/asset_state.dart';
import 'package:asset_store/models/asset.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirestoreInstance mockFirestore;
  late AssetState assetState;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirestoreInstance();
    assetState = AssetState();
  });

  test('initially, the asset list should be empty', () {
    expect(assetState.assets, []);
  });

  test('adding an asset updates the asset list', () async {
    final asset = Asset(
      id: '',
      name: 'Laptop',
      category: 'Technology',
      purchaseDate: '2023-01-15',
      cost: 1200.0,
      photoPath: null,
    );

    await assetState.addAssetToDatabase(asset);

    expect(assetState.assets.length, 1);
    expect(assetState.assets.first.name, 'Laptop');
  });

  test('listening to Firestore updates the asset list', () async {
    await mockFirestore.collection('assets').add({
      'name': 'Desk',
      'category': 'Furniture',
      'purchaseDate': '2022-05-10',
      'cost': 300.0,
      'photoPath': null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'owner': 'John Doe',
      'userId': '12345',
    });

    assetState._listenToAssets();

    await Future.delayed(Duration(milliseconds: 500)); // Allow async updates

    expect(assetState.assets.length, 1);
    expect(assetState.assets.first.name, 'Desk');
  });
}
```

## Step 3: Write Widget Tests for `Dashboard` and `AssetForm`

For widget tests, we use `flutter_test` to verify the widget behavior and interactions.

**test/dashboard_test.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:asset_store/state/asset_state.dart';
import 'package:asset_store/screens/dashboard.dart';
import 'package:asset_store/models/asset.dart';

void main() {
  testWidgets('Dashboard displays assets and total cost', (WidgetTester tester) async {
    final assetState = AssetState();
    assetState.addAssetToDatabase(Asset(
      id: '',
      name: 'Laptop',
      category: 'Technology',
      purchaseDate: '2023-01-15',
      cost: 1200.0,
      photoPath: null,
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => assetState,
        child: MaterialApp(
          home: Dashboard(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Allow any async operations to complete

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Total Cost: \$1200.00'), findsOneWidget);
  });
}
```

**test/asset_form_test.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_store/screens/asset_form.dart';
import 'package:asset_store/models/asset.dart';

void main() {
  testWidgets('AssetForm saves asset on submit', (WidgetTester tester) async {
    final mockAddAsset = (Asset asset) async {};

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
```

## Summary

- **Unit tests**: Verify the logic in `AssetState` for adding assets and listening to Firestore updates.
- **Widget tests**: Verify the UI behavior of `Dashboard` and `AssetForm` using `flutter_test`.

Run the tests with the following command:

```sh
flutter test
```

This setup ensures your app is well-tested and helps you catch bugs early in the development process.
