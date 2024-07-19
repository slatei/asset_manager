import 'dart:io';
import 'dart:typed_data';

import 'package:asset_store/models/asset_orig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_store/screens/asset_form.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('AssetForm', () {
    late AssetForm assetForm;
    late MockImagePicker mockImagePicker;

    setUp(() {
      mockImagePicker = MockImagePicker();
      assetForm = AssetForm(
        addAsset: (AssetOriginal asset,
            {File? imageFile, Uint8List? imageBytes}) async {
          // Mock the addAsset function
        },
        imagePicker: mockImagePicker,
      );
    });

    testWidgets('validates empty form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: assetForm,
          ),
        ),
      );

      await tester.tap(find.text('Save Asset'));
      await tester.pump();

      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Please enter a category'), findsOneWidget);
      expect(find.text('Please enter a purchase date'), findsOneWidget);
      expect(find.text('Please enter a cost'), findsOneWidget);
    });

    testWidgets('picks an image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: assetForm,
          ),
        ),
      );

      await tester.tap(find.text('Upload Receipt'));
      await tester.pump();

      // Assuming MockImagePicker sets a mock image path
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('submits the form and resets fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: assetForm,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Laptop');
      await tester.enterText(find.byType(TextFormField).at(1), 'Technology');
      await tester.enterText(find.byType(TextFormField).at(2), '2023-01-15');
      await tester.enterText(find.byType(TextFormField).at(3), '1200');

      await tester.tap(find.text('Save Asset'));
      await tester.pump();

      // Check that the form fields are reset
      expect(find.text('Laptop'), findsNothing);
      expect(find.text('Technology'), findsNothing);
      expect(find.text('2023-01-15'), findsNothing);
      expect(find.text('1200'), findsNothing);
      expect(find.byType(Image), findsNothing);
    });
  });
}

// Mock ImagePicker class
class MockImagePicker extends ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool? requestFullMetadata,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return XFile('mock_image_path');
  }
}
