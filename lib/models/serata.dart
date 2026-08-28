class Serata {
  String id;
  String titolo;
  DateTime data;
  String luogo;
  String descrizione;
  List<String> partecipantiIds;
  List<String> giochiIds;
  String stato;
  String note;

  Serata({
    required this.id,
    required this.titolo,
    required this.data,
    this.luogo = '',
    this.descrizione = '',
    this.partecipantiIds = const [],
    this.giochiIds = const [],
    this.stato = 'Futura',
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titolo': titolo,
      'data': data.toIso8601String(),
      'luogo': luogo,
      'descrizione': descrizione,
      'partecipantiIds': partecipantiIds,
      'giochiIds': giochiIds,
      'stato': stato,
      'note': note,
    };
  }

  factory Serata.fromMap(Map<String, dynamic> map) {
    return Serata(
      id: map['id'],
      titolo: map['titolo'],
      data: DateTime.parse(map['data']),
      luogo: map['luogo'] ?? '',
      descrizione: map['descrizione'] ?? '',
      partecipantiIds: List<String>.from(map['partecipantiIds'] ?? []),
      giochiIds: List<String>.from(map['giochiIds'] ?? []),
      stato: map['stato'] ?? 'Futura',
      note: map['note'] ?? '',
    );
  }
}
