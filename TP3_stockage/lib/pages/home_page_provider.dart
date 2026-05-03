import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import 'api_notes_page.dart';
import 'create_page.dart';
import 'detail_page.dart';
class HomePageProvider extends StatelessWidget {
  const HomePageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageProviderView();
  }
}

class _HomePageProviderView extends StatefulWidget {
  const _HomePageProviderView();

  @override
  State<_HomePageProviderView> createState() => _HomePageProviderViewState();
}

class _HomePageProviderViewState extends State<_HomePageProviderView> {
  String _query = '';

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _formatDate(DateTime dt) {
    return DateFormat("d MMMM yyyy 'à' HH:mm", 'fr_FR').format(dt);
  }

  String _snippet(String text) {
    final t = text.trim();
    if (t.isEmpty) return '';
    if (t.length <= 30) return t;
    return '${t.substring(0, 30)}...';
  }

  String _labelForSort(SortOption option) {
    switch (option) {
      case SortOption.dateDesc:
        return "Plus récent d'abord";
      case SortOption.dateAsc:
        return "Plus ancien d'abord";
      case SortOption.titreAsc:
        return 'Titre A → Z';
      case SortOption.titreDesc:
        return 'Titre Z → A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteService = context.watch<NoteService>();
    final list = _query.trim().isEmpty
        ? noteService.notes
        : noteService.search(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        actions: [
          // 🔹 Bouton API REST
          IconButton(
            icon: const Icon(Icons.cloud),
            tooltip: 'Notes API',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApiNotesPage()),
              );
            },
          ),
          // 🔹 Tri
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) =>
                context.read<NoteService>().setSortOption(option),
            itemBuilder: (context) => SortOption.values
                .map(
                  (opt) => PopupMenuItem(
                    value: opt,
                    child: Text(_labelForSort(opt)),
                  ),
                )
                .toList(),
          ),
          // 🔹 Compteur
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Consumer<NoteService>(
                builder: (context, ns, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${ns.count} notes'),
                  );
                },
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      // 🔹 Bouton + pour créer une note
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNotePage()),
          );
          if (result is Note && context.mounted) {
            await context.read<NoteService>().addNote(result);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          if (noteService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noteService.notes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Aucune note', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('Appuyez sur + pour créer une note',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          if (_query.trim().isNotEmpty && list.isEmpty) {
            return const Center(child: Text('Aucun résultat'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final note = list[index];
              final color = _hexToColor(note.couleur);

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailNotePage(note: note),
                      ),
                    );

                    if (!context.mounted) return;

                    if (result == 'deleted') {
                      await context.read<NoteService>().deleteNote(note.id);
                    } else if (result is Note) {
                      await context.read<NoteService>().updateNote(result);
                    }
                  },
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🔹 Bande de couleur
                        Container(
                          width: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.titre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _snippet(note.contenu),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(note.dateCreation),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}