class Partita {
  String id;
  String giocoId;
  String serataId;
  DateTime data;
  List<String> giocatoriIds;
  Map<String, int> punteggi;
  String vincitoreId;
  int durata;
  String note;
  int valutazione;

  Partita({
    required this.id,
    required this.giocoId,
    this.serataId = '',
    required this.data,
    this.giocatoriIds = const [],
    this.punteggi = const {},
    this.vincitoreId = '',
    this.durata = 0,
    this.note = '',
    this.valutazione = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'giocoId': giocoId,
      'serataId': serataId,
      'data': data.toIso8601String(),
      'giocatoriIds': giocatoriIds,
      'punteggi': punteggi,
      'vincitoreId': vincitoreId,
      'durata': durata,
      'note': note,
      'valutazione': valutazione,
    };
  }

  factory Partita.fromMap(Map<String, dynamic> map) {
    return Partita(
      id: map['id'],
      giocoId: map['giocoId'],
      serataId: map['serataId'] ?? '',
      data: DateTime.parse(map['data']),
      giocatoriIds: List<String>.from(map['giocatoriIds'] ?? []),
      punteggi: Map<String, int>.from(map['punteggi'] ?? {}),
      vincitoreId: map['vincitoreId'] ?? '',
      durata: map['durata'] ?? 0,
      note: map['note'] ?? '',
      valutazione: map['valutazione'] ?? 0,
    );
  }
}
