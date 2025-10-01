import 'package:flutter/material.dart';
import 'screens/player_list_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PlayerListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


