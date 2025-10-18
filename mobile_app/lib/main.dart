import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import the package
import 'package:mobile_app/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // --- NEW: Get credentials from dotenv ---
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  // Basic check to ensure keys were loaded
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase URL/Key not found in .env file');
  }

  await Supabase.initialize(
    url: supabaseUrl, // Use variable
    anonKey: supabaseAnonKey, // Use variable
  );

  try {
    await Supabase.instance.client.auth.signInAnonymously();
  } catch (e) {
    debugPrint("Anonymous sign-in error: $e");
  }

  runApp(const AlAsasApp());
}

class AlAsasApp extends StatelessWidget {
  const AlAsasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alasas',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
