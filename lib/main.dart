import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Das Paket
import 'package:vertragsmanager/src/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HIER DEINE DATEN EINFÜGEN (Copy & Paste aus dem Browser):
  await Supabase.initialize(
    url: 'https://whrbkxrzwhkpcpmvqdar.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndocmJreHJ6d2hrcGNwbXZxZGFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzE4ODUsImV4cCI6MjA4NTgwNzg4NX0.Bt84hpZyoi6vnZYVUo0e-m8WVzksf72aYphh6zUzi_4',
  );

  runApp(const ProviderScope(child: VertragsManagerApp()));
}

class VertragsManagerApp extends StatelessWidget {
  const VertragsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertragsmanager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}