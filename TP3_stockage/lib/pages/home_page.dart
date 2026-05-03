// // Liste des notes : chargement depuis la base, navigation vers création et détail.
// import 'package:flutter/material.dart';

// import '../models/note.dart';
// import '../services/db_service.dart';
// import 'create_page.dart';
// import 'detail_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Note> _notes = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }

//   Future<void> _loadNotes() async {
//     final notes = await DbService().getAllNotes();
//     if (!mounted) return;
//     setState(() {
//       _notes = notes;
//       _isLoading = false;
//     });
//   }

//   Color _hexToColor(String hex) {
//     final buffer = StringBuffer();
//     if (hex.length == 7) buffer.write('ff');
//     buffer.write(hex.replaceFirst('#', ''));
//     return Color(int.parse(buffer.toString(), radix: 16));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mes Notes')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CreateNotePage()),
//           );
//           if (result is Note) {
//             await DbService().insertNote(result);
//             await _loadNotes();
//           }
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: Builder(
//         builder: (context) {
//           if (_isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (_notes.isEmpty) {
//             return const Center(child: Text('Aucune note'));
//           }

//           return ListView.builder(
//             itemCount: _notes.length,
//             itemBuilder: (context, index) {
//               final note = _notes[index];
//               final color = _hexToColor(note.couleur);

//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: InkWell(
//                   onTap: () async {
//                     final result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => DetailNotePage(note: note),
//                       ),
//                     );

//                     if (result == 'deleted') {
//                       await DbService().deleteNote(note.id);
//                       await _loadNotes();
//                     } else if (result is Note) {
//                       await DbService().updateNote(result);
//                       await _loadNotes();
//                     }
//                   },
//                   child: IntrinsicHeight(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Container(
//                           width: 8,
//                           decoration: BoxDecoration(
//                             color: color,
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(12),
//                               bottomLeft: Radius.circular(12),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.all(12),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 note.titre,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<NoteService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Bloc Notes")),
      body: ListView.builder(
        itemCount: service.notes.length,
        itemBuilder: (context, index) {
          final note = service.notes[index];

          return ListTile(
            title: Text(note.titre),
            subtitle: Text(note.contenu),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                service.deleteNote(note.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final note = Note(
            id: DateTime.now().toString(),
            titre: "Note ${service.notes.length}",
            contenu: "Contenu",
            couleur: "#FFE082",
            dateCreation: DateTime.now(),
          );

          service.addNote(note);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}