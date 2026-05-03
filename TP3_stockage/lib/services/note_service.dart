// import 'package:flutter/material.dart';

// import '../models/note.dart';
// import 'db_service.dart';

// enum SortOption { dateDesc, dateAsc, titreAsc, titreDesc }

// class NoteService extends ChangeNotifier {
//   List<Note> _notes = [];
//   final DbService _db = DbService();

//   bool _loading = false;
//   bool get isLoading => _loading;

//   SortOption _sortOption = SortOption.dateDesc;
//   SortOption get sortOption => _sortOption;

//   List<Note> get notes => List.unmodifiable(_notes);
//   int get count => _notes.length;

//   Future<void> loadNotes() async {
//     _loading = true;
//     notifyListeners();
//     final notes = await _db.getAllNotes();
//     _notes = notes;
//     _applySort();
//     _loading = false;
//     notifyListeners();
//   }

//   Future<void> addNote(Note note) async {
//     await _db.insertNote(note);
//     _notes.insert(0, note);
//     _applySort();
//     notifyListeners();
//   }

//   Future<void> updateNote(Note note) async {
//     await _db.updateNote(note);
//     final index = _notes.indexWhere((n) => n.id == note.id);
//     if (index != -1) {
//       _notes[index] = note;
//       _applySort();
//       notifyListeners();
//     }
//   }

//   Future<void> deleteNote(String id) async {
//     await _db.deleteNote(id);
//     _notes.removeWhere((n) => n.id == id);
//     notifyListeners();
//   }

//   Note? getNoteById(String id) {
//     return _notes
//         .cast<Note?>()
//         .firstWhere((n) => n!.id == id, orElse: () => null);
//   }

//   List<Note> search(String query) {
//     final q = query.trim().toLowerCase();
//     if (q.isEmpty) return _notes;
//     return _notes.where((n) {
//       return n.titre.toLowerCase().contains(q) ||
//           n.contenu.toLowerCase().contains(q);
//     }).toList();
//   }

//   void setSortOption(SortOption option) {
//     _sortOption = option;
//     _applySort();
//     notifyListeners();
//   }

//   void _applySort() {
//     switch (_sortOption) {
//       case SortOption.dateDesc:
//         _notes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
//         break;
//       case SortOption.dateAsc:
//         _notes.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
//         break;
//       case SortOption.titreAsc:
//         _notes.sort((a, b) =>
//             a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));
//         break;
//       case SortOption.titreDesc:
//         _notes.sort((a, b) =>
//             b.titre.toLowerCase().compareTo(a.titre.toLowerCase()));
//         break;
//     }
//   }
// }
// import 'dart:convert';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import 'db_service.dart';

enum SortOption { dateDesc, dateAsc, titreAsc, titreDesc }

class NoteService extends ChangeNotifier {
  final SharedPreferences prefs;
  final DbService _db = DbService();

  List<Note> _notes = [];
  SortOption _sortOption = SortOption.dateDesc;
  bool isLoading = false;

  NoteService(this.prefs) {
    _loadNotes();
  }

  // 🔹 Getter notes triées
  List<Note> get notes {
    final sorted = [..._notes];
    switch (_sortOption) {
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case SortOption.dateAsc:
        sorted.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case SortOption.titreAsc:
        sorted.sort((a, b) => a.titre.compareTo(b.titre));
        break;
      case SortOption.titreDesc:
        sorted.sort((a, b) => b.titre.compareTo(a.titre));
        break;
    }
    return sorted;
  }

  // 🔹 Nombre de notes
  int get count => _notes.length;

  // 🔹 Changer le tri
  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  // 🔹 Recherche
  List<Note> search(String query) {
    if (query.trim().isEmpty) return notes;
    return notes
        .where((n) =>
            n.titre.toLowerCase().contains(query.toLowerCase()) ||
            n.contenu.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // 🔹 Charger depuis SharedPreferences
  void _loadNotes() {
    final data = prefs.getString('notes');
    if (data != null) {
      List decoded = jsonDecode(data);
      _notes = decoded.map((e) => Note.fromJson(e)).toList();
      notifyListeners();
    }
  }

  // 🔹 Sauvegarder dans SharedPreferences
  void _saveNotes() {
    final data = jsonEncode(_notes.map((e) => e.toJson()).toList());
    prefs.setString('notes', data);
  }

  // 🔹 Charger depuis SQLite
  Future<void> loadNotes() async {
    isLoading = true;
    notifyListeners();
    final notes = await _db.getAllNotes();
    _notes = notes;
    _saveNotes();
    isLoading = false;
    notifyListeners();
  }

  // 🔹 Ajouter
  Future<void> addNote(Note note) async {
    await _db.insertNote(note);
    _notes.insert(0, note);
    _saveNotes();
    notifyListeners();
  }

  // 🔹 Modifier
  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _saveNotes();
      notifyListeners();
    }
  }

  // 🔹 Supprimer
  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    _saveNotes();
    notifyListeners();
  }

  // 🔹 Trouver par id
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }
}