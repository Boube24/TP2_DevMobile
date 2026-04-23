// Point d'entrée de l'application Bloc-Notes : thème et écran d'accueil.
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'pages/home_page_provider.dart';
import 'services/note_service.dart';

void main() async {
  // Indispensable avant tout appel async natif (ici : formats de dates).
  WidgetsFlutterBinding.ensureInitialized();
  // Charge les données de symboles pour le formatage des dates en français (fr_FR).
  await initializeDateFormatting('fr_FR', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteService()..loadNotes(),
      child: const MyApp(),
    ),
  );
}

/// Racine de l'application : [MaterialApp] avec thème et page d'accueil.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc-Notes',
      // Masque la bande « DEBUG » en haut à droite en mode développement.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Palette dérivée d'une couleur ambre ; interface Material 3.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MainTabs(),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(), // Part 1 - setState
    HomePageProvider(), // Part 2 - Provider
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.amber,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Partie 1 - setState',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_outlined),
            label: 'Partie 2 - Provider',
          ),
        ],
      ),
    );
  }
}
