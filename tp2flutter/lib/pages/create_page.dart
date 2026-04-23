// Création ou modification d'une note (titre, contenu, couleur).
import 'package:flutter/material.dart';

import '../models/note.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key, this.note});

  final Note? note;

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  late TextEditingController _titreController;
  late TextEditingController _contenuController;
  String _selectedColor = '#FFE082';
  bool _isEditing = false;

  static const List<String> _colors = [
    '#FFE082',
    '#EF9A9A',
    '#A5D6A7',
    '#90CAF9',
    '#CE93D8',
    '#FFCC80',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    _titreController = TextEditingController(text: widget.note?.titre ?? '');
    _contenuController = TextEditingController(text: widget.note?.contenu ?? '');
    _selectedColor = widget.note?.couleur ?? '#FFE082';
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la note' : 'Nouvelle note'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                maxLength: 60,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contenuController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                minLines: 4,
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              const Text('Couleur :'),
              const SizedBox(height: 8),
              Row(
                children: _colors.map((c) {
                  final isSelected = c == _selectedColor;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hexToColor(c),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final titre = _titreController.text.trim();
                    final contenu = _contenuController.text.trim();
                    if (titre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Le titre ne peut pas être vide'),
                        ),
                      );
                      return;
                    }

                    if (!_isEditing) {
                      final note = Note(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        titre: titre,
                        contenu: contenu,
                        couleur: _selectedColor,
                        dateCreation: DateTime.now(),
                      );
                      Navigator.pop(context, note);
                    } else {
                      final updated = widget.note!.copyWith(
                        titre: titre,
                        contenu: contenu,
                        couleur: _selectedColor,
                        dateModification: DateTime.now(),
                      );
                      Navigator.pop(context, updated);
                    }
                  },
                  child: const Text('Sauvegarder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

