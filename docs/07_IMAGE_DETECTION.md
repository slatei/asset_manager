# Image Detection and Receipt Scanning

## ATTEMPT 1

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

### Step 1: Uploading Receipts to Firestore

#### Update `AssetForm` to Add Upload Button

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

### Step 2: Processing the Receipt With Google Cloud Vision API

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

### Step 3: Integrate Processing in AssetForm

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

### Notes

- **Accuracy:** OCR and text extraction accuracy can vary. It may require fine-tuning based on the receipts you expect to process.
- **Security:** Ensure the service account key is securely stored and not exposed in your source code.
- **Cost:** Google Cloud Vision API usage may incur costs based on the number of images processed.

By following these steps, you can implement a system to upload receipts, process them using OCR, and auto-fill the asset form fields with extracted information.

## ATTEMPT 2

---

> I would like to now start scanning these receipts using AI tool to try to map values from the receipt to information about the assets; for example, mapping a "total" on the receipt to the asset "cost", or other information that could be provided from the receipt
>
> Ideally I would be able to have the "asset form" scan the image the moment the image has been provided, and fill out the form before the entire asset has been saved to the database. However I don't know if that is feasible with current tools

---

To implement receipt scanning and auto-filling the asset form in your Flutter application, we can use a combination of AI-powered OCR (Optical Character Recognition) and Natural Language Processing (NLP) tools. Google Cloud Vision API is a powerful tool for OCR, and we can leverage its capabilities to extract text from receipts. We can then use a custom logic or a lightweight NLP model to map extracted text to the relevant fields in the asset form.

Here’s a step-by-step guide to achieve this:

1. **Setup Google Cloud Vision API**:

   - Create a project on Google Cloud Platform (GCP).
   - Enable the Vision API.
   - Set up authentication by creating a service account and downloading the key file.

2. **Integrate Google Cloud Vision API in Flutter**:

   - Use a package like `googleapis` or `http` to call the Vision API from Flutter.

3. **Process and Map Receipt Data**:

   - After extracting text using Vision API, process the text to identify key information like total cost, purchase date, etc.
   - Use regex or custom logic to map these values to the asset form fields.

4. **Update the Asset Form**:
   - Automatically populate the asset form with the extracted data when the image is selected.

### Step-by-Step Implementation:

#### 1. Setting up Google Cloud Vision API

- Follow the [official documentation](https://cloud.google.com/vision/docs/setup) to set up the Vision API and obtain your service account key.

#### 2. Integrating Google Cloud Vision API in Flutter

Add dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  googleapis: ^3.0.0
  googleapis_auth: ^1.0.0
  http: ^0.13.3
  image_picker: ^0.8.4+8
  path_provider: ^2.0.7
```

Create a `vision_api_service.dart` file for interacting with Google Cloud Vision API:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';

class VisionApiService {
  final vision.VisionApi _visionApi;

  VisionApiService(this._visionApi);

  static Future<VisionApiService> create() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(r'''
    {
      "type": "service_account",
      "project_id": "YOUR_PROJECT_ID",
      "private_key_id": "YOUR_PRIVATE_KEY_ID",
      "private_key": "YOUR_PRIVATE_KEY",
      "client_email": "YOUR_CLIENT_EMAIL",
      "client_id": "YOUR_CLIENT_ID",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "YOUR_CLIENT_X509_CERT_URL"
    }
    ''');

    final httpClient = await clientViaServiceAccount(accountCredentials, [vision.VisionApi.cloudPlatformScope]);
    final visionApi = vision.VisionApi(httpClient);

    return VisionApiService(visionApi);
  }

  Future<vision.GoogleCloudVisionV1p1beta1TextAnnotation?> detectText(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final request = vision.BatchAnnotateImagesRequest(
      requests: [
        vision.AnnotateImageRequest(
          image: vision.Image(content: base64Image),
          features: [vision.Feature(type: 'TEXT_DETECTION')],
        ),
      ],
    );

    final response = await _visionApi.images.annotate(request);
    return response.responses?.first.fullTextAnnotation;
  }
}
```

#### 3. Process and Map Receipt Data

Create a `receipt_processor.dart` file to handle the processing of receipt data:

```dart
class ReceiptProcessor {
  static Map<String, String> processReceipt(String receiptText) {
    // Example processing logic to extract total cost and purchase date
    final lines = receiptText.split('\n');
    String? totalCost;
    String? purchaseDate;

    for (var line in lines) {
      if (line.toLowerCase().contains('total')) {
        final match = RegExp(r'(\d+(\.\d{2})?)').firstMatch(line);
        if (match != null) {
          totalCost = match.group(0);
        }
      } else if (RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(line)) {
        purchaseDate = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(line)?.group(0);
      }
    }

    return {
      'cost': totalCost ?? '',
      'purchaseDate': purchaseDate ?? '',
    };
  }
}
```

#### 4. Update the Asset Form

In `asset_form.dart`, add the code to handle image selection and text detection:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:your_project_name/vision_api_service.dart';
import 'package:your_project_name/receipt_processor.dart';

class AssetForm extends StatefulWidget {
  const AssetForm({required this.addAsset, super.key});

  final FutureOr<void> Function(Asset asset) addAsset;

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');

  String? _name;
  String? _category;
  String? _purchaseDate;
  double? _cost;
  String? _photoPath;
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(await pickedFile.readAsBytes());

      setState(() {
        _selectedImage = tempFile;
      });

      final visionApiService = await VisionApiService.create();
      final textAnnotation = await visionApiService.detectText(tempFile);

      if (textAnnotation != null) {
        final extractedData = ReceiptProcessor.processReceipt(textAnnotation.text!);
        setState(() {
          _cost = double.tryParse(extractedData['cost'] ?? '') ?? _cost;
          _purchaseDate = extractedData['purchaseDate'] ?? _purchaseDate;
        });
      }
    }
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
              initialValue: _purchaseDate,
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
              initialValue: _cost?.toString(),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Photo Path'),
              onSaved: (value) {
                _photoPath = value;
              },
              initialValue: _photoPath,
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,


                height: 200,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
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

This implementation covers the basics of integrating Google Cloud Vision API for text extraction from receipts and using the extracted data to auto-fill the asset form fields. Make sure to replace placeholders with actual values and handle error cases as needed.

## Setup Google Cloud Vision Library

<https://cloud.google.com/vision/docs/setup?authuser=1&hl=en>
