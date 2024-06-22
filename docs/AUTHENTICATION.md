# Authentication

- [Authentication](#authentication)
    - [Steps to Add Firebase Authentication to Your Flutter App](#steps-to-add-firebase-authentication-to-your-flutter-app)
    - [Step-by-Step Instructions](#step-by-step-instructions)
      - [1. Set Up Firebase Project](#1-set-up-firebase-project)
      - [2. Add Firebase SDK to Your Flutter App](#2-add-firebase-sdk-to-your-flutter-app)
      - [3. Initialize Firebase in Your Flutter App](#3-initialize-firebase-in-your-flutter-app)
      - [4. Implement Authentication](#4-implement-authentication)
      - [5. Secure Backend API](#5-secure-backend-api)
    - [Running the Project](#running-the-project)
    - [Step-by-Step Instructions](#step-by-step-instructions-1)
    - [Full Example Code Recap](#full-example-code-recap)
  - [Dealing With MacOS Local Development Issues](#dealing-with-macos-local-development-issues)

Google Cloud Platform (GCP) offers a robust authentication solution called Firebase Authentication. Firebase Authentication provides backend services, easy-to-use SDKs, and ready-made UI libraries to authenticate users to your app. It supports authentication using passwords, phone numbers, and popular federated identity providers like Google, Facebook, and Twitter.

### Steps to Add Firebase Authentication to Your Flutter App

1. **Set Up Firebase Project**:

   - Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Register your app with Firebase.

2. **Add Firebase SDK to Your Flutter App**:

   - Add Firebase SDK dependencies to your `pubspec.yaml`.

3. **Initialize Firebase in Your Flutter App**:

   - Initialize Firebase in your Flutter app.

4. **Implement Authentication**:

   - Implement the sign-in and sign-out functionality in your app.

5. **Secure Backend API**:
   - Secure your backend API endpoints to require authentication.

### Step-by-Step Instructions

#### 1. Set Up Firebase Project

- Go to the [Firebase Console](https://console.firebase.google.com/).
- Click on "Add project" and follow the setup flow.
- Once the project is created, add a new Flutter app to the project.

#### 2. Add Firebase SDK to Your Flutter App

Add the required Firebase dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^5.0.0
  http: ^0.13.3
  sqflite: ^2.0.0+3
  path_provider: ^2.0.2
  image_picker: ^0.8.4+1
  dio: ^4.0.7
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0
```

#### 3. Initialize Firebase in Your Flutter App

Initialize Firebase in the `main.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/dashboard.dart';
import 'screens/sign_in.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Asset Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return Dashboard();
        } else {
          return SignInScreen();
        }
      },
    );
  }
}
```

#### 4. Implement Authentication

Create a new file `auth_service.dart` in the `services` directory for authentication logic:

**lib/services/auth_service.dart**:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Additional methods for Google Sign-In, registration, etc. can be added here
}
```

Create a `sign_in.dart` file in the `screens` directory for the sign-in screen:

**lib/screens/sign_in.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        await authService.signInWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                        );
                      } catch (e) {
                        print(e);
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Text('Sign In'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

#### 5. Secure Backend API

Modify your backend API to require authentication. You can use Firebase Admin SDK for this. Here’s a basic example for a Node.js Express server:

**backend/middleware/authMiddleware.js**:

```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const authenticate = async (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];
  if (!idToken) {
    return res.status(401).send('Unauthorized');
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).send('Unauthorized');
  }
};

module.exports = authenticate;
```

Use this middleware in your API routes:

**backend/routes/assetRoutes.js**:

```javascript
const express = require('express');
const router = express.Router();
const assetController = require('../controllers/assetController');
const authenticate = require('../middleware/authMiddleware');

router.get('/', authenticate, assetController.getAllAssets);
router.post('/', authenticate, assetController.addAsset);
router.get('/:id', authenticate, assetController.getAssetById);
router.put('/:id', authenticate, assetController.updateAsset);
router.delete('/:id', authenticate, assetController.deleteAsset);

module.exports = router;
```

### Running the Project

After making these changes, ensure your Flutter project and backend server are both running. Use `flutter run` to start the Flutter app and `node app.js` to start your backend server.

This setup will add a layer of authentication to your app, ensuring that only authenticated users can access the asset management functionality. Firebase Authentication simplifies the process of adding secure authentication to your app while leveraging Google Cloud services.

---

> how can we build this out using the firebase authentication emulator?

---

Using the Firebase Authentication emulator allows you to develop and test your application locally without interacting with the live Firebase services. Here's how you can set up and use the Firebase Authentication emulator with your Flutter app:

### Step-by-Step Instructions

1. **Install Firebase CLI**:
   Ensure you have the Firebase CLI installed. If not, install it using npm:

   ```sh
   npm install -g firebase-tools
   ```

2. **Initialize Firebase Project**:
   If you haven't already initialized your Firebase project, do so now:

   ```sh
   firebase init
   ```

   During the initialization, select `Emulators` and follow the prompts to set up the Authentication emulator.

3. **Configure Firebase Emulators**:
   Create a `firebase.json` file in the root of your project if it doesn't exist. Add the configuration for the Authentication emulator:

   ```json
   {
     "emulators": {
       "auth": {
         "port": 9099
       }
     }
   }
   ```

4. **Start Firebase Emulators**:
   Start the Firebase emulators:

   ```sh
   firebase emulators:start
   ```

5. **Update Flutter App to Use Firebase Authentication Emulator**:

   **a. Add Dependencies**:
   Ensure you have the required Firebase dependencies in your `pubspec.yaml` file:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     provider: ^5.0.0
     http: ^0.13.3
     sqflite: ^2.0.0+3
     path_provider: ^2.0.2
     image_picker: ^0.8.4+1
     dio: ^4.0.7
     firebase_core: ^2.0.0
     firebase_auth: ^4.0.0
   ```

   **b. Initialize Firebase in `main.dart`**:
   Update your `main.dart` to initialize Firebase and use the emulator if necessary:

   ```dart
   import 'package:flutter/material.dart';
   import 'package:firebase_core/firebase_core.dart';
   import 'package:provider/provider.dart';
   import 'services/api_service.dart';
   import 'services/auth_service.dart';
   import 'screens/dashboard.dart';
   import 'screens/sign_in.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();

     // Use the Firebase Authentication emulator if available
     if (const String.fromEnvironment('USE_FIREBASE_EMULATOR') == 'true') {
       await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
     }

     runApp(MyApp());
   }

   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MultiProvider(
         providers: [
           ChangeNotifierProvider(create: (context) => ApiService()),
           ChangeNotifierProvider(create: (context) => AuthService()),
         ],
         child: MaterialApp(
           title: 'Asset Management',
           theme: ThemeData(
             primarySwatch: Colors.blue,
           ),
           home: AuthWrapper(),
         ),
       );
     }
   }

   class AuthWrapper extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       final authService = Provider.of<AuthService>(context);
       return StreamBuilder<User?>(
         stream: authService.user,
         builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
             return Center(child: CircularProgressIndicator());
           } else if (snapshot.hasData) {
             return Dashboard();
           } else {
             return SignInScreen();
           }
         },
       );
     }
   }
   ```

   **c. Update AuthService**:
   Ensure your `AuthService` uses the Firebase Auth emulator if necessary:

   **lib/services/auth_service.dart**:

   ```dart
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:flutter/foundation.dart';

   class AuthService extends ChangeNotifier {
     final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

     User? get currentUser => _firebaseAuth.currentUser;

     Stream<User?> get user => _firebaseAuth.authStateChanges();

     Future<void> signInWithEmailAndPassword(String email, String password) async {
       try {
         await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
       } catch (e) {
         throw e;
       }
     }

     Future<void> signOut() async {
       await _firebaseAuth.signOut();
     }

     // Additional methods for Google Sign-In, registration, etc. can be added here
   }
   ```

6. **Secure Backend API with Emulator**:
   Ensure your backend API can verify ID tokens using the Firebase Authentication emulator. This involves setting up the Firebase Admin SDK to use the emulator.

   **backend/middleware/authMiddleware.js**:

   ```javascript
   const admin = require('firebase-admin');

   admin.initializeApp({
     credential: admin.credential.applicationDefault(),
   });

   const authenticate = async (req, res, next) => {
     const idToken = req.headers.authorization?.split('Bearer ')[1];
     if (!idToken) {
       return res.status(401).send('Unauthorized');
     }

     try {
       const decodedToken = await admin.auth().verifyIdToken(idToken);
       req.user = decodedToken;
       next();
     } catch (error) {
       return res.status(401).send('Unauthorized');
     }
   };

   module.exports = authenticate;
   ```

7. **Testing and Running the Application**:

   - Start the Firebase emulators: `firebase emulators:start`.
   - Run your Flutter app with the environment variable to use the emulator:

     ```sh
     flutter run --dart-define=USE_FIREBASE_EMULATOR=true
     ```

### Full Example Code Recap

**pubspec.yaml**:

```yaml
name: asset_management
description: A new Flutter project to manage assets.

publish_to: 'none' # Remove this line if you want to publish to pub.dev

version: 1.0.0+1

environment:
  sdk: '>=2.12.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^5.0.0
  http: ^0.13.3
  sqflite: ^2.0.0+3
  path_provider: ^2.0.2
  image_picker: ^0.8.4+1
  dio: ^4.0.7
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  http_mock_adapter: ^0.3.1

flutter:
  uses-material-design: true
```

**lib/main.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/dashboard.dart';
import 'screens/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Use the Firebase Authentication emulator if available
  if (const String.fromEnvironment('USE_FIREBASE_EMULATOR') == 'true') {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Asset Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return Dashboard();
        } else {
          return SignInScreen();
        }
      },
    );
  }
}
```

**lib/services/auth_service.dart**:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Additional methods for Google Sign-In, registration, etc. can be added here
}
```

**lib/screens/sign_in.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _
```

## Dealing With MacOS Local Development Issues

<https://codewithandrea.com/articles/flutter-firebase-auth-macos/>
