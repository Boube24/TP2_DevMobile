import 'package:flutter/material.dart';

import '../models/note.dart';
import 'db_service.dart';

enum SortOption { dateDesc, dateAsc, titreAsc, titreDesc }

class NoteService extends ChangeNotifier {
  List<Note> _notes = [];
  final DbService _db = DbService();

  bool _loading = false;
  bool get isLoading => _loading;

  SortOption _sortOption = SortOption.dateDesc;
  SortOption get sortOption => _sortOption;

  List<Note> get notes => List.unmodifiable(_notes);
  int get count => _notes.length;

  Future<void> loadNotes() async {
    _loading = true;
    notifyListeners();
    final notes = await _db.getAllNotes();
    _notes = notes;
    _applySort();
    _loading = false;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _db.insertNote(note);
    _notes.insert(0, note);
    _applySort();
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _applySort();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Note? getNoteById(String id) {
    return _notes
        .cast<Note?>()
        .firstWhere((n) => n!.id == id, orElse: () => null);
  }

  List<Note> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _notes;
    return _notes.where((n) {
      return n.titre.toLowerCase().contains(q) ||
          n.contenu.toLowerCase().contains(q);
    }).toList();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    switch (_sortOption) {
      case SortOption.dateDesc:
        _notes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case SortOption.dateAsc:
        _notes.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case SortOption.titreAsc:
        _notes.sort((a, b) =>
            a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));
        break;
      case SortOption.titreDesc:
        _notes.sort((a, b) =>
            b.titre.toLowerCase().compareTo(a.titre.toLowerCase()));
        break;
    }
  }
}

