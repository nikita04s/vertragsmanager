import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vertragsmanager/src/home_screen.dart';

void main() {
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
          seedColor: const Color(0xFF4A90E2), // Blaues Branding
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(), // Moderne Schriftart
      ),
      home: const HomeScreen(),
    );
  }
}