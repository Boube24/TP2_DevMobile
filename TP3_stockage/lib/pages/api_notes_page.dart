import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  final ApiService _api = ApiService();
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final notes = await _api.getAllNotes();
      setState(() { _notes = notes; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Erreur : $e'; _isLoading = false; });
    }
  }

  Future<void> _createNote() async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titre: 'Nouvelle note',
      contenu: 'Contenu de la note',
      couleur: '#FFE082',
      dateCreation: DateTime.now(),
    );
    final success = await _api.createNote(note);
    if (!mounted) return;
    if (success) {
      setState(() => _notes.insert(0, note));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Note créée !'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erreur création'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteNote(Note note, int index) async {
    final success = await _api.deleteNote(note.id);
    if (!mounted) return;
    if (success) {
      setState(() => _notes.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Note supprimée !'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes API'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotes),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadNotes,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _notes.isEmpty
                  ? const Center(child: Text('Aucune note'))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Dismissible(
                          key: Key(note.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteNote(note, index),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(note.titre,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(note.contenu,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}