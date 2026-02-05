import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vertragsmanager/src/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Statusbar transparent machen für den modernen Look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

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
    const iosBackground = Color(0xFFF2F2F7); // Apple System Grey 6
    const iosPrimary = Color(0xFF0F669C);    // Dein Blau
    const iosText = Color(0xFF000000);

    return MaterialApp(
      title: 'Vertragsmanager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: iosBackground,
        primaryColor: iosPrimary,
        // Apple nutzt keine "Ripple" Effekte (Wellen), sondern Highlight/Fade
        splashFactory: NoSplash.splashFactory, 
        highlightColor: Colors.transparent,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: iosBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true, // iOS Standard: Titel mittig (außer Large Title)
          titleTextStyle: TextStyle(
            color: iosText, 
            fontSize: 17, 
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: iosPrimary),
        ),
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: iosPrimary,
          primary: iosPrimary,
          surface: Colors.white,
          background: iosBackground,
        ),
        
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: iosText,
          displayColor: iosText,
        ),
        
        // WICHTIG: Echte iOS Slide-Animation beim Seitenwechsel
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}