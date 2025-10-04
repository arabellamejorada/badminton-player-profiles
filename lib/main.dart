import 'package:flutter/material.dart';
import 'screens/player_list_screen.dart';
import 'screens/add_player_screen.dart';

void main() {
  runApp(const BadmintonPlayerProfilesApp());
}

class BadmintonPlayerProfilesApp extends StatelessWidget {
  const BadmintonPlayerProfilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Badminton Player Profiles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004E89),
          primary: const Color(0xFF004E89),
          onPrimary: const Color(0xFFEFEFD0),
          secondary: const Color(0xFF004E89),
          onSecondary: const Color(0xFFEFEFD0),
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF004E89), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF004E89),
            foregroundColor: const Color(0xFFEFEFD0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const PlayerListScreen(),
      routes: {
        '/add_player': (context) => const AddPlayerScreen(),
        // We can't add the edit screen route here since it requires a playerId parameter
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


