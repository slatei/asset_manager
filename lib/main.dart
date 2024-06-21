import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApiService(),
      child: MaterialApp(
        title: 'Asset Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Dashboard(),
      ),
    );
  }
}
