# Authentication

- [Authentication](#authentication)
  - [Steps to Add Firebase Authentication](#steps-to-add-firebase-authentication)
  - [Step-by-Step Instructions](#step-by-step-instructions)
    - [1. Set Up Firebase Project](#1-set-up-firebase-project)
    - [2. Add Firebase to Your Flutter App](#2-add-firebase-to-your-flutter-app)
    - [3. Configure Authentication Methods](#3-configure-authentication-methods)
    - [4. Implement Authentication in Your Flutter App](#4-implement-authentication-in-your-flutter-app)

Google Cloud offers several authentication solutions that can be integrated into your Flutter app, such as Firebase Authentication. Firebase Authentication provides a secure and easy-to-use way to add authentication and user management to your app, supporting various methods like email/password, phone authentication, and social logins including Google Sign-In.

## Steps to Add Firebase Authentication

1. **Set Up Firebase Project**
2. **Add Firebase to Your Flutter App**
3. **Configure Authentication Methods**
4. **Implement Authentication in Your Flutter App**

## Step-by-Step Instructions

### 1. Set Up Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click on "Add Project" and follow the instructions to create a new Firebase project.
3. Once the project is created, navigate to the project dashboard.

### 2. Add Firebase to Your Flutter App

1. **Add Firebase SDKs**:

   - In your Firebase project console, click on the Android icon to add an Android app to your Firebase project.
   - Follow the instructions to download the `google-services.json` file and place it in the `android/app` directory.
   - Similarly, click on the iOS icon to add an iOS app to your Firebase project and download the `GoogleService-Info.plist` file, placing it in the `ios/Runner` directory.

2. **Add FlutterFire Plugins**:
   Add the necessary Firebase dependencies to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     firebase_core: latest_version
     firebase_auth: latest_version
     provider: ^5.0.0
     http: ^0.13.3
     sqflite: ^2.0.0+3
     path_provider: ^2.0.2
     image_picker: ^0.8.4+1
     dio: ^4.0.7
   ```

   Replace `latest_version` with the latest versions of `firebase_core` and `firebase_auth` from pub.dev.

3. **Configure Firebase for Android**:

   - Modify the `android/build.gradle` file:

     ```groovy
     buildscript {
       dependencies {
         classpath 'com.google.gms:google-services:4.3.10' // Add this line
       }
     }
     ```

   - Modify the `android/app/build.gradle` file:

     ```groovy
     apply plugin: 'com.google.gms.google-services' // Add this line
     ```

4. **Configure Firebase for iOS**:

   - Open `ios/Runner.xcworkspace` in Xcode.
   - Add the `GoogleService-Info.plist` file to the project.
   - Modify the `ios/Podfile` to include the Firebase SDK:

     ```ruby
     platform :ios, '10.0'
     use_frameworks! # Add this line if it's not already present
     pod 'Firebase/Core'
     pod 'Firebase/Auth'
     ```

5. **Initialize Firebase in Your Flutter App**:
   Modify the `main.dart` file to initialize Firebase:

   ```dart
   import 'package:flutter/material.dart';
   import 'package:firebase_core/firebase_core.dart';
   import 'screens/dashboard.dart';
   import 'package:provider/provider.dart';
   import 'services/api_service.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(MyApp());
   }

   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return ChangeNotifierProvider(
         create: (context) => ApiService(),
         child: MaterialApp(
           title: 'Asset Management',
           theme: ThemeData(
             primarySwatch: Colors.blue,
           ),
           home: Dashboard(),
         ),
       );
     }
   }
   ```

### 3. Configure Authentication Methods

1. In the Firebase console, navigate to "Authentication" -> "Sign-in method".
2. Enable the sign-in providers you want to use (e.g., Email/Password, Google, etc.).

### 4. Implement Authentication in Your Flutter App

1. **Create Authentication Service**:
   Create a new file `auth_service.dart` to handle authentication logic:

   ```dart
   import 'package:firebase_auth/firebase_auth.dart';

   class AuthService {
     final FirebaseAuth _auth = FirebaseAuth.instance;

     // Sign in with email and password
     Future<User?> signInWithEmailAndPassword(String email, String password) async {
       try {
         UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
         User? user = result.user;
         return user;
       } catch (e) {
         print(e.toString());
         return null;
       }
     }

     // Register with email and password
     Future<User?> registerWithEmailAndPassword(String email, String password) async {
       try {
         UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
         User? user = result.user;
         return user;
       } catch (e) {
         print(e.toString());
         return null;
       }
     }

     // Sign out
     Future<void> sign
   ```
