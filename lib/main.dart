import 'package:asset_store/screens/asset_lists/assets_list.dart';
import 'package:asset_store/state/categories_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:asset_store/screens/auth.dart';
import 'package:asset_store/screens/dashboard.dart';
import 'package:asset_store/state/asset_state.dart';
import 'package:asset_store/state/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    } catch (e) {
      print(e);
    }
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthState(auth: FirebaseAuth.instance)),
        ChangeNotifierProvider(
            create: (context) => AssetState(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                  storage: FirebaseStorage.instance,
                )),
        ChangeNotifierProvider(
            create: (context) => CategoriesState(
                  firestore: FirebaseFirestore.instance,
                )),
      ],
      child: MaterialApp(
        title: 'Asset Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          // '/': (context) => const AuthWrapper(),
          '/': (context) => const AssetsList(),
          '/dashboard': (context) => const Dashboard(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    if (authState.user == null) {
      return const AuthScreen();
    } else {
      return const Dashboard();
    }
  }
}

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sandbox'),
        backgroundColor: Colors.grey,
      ),
      body: const AssetsList(),
    );
  }
}
