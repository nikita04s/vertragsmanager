import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Wichtig für iOS Widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vertragsmanager/src/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HIER SIND WIEDER DEINE ECHTEN DATEN:
  await Supabase.initialize(
    url: 'https://whrbkxrzwhkpcpmvqdar.supabase.co',
    // Dein originaler Key von ganz am Anfang:
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndocmJreHJ6d2hrcGNwbXZxZGFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzE4ODUsImV4cCI6MjA4NTgwNzg4NX0.Bt84hpZyoi6vnZYVUo0e-m8WVzksf72aYphh6zUzi_4',
  );

  runApp(const ProviderScope(child: VertragsManagerApp()));
}

class VertragsManagerApp extends StatelessWidget {
  const VertragsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // iOS System Farben
    const iosBackground = Color(0xFFF2F2F7);
   const iosPrimary = Color(0xFF0F669C);    // <-- NEU: Dein "Lapis Blue"

    return MaterialApp(
      title: 'Vertragsmanager',
      debugShowCheckedModeBanner: false,
      // Wir nutzen zwar Material, stylen es aber wie iOS
      theme: ThemeData(
        scaffoldBackgroundColor: iosBackground,
        primaryColor: iosPrimary,
        
        // App Bar Theme (Initial)
        appBarTheme: const AppBarTheme(
          backgroundColor: iosBackground,
          elevation: 0, // Kein Schatten
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black, 
            fontSize: 17, 
            fontWeight: FontWeight.w600
          ),
          iconTheme: IconThemeData(color: iosPrimary),
        ),
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: iosPrimary,
          brightness: Brightness.light,
          primary: iosPrimary,
          background: iosBackground,
          surface: Colors.white, // Karten sind weiß
        ),
        useMaterial3: true,
        // Apple nutzt "San Francisco" oder "Inter". 
        // Inter kommt dem sehr nahe und sieht sauberer aus als Poppins für Apps.
        textTheme: GoogleFonts.interTextTheme(), 
      ),
      home: const HomeScreen(),
    );
  }
}