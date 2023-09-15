import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:miteiru/background/hive_database.dart';
import 'package:miteiru/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<void> _initialization = initializeApp();

  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dir = await getApplicationDocumentsDirectory();
    Hive.defaultDirectory = dir.path;
    await HiveDatabase.initDatabases();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromRGBO(240, 246, 254, 0)),
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const MyHomePage(title: 'Miteiru'); // Your main screen
            }
            if (snapshot.hasError) {
              return const SomethingWentWrong(); // Error Screen
            }
            return const LoadingScreen(); // Loading Screen
          },
        ));
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Something went wrong!'),
      ),
    );
  }
}
