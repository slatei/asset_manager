# Authentication

<!-- markdownlint-disable -->

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
  - [Managing User State](#managing-user-state)
    - [Step-by-Step Instructions](#step-by-step-instructions-2)
    - [1. Add Dependencies](#1-add-dependencies)
    - [2. Initialize Firebase in Your Flutter App](#2-initialize-firebase-in-your-flutter-app)
    - [3. Use `firebase_ui_auth` for Authentication](#3-use-firebase_ui_auth-for-authentication)
    - [4. Add a Logout Mechanism](#4-add-a-logout-mechanism)
    - [Running the Project](#running-the-project-1)
  - [Authentication State](#authentication-state)
    - [Steps to Implement State Management for Authentication](#steps-to-implement-state-management-for-authentication)
    - [Step-by-Step Implementation](#step-by-step-implementation)
      - [Step 1: Create AuthState Class](#step-1-create-authstate-class)
      - [Step 2: Update AuthService](#step-2-update-authservice)
      - [Step 3: Update Main Application](#step-3-update-main-application)
      - [Step 4: Update UI Components to Use AuthState](#step-4-update-ui-components-to-use-authstate)
    - [Explanation](#explanation)

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
  runApp(App());
}

class App extends StatelessWidget {
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

     runApp(App());
   }

   class App extends StatelessWidget {
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

  runApp(App());
}

class App extends StatelessWidget {
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

## Managing User State

Using `firebase_ui_auth` for authentication simplifies the process of adding authentication to your Flutter app with pre-built UI screens and functionalities. Here’s how you can integrate `firebase_ui_auth` for authentication and add a logout mechanism.

### Step-by-Step Instructions

1. **Add Dependencies**:
   Add the required Firebase dependencies to your `pubspec.yaml` file.

2. **Initialize Firebase in Your Flutter App**:
   Initialize Firebase in your Flutter app.

3. **Use `firebase_ui_auth` for Authentication**:
   Update your app to use `firebase_ui_auth` for sign-in and sign-out functionalities.

4. **Add a Logout Mechanism**:
   Add a button to allow users to log out.

### 1. Add Dependencies

Update your `pubspec.yaml` file to include the `firebase_ui_auth` package along with other required Firebase packages:

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
  firebase_ui_auth: ^1.0.0
```

Run `flutter pub get` to install the new dependencies.

### 2. Initialize Firebase in Your Flutter App

Update your `main.dart` to initialize Firebase:

**lib/main.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/dashboard.dart';
import 'firebase_options.dart';  // Automatically generated after running FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

### 3. Use `firebase_ui_auth` for Authentication

Update your `AuthService` to handle sign-in and sign-out, and replace the custom sign-in screen with `firebase_ui_auth`.

**lib/services/auth_service.dart**:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
```

Update `lib/screens/sign_in.dart` to use `firebase_ui_auth`:

**lib/screens/sign_in.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(clientId: 'YOUR_GOOGLE_CLIENT_ID'),
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }),
      ],
    );
  }
}
```

Replace the `AuthWrapper` in `main.dart` to navigate to the `Dashboard` or `SignInScreen` based on the authentication state:

**lib/main.dart** (updated):

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/dashboard.dart';
import 'screens/sign_in.dart';
import 'firebase_options.dart';  // Automatically generated after running FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/dashboard': (context) => Dashboard(),
        },
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

### 4. Add a Logout Mechanism

Update your `Dashboard` screen to include a logout button:

**lib/screens/dashboard.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../widgets/asset_card.dart';
import './asset_form.dart';
import './receipt_upload.dart';
import '../services/auth_service.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Asset>>(
        future: apiService.fetchAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No assets found.'));
          } else {
            final assets = snapshot.data!;
            final totalCost = assets.fold(0.0, (sum, asset) => sum + asset.cost);

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Assets: ${assets.length}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return AssetCard(asset: asset);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addAsset',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssetForm()),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Add Asset',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'uploadReceipt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReceiptUpload()),
              );
            },
            child: Icon(Icons.upload),
            tooltip: '

Upload Receipt',
          ),
        ],
      ),
    );
  }
}
```

### Running the Project

After making these changes, save all files and run your project again:

```sh
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

This setup will use `firebase_ui_auth` for the authentication screen, provide a mechanism for users to log in and out, and ensure the authentication state is managed and reflected in the app.

## Authentication State

Using a state manager to handle the authentication status can help simplify your code and make the authentication flow more manageable. While it adds a bit of initial complexity, it can greatly improve the maintainability and scalability of your application in the long run. For a more sophisticated and robust solution, this is generally a good approach.

Here's how you can manage the authentication status using `Provider` for state management in your Flutter application:

### Steps to Implement State Management for Authentication

1. **Create an AuthState Class**:
   Create a class to manage the authentication state.

2. **Update the AuthService**:
   Modify the `AuthService` to notify the `AuthState` about authentication changes.

3. **Update the UI to Use AuthState**:
   Use `AuthState` to control the authentication flow in your UI components.

### Step-by-Step Implementation

#### Step 1: Create AuthState Class

Create a new class `AuthState` to manage the authentication state.

**lib/state/auth_state.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  AuthState() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }
}
```

#### Step 2: Update AuthService

Modify the `AuthService` to use the `AuthState` for state management. In this example, we’ll refactor the `AuthService` to remove direct authentication handling since `AuthState` is managing it.

**lib/services/auth_service.dart**:

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
}
```

#### Step 3: Update Main Application

Update your `main.dart` file to use the `AuthState` for managing authentication status.

**lib/main.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'state/auth_state.dart';
import 'screens/dashboard.dart';
import 'screens/sign_in.dart';
import 'firebase_options.dart';  // Automatically generated after running FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        ChangeNotifierProvider(create: (context) => AuthState()),
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
    final authState = Provider.of<AuthState>(context);
    if (authState.user == null) {
      return SignInScreen();
    } else {
      return Dashboard();
    }
  }
}
```

#### Step 4: Update UI Components to Use AuthState

Update your `Dashboard` and `SignInScreen` to use `AuthState` for managing authentication.

**lib/screens/dashboard.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/asset_card.dart';
import '../state/auth_state.dart';
import './asset_form.dart';
import './receipt_upload.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authState.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Asset>>(
        future: apiService.fetchAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No assets found.'));
          } else {
            final assets = snapshot.data!;
            final totalCost = assets.fold(0.0, (sum, asset) => sum + asset.cost);

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Assets: ${assets.length}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return AssetCard(asset: asset);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addAsset',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssetForm()),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Add Asset',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'uploadReceipt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReceiptUpload()),
              );
            },
            child: Icon(Icons.upload),
            tooltip: 'Upload Receipt',
          ),
        ],
      ),
    );
  }
}
```

**lib/screens/sign_in.dart**:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import '../firebase_options.dart';  // Ensure this import is correct for your project

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(clientId: DefaultFirebaseOptions.currentPlatform.androidClientId),
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }),
      ],
    );
  }
}
```

### Explanation

1. **AuthState Class**:

   - Manages the authentication state and notifies listeners of changes.
   - Listens to Firebase Auth state changes and updates the user state.

2. **AuthService Class**:

   - Handles authentication-related operations like sign-in and sign-out.
   - Simplified to focus only on actions, while `AuthState` manages the state.

3. **Provider Setup**:

   - `AuthState` is provided at the root level, ensuring it is accessible throughout the app.
   - The `AuthWrapper` widget now relies on `AuthState` to determine whether to show the `Dashboard` or `SignInScreen`.

4. **UI Components**:
   - `Dashboard` and `SignInScreen` use `AuthState` to manage the authentication flow.
   - The `Dashboard` includes a logout button that signs out the user and navigates back to the sign-in screen.

By managing the authentication state through a state manager like `Provider`, you create a cleaner and more maintainable architecture for your app. This approach helps ensure that your UI components remain in sync with the authentication state and provides a clear separation of concerns.
