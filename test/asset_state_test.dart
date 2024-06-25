import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:asset_store/state/asset_state.dart';
import 'package:asset_store/models/asset.dart';

void main() async {
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

  setUp(() async {
    mockAuth = MockFirebaseAuth(mockUser: user);
    mockStorage = MockFirebaseStorage();
    fakeFirestore = FakeFirebaseFirestore();
    assetState = AssetState(
        firestore: fakeFirestore, auth: mockAuth, storage: mockStorage);

    // Sign in the fake user
    await mockAuth.signInWithEmailAndPassword(
      email: user.email!,
      password: 'example',
    );
  });

  test('initially, the asset list should be empty', () {
    expect(assetState.assets, isEmpty);
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

    // FakeFirestore needs some time to update the stream
    await Future.delayed(const Duration(milliseconds: 500));

    expect(assetState.assets.length, 1);
    expect(assetState.assets.first.name, 'Laptop');
  });

  // test('listening to Firestore updates the asset list', () async {
  //   await fakeFirestore.collection('assets').add({
  //     'name': 'Desk',
  //     'category': 'Furniture',
  //     'purchaseDate': '2022-05-10',
  //     'cost': 300.0,
  //     'photoPath': null,
  //     'timestamp': DateTime.now().millisecondsSinceEpoch,
  //     'owner': 'John Doe',
  //     'userId': '12345',
  //   });

  //   assetState._listenToAssets();

  //   await Future.delayed(
  //       const Duration(milliseconds: 500)); // Allow async updates

  //   expect(assetState.assets.length, 1);
  //   expect(assetState.assets.first.name, 'Desk');
  // });
}
