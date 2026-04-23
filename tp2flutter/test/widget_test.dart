// Test widget Flutter de base.
//
// Pour interagir avec un widget dans vos tests, utilisez l'utilitaire WidgetTester
// du package flutter_test (tap, défilement, recherche dans l'arbre, etc.).

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:tp2flutter/main.dart';

void main() {
  setUpAll(() {
    // Sqflite nécessite une implémentation en environnement de test (hors mobile).
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Test smoke : l\'app affiche Mes Notes', (WidgetTester tester) async {
    // Construire l'application et déclencher une frame.
    await tester.pumpWidget(const MyApp());

    // Vérifier que la barre d'application contient le titre attendu.
    expect(find.text('Mes Notes'), findsOneWidget);
  });
}
