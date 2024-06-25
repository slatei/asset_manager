# Uploading Images

> Now we would like to move to adding some functionality for being able to upload a receipt and somehow scanning the receipt and auto-filling the fields wherever possible
>
> This means we will need to add two pieces of functionality:
>
> 1. On the asset_form page, add a button for uploading a receipt to firestore
> 2. Add, or trigger, some sort of function which can be used for processing the receipt, and returning information accordingly
>
> Let's focus, for now, on updating the application to upload images when creating a new app. When "creating a new app" we need a button that allows me to select an image, and once the image is selected, I should be able to continue updating the form. The image should only be added to storage once I have selected "Save Asset"

## Updating the Application

To add the functionality for uploading a receipt when creating a new asset, we will make the following updates:

1. **Update the AssetForm to include a button for selecting an image.**
2. **Modify the AssetState to handle the image upload to Firebase Storage.**
3. **Ensure the image URL is saved along with the asset details in Firestore when the "Save Asset" button is clicked.**

### Step 1: Update `AssetForm` to Include Image Selection

We'll use the `image_picker` package to allow users to select an image from their device. Update `pubspec.yaml` to include this dependency:

```yaml
dependencies:
  image_picker: ^0.8.4+8
  firebase_storage: ^10.2.0
  # Other dependencies...
```

Next, update the `AssetForm` widget to include the image selection button:

```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:asset_store/models/asset.dart';

class AssetForm extends StatefulWidget {
  const AssetForm({required this.addAsset, super.key});

  final FutureOr<void> Function(Asset asset, File? imageFile) addAsset;

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  String? _name;
  String? _category;
  String? _purchaseDate;
  double? _cost;
  String? _photoPath;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

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

      await widget.addAsset(asset, _imageFile);

      _formKey.currentState?.reset();
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
          child: ListView(
            children: <Widget>[
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
              if (_imageFile != null)
                Image.file(_imageFile!, height: 200),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Asset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Step 2: Modify `AssetState` to Handle Image Upload

Update `AssetState` to handle the image upload and saving asset details to Firestore:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../models/asset.dart';

class AssetState extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  List<Asset> _assets = [];
  List<Asset> get assets => _assets;

  AssetState({required this.firestore, required this.auth, required this.storage}) {
    _listenToAssets();
  }

  void _listenToAssets() {
    firestore.collection('assets').snapshots().listen((snapshot) {
      _assets = snapshot.docs.map((doc) {
        final data = doc.data()!;
        return Asset(
          id: doc.id,
          name: data['name'],
          category: data['category'],
          purchaseDate: data['purchaseDate'],
          cost: data['cost'],
          photoPath: data['photoPath'],
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<DocumentReference> addAssetToDatabase(Asset asset, File? imageFile) async {
    String? photoUrl;

    if (imageFile != null) {
      final ref = storage.ref().child('assets').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      photoUrl = await snapshot.ref.getDownloadURL();
    }

    return firestore.collection('assets').add(<String, dynamic>{
      'name': asset.name,
      'category': asset.category,
      'purchaseDate': asset.purchaseDate,
      'cost': asset.cost,
      'photoPath': photoUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'owner': auth.currentUser!.displayName,
      'userId': auth.currentUser!.uid,
    });
  }
}
```

### Step 3: Update Provider Setup

Ensure the `AssetState` is provided with the necessary instances of `FirebaseFirestore`, `FirebaseAuth`, and `FirebaseStorage`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
import 'state/asset_state.dart';
import 'state/auth_state.dart';
import 'screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthState(auth: FirebaseAuth.instance),
        ),
        ChangeNotifierProvider(
          create: (context) => AssetState(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
            storage: FirebaseStorage.instance,
          ),
        ),
      ],
      child: const MaterialApp(
        home: Dashboard(),
      ),
    );
  }
}
```

### Summary

1. **Updated `AssetForm`** to include a button for selecting an image using the `image_picker` package.
2. **Modified `AssetState`** to handle image uploads to Firebase Storage and save the asset details to Firestore.
3. **Updated the provider setup** to include the necessary instances of `FirebaseFirestore`, `FirebaseAuth`, and `FirebaseStorage`.

With these changes, you should be able to select an image when creating a new asset, and the image will be uploaded to Firebase Storage when the asset is saved. The image URL will be stored in Firestore along with the other asset details.

## Using Universal IO

> WARNING: You are using the Auth Emulator, which is intended for local testing only. Do not use with production credentials.
> ══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
> The following assertion was thrown building AssetForm(dirty, state: \_AssetFormState#cc4d8):
> Assertion failed: file:///Users/nic/flutter/packages/flutter/lib/src/widgets/image.dart:480:10
> !kIsWeb
> "Image.file is not supported on Flutter Web. Consider using either Image.asset or Image.network
> instead."
>
> The relevant error-causing widget was:
> AssetForm
> AssetForm:file:///Users/nic/Workspace/personal/asset_store/lib/screens/dashboard.dart:82:37
>
> When the exception was thrown, this was the stack:
> dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 296:3 throw_
> dart-sdk/lib/\_internal/js_dev_runtime/private/ddc_runtime/errors.dart 29:3 assertFailed

To address the issue where `Image.file` is not supported on Flutter Web, you can conditionally render the image using `Image.network` on web platforms and `Image.file` on other platforms. Additionally, you can use the `universal_io` package to handle file paths and URLs more easily across different platforms.

First, add the `universal_io` package to your `pubspec.yaml` file:

```yaml
dependencies:
  universal_io: ^2.0.4
  image_picker: ^0.8.4+8
  firebase_storage: ^10.2.0
  # Other dependencies...
```

Then, update your `AssetForm` to handle image selection and rendering conditionally based on the platform:

```dart
import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart' as universal_io;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:asset_store/models/asset.dart';

class AssetForm extends StatefulWidget {
  const AssetForm({required this.addAsset, super.key});

  final FutureOr<void> Function(Asset asset, io.File? imageFile) addAsset;

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');
  final ImagePicker _picker = ImagePicker();
  universal_io.File? _imageFile;
  String? _imageUrl;

  String? _name;
  String? _category;
  String? _purchaseDate;
  double? _cost;
  String? _photoPath;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() {
          _imageUrl = pickedFile.path;
        });
      } else {
        setState(() {
          _imageFile = universal_io.File(pickedFile.path);
        });
      }
    }
  }

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

      await widget.addAsset(asset, _imageFile);

      _formKey.currentState?.reset();
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
          child: ListView(
            children: <Widget>[
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
              if (_imageFile != null || _imageUrl != null)
                kIsWeb
                    ? Image.network(_imageUrl!, height: 200)
                    : Image.file(_imageFile!, height: 200),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Asset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Modifications in `AssetState` for Image Upload

Update the `AssetState` class to handle the image upload appropriately. Since the image upload is being done after the image is selected but before the asset is saved, ensure that the correct file handling is performed:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:typed_data';

import '../models/asset.dart';

class AssetState extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  List<Asset> _assets = [];
  List<Asset> get assets => _assets;

  AssetState({required this.firestore, required this.auth, required this.storage}) {
    _listenToAssets();
  }

  void _listenToAssets() {
    firestore.collection('assets').snapshots().listen((snapshot) {
      _assets = snapshot.docs.map((doc) {
        final data = doc.data();
        return Asset(
          id: doc.id,
          name: data['name'],
          category: data['category'],
          purchaseDate: data['purchaseDate'],
          cost: data['cost'],
          photoPath: data['photoPath'],
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<DocumentReference> addAssetToDatabase(Asset asset, io.File? imageFile) async {
    String? photoUrl;

    if (imageFile != null) {
      final ref = storage.ref().child('assets').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      photoUrl = await snapshot.ref.getDownloadURL();
    }

    return firestore.collection('assets').add(<String, dynamic>{
      'name': asset.name,
      'category': asset.category,
      'purchaseDate': asset.purchaseDate,
      'cost': asset.cost,
      'photoPath': photoUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'owner': auth.currentUser!.displayName,
      'userId': auth.currentUser!.uid,
    });
  }

  Future<DocumentReference> addAssetToDatabaseWeb(Asset asset, Uint8List imageBytes) async {
    String? photoUrl;

    if (imageBytes.isNotEmpty) {
      final ref = storage.ref().child('assets').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putData(imageBytes);
      final snapshot = await uploadTask.whenComplete(() {});
      photoUrl = await snapshot.ref.getDownloadURL();
    }

    return firestore.collection('assets').add(<String, dynamic>{
      'name': asset.name,
      'category': asset.category,
      'purchaseDate': asset.purchaseDate,
      'cost': asset.cost,
      'photoPath': photoUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'owner': auth.currentUser!.displayName,
      'userId': auth.currentUser!.uid,
    });
  }
}
```

### Summary

1. **Updated `AssetForm`** to include conditional image rendering using `Image.file` for mobile and `Image.network` for web.
2. **Added file handling and image upload functionality** in `AssetState` for both mobile and web.
3. **Ensured the correct instances** of `FirebaseFirestore`, `FirebaseAuth`, and `FirebaseStorage` are provided during the setup.

These changes will allow you to select an image, preview it correctly based on the platform, and upload it to Firebase Storage when saving the asset.
