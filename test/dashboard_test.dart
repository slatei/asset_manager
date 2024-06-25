import 'package:asset_store/state/auth_state.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:asset_store/state/asset_state.dart';
import 'package:asset_store/screens/dashboard.dart';
import 'package:asset_store/models/asset.dart';

void main() {
  final user = MockUser(
    isAnonymous: false,
    uid: 'uid',
    email: 'user@example.com',
    displayName: 'User',
  );

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseStorage mockStorage;
  late AssetState assetState;
  late AuthState authState;

  setUp(() async {
    mockAuth = MockFirebaseAuth(mockUser: user);
    mockStorage = MockFirebaseStorage();
    fakeFirestore = FakeFirebaseFirestore();
    assetState = AssetState(
        firestore: fakeFirestore, auth: mockAuth, storage: mockStorage);
    authState = AuthState(auth: mockAuth);

    // Sign in the fake user
    await mockAuth.signInWithEmailAndPassword(
      email: user.email!,
      password: 'example',
    );
  });

  testWidgets('Dashboard displays assets and total cost',
      (WidgetTester tester) async {
    assetState.addAssetToDatabase(Asset(
      id: '',
      name: 'Laptop',
      category: 'Technology',
      purchaseDate: '2023-01-15',
      cost: 1200.0,
      photoPath: null,
    ));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => authState),
          ChangeNotifierProvider(create: (context) => assetState),
        ],
        child: const MaterialApp(
          home: Dashboard(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Allow any async operations to complete

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Total Cost: \$1200.00'), findsOneWidget);
  });
}
