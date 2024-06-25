# Image Detection and Receipt Scanning

> Now we would like to move to adding some functionality for being able to upload a receipt and somehow scanning the receipt and auto-filling the fields wherever possible
>
> This means we will need to add two pieces of functionality:
>
> 1. On the asset_form page, add a button for uploading a receipt to firestore
> 2. Add, or trigger, some sort of function which can be used for processing the receipt, and returning information accordingly
>
> The first item should be relatively straightforward, however I am more interested in deciding how best to scan the receipt contents, and would like some guidance on how the receipts can be scanned, (or if it is even possible)
>
> The receipts that are to be uploaded are non-deterministic, they could be any photo of a receipt, with no set way of knowing what items are contained on the receipt, or how they will map to database fields

To add functionality for uploading and scanning receipts, you can use Firebase Storage for storing the receipt images and Google Cloud Vision API for processing and extracting information from the receipts. Here's a step-by-step guide on how to implement these features:

## Step 1: Uploading Receipts to Firestore

### Update `AssetForm` to Add Upload Button

First, update your `AssetForm` to include a button for uploading receipts. Use the `image_picker` package to allow users to select an image from their device.

1. **Add dependencies in `pubspec.yaml`:**

   ```yaml
   dependencies:
     image_picker: ^0.8.4+5
     firebase_storage: ^10.1.0
     path_provider: ^2.0.11
     path: ^1.8.2
   ```

2. **Update `AssetForm` widget:**

   ```dart
   import 'dart:async';
   import 'dart:io';
   import 'package:flutter/material.dart';
   import 'package:image_picker/image_picker.dart';
   import 'package:firebase_storage/firebase_storage.dart';

   import 'package:asset_store/models/asset.dart';

   class AssetForm extends StatefulWidget {
     const AssetForm({required this.addAsset, super.key});

     final FutureOr<void> Function(Asset asset) addAsset;

     @override
     State<AssetForm> createState() => _AssetFormState();
   }

   class _AssetFormState extends State<AssetForm> {
     final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');
     final ImagePicker _picker = ImagePicker();
     File? _receiptImage;

     String? _name;
     String? _category;
     String? _purchaseDate;
     double? _cost;
     String? _photoPath;

     void _submitForm() async {
       if (_formKey.currentState!.validate()) {
         _formKey.currentState!.save();

         final asset = Asset(
           id: '',
           name: _name!,
           category: _category!,
           purchaseDate: _purchaseDate!,
           cost: _cost!,
           photoPath: _photoPath,
         );

         await widget.addAsset(asset);

         _formKey.currentState?.reset();
       }
     }

     Future<void> _uploadReceipt() async {
       final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
       if (pickedFile != null) {
         final File file = File(pickedFile.path);
         final storageRef = FirebaseStorage.instance.ref().child('receipts/${DateTime.now().millisecondsSinceEpoch}');
         final uploadTask = storageRef.putFile(file);

         final snapshot = await uploadTask.whenComplete(() => {});
         final downloadUrl = await snapshot.ref.getDownloadURL();

         setState(() {
           _receiptImage = file;
           _photoPath = downloadUrl;
         });

         // Here you can trigger the receipt processing function
         _processReceipt(downloadUrl);
       }
     }

     Future<void> _processReceipt(String imageUrl) async {
       // Call your receipt processing function here
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Add Asset'),
         ),
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Form(
             key: _formKey,
             child: ListView(children: <Widget>[
               TextFormField(
                 decoration: const InputDecoration(labelText: 'Name'),
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Please enter a name';
                   }
                   return null;
                 },
                 onSaved: (value) {
                   _name = value;
                 },
               ),
               TextFormField(
                 decoration: const InputDecoration(labelText: 'Category'),
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Please enter a category';
                   }
                   return null;
                 },
                 onSaved: (value) {
                   _category = value;
                 },
               ),
               TextFormField(
                 decoration: const InputDecoration(labelText: 'Purchase Date'),
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Please enter a purchase date';
                   }
                   return null;
                 },
                 onSaved: (value) {
                   _purchaseDate = value;
                 },
               ),
               TextFormField(
                 decoration: const InputDecoration(labelText: 'Cost'),
                 keyboardType: TextInputType.number,
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Please enter a cost';
                   }
                   if (double.tryParse(value) == null) {
                     return 'Please enter a valid number';
                   }
                   return null;
                 },
                 onSaved: (value) {
                   _cost = double.parse(value!);
                 },
               ),
               TextFormField(
                 decoration: const InputDecoration(labelText: 'Photo Path'),
                 onSaved: (value) {
                   _photoPath = value;
                 },
               ),
               const SizedBox(height: 20),
               ElevatedButton(
                 onPressed: _uploadReceipt,
                 child: const Text('Upload Receipt'),
               ),
               const SizedBox(height: 20),
               ElevatedButton(
                 onPressed: _submitForm,
                 child: const Text('Save Asset'),
               ),
             ]),
           ),
         ),
       );
     }
   }
   ```

## Step 2: Processing the Receipt With Google Cloud Vision API

To extract text from the receipt image, you can use the Google Cloud Vision API. This API allows you to perform Optical Character Recognition (OCR) on images.

1. **Set up Google Cloud Vision API:**

   - Enable the Vision API in your Google Cloud project.
   - Create a service account and download the JSON key file.

2. **Add `googleapis` dependency in `pubspec.yaml`:**

   ```yaml
   dependencies:
     googleapis: ^7.0.0
     googleapis_auth: ^1.1.0
   ```

3. **Create a function to call the Vision API:**

   ```dart
   import 'dart:convert';
   import 'package:googleapis/vision/v1.dart' as vision;
   import 'package:googleapis_auth/auth_io.dart';
   import 'package:http/http.dart' as http;

   Future<Map<String, dynamic>> processReceipt(String imageUrl) async {
     final serviceAccountKey = jsonDecode(await rootBundle.loadString('path/to/service_account_key.json'));

     final client = await clientViaServiceAccount(
       ServiceAccountCredentials.fromJson(serviceAccountKey),
       [vision.VisionApi.cloudPlatformScope],
     );

     final visionApi = vision.VisionApi(client);
     final image = vision.Image()..source = vision.ImageSource()..imageUri = imageUrl;

     final request = vision.AnnotateImageRequest()
       ..image = image
       ..features = [vision.Feature()..type = 'TEXT_DETECTION'];

     final response = await visionApi.images.annotate(vision.BatchAnnotateImagesRequest()..requests = [request]);

     client.close();

     if (response.responses.isEmpty) {
       return {};
     }

     final annotations = response.responses.first.fullTextAnnotation;
     final text = annotations?.text ?? '';

     // Process the text to extract relevant information

     return {
       'name': extractName(text),
       'category': extractCategory(text),
       'purchaseDate': extractPurchaseDate(text),
       'cost': extractCost(text),
     };
   }

   String extractName(String text) {
     // Implement name extraction logic
   }

   String extractCategory(String text) {
     // Implement category extraction logic
   }

   String extractPurchaseDate(String text) {
     // Implement purchase date extraction logic
   }

   String extractCost(String text) {
     // Implement cost extraction logic
   }
   ```

## Step 3: Integrate Processing in AssetForm

Update the `_processReceipt` method in `AssetForm` to call the `processReceipt` function and auto-fill the fields.

```dart
Future<void> _processReceipt(String imageUrl) async {
  final extractedData = await processReceipt(imageUrl);

  setState(() {
    _name = extractedData['name'] as String?;
    _category = extractedData['category'] as String?;
    _purchaseDate = extractedData['purchaseDate'] as String?;
    _cost = extractedData['cost'] as double?;
  });
}
```

## Notes

- **Accuracy:** OCR and text extraction accuracy can vary. It may require fine-tuning based on the receipts you expect to process.
- **Security:** Ensure the service account key is securely stored and not exposed in your source code.
- **Cost:** Google Cloud Vision API usage may incur costs based on the number of images processed.

By following these steps, you can implement a system to upload receipts, process them using OCR, and auto-fill the asset form fields with extracted information.
