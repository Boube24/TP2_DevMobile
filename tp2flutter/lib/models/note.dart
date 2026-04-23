// Représente une note : sérialisation Map pour SQLite et copie partielle.
class Note {
  final String id;
  final String titre;
  final String contenu;
  final String couleur;
  final DateTime dateCreation;
  final DateTime? dateModification;

  const Note({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.couleur,
    required this.dateCreation,
    this.dateModification,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'couleur': couleur,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      titre: (map['titre'] as String?) ?? '',
      contenu: (map['contenu'] as String?) ?? '',
      couleur: (map['couleur'] as String?) ?? '#FFE082',
      dateCreation: DateTime.parse(map['dateCreation'] as String),
      dateModification: (map['dateModification'] as String?) == null
          ? null
          : DateTime.parse(map['dateModification'] as String),
    );
  }

  Note copyWith({
    String? id,
    String? titre,
    String? contenu,
    String? couleur,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Note(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      couleur: couleur ?? this.couleur,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}

