class Gioco {
  String id;
  String nome;
  String descrizione;
  String categoria;
  int minGiocatori;
  int maxGiocatori;
  int durata;
  String difficolta;
  String stato;
  String note;
  int etaConsigliata;

  Gioco({
    required this.id,
    required this.nome,
    this.descrizione = '',
    this.categoria = '',
    this.minGiocatori = 2,
    this.maxGiocatori = 4,
    this.durata = 60,
    this.difficolta = 'Media',
    this.stato = 'Posseduto',
    this.note = '',
    this.etaConsigliata = 8,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'categoria': categoria,
      'minGiocatori': minGiocatori,
      'maxGiocatori': maxGiocatori,
      'durata': durata,
      'difficolta': difficolta,
      'stato': stato,
      'note': note,
      'etaConsigliata': etaConsigliata,
    };
  }

  factory Gioco.fromMap(Map<String, dynamic> map) {
    return Gioco(
      id: map['id'],
      nome: map['nome'],
      descrizione: map['descrizione'] ?? '',
      categoria: map['categoria'] ?? '',
      minGiocatori: map['minGiocatori'] ?? 2,
      maxGiocatori: map['maxGiocatori'] ?? 4,
      durata: map['durata'] ?? 60,
      difficolta: map['difficolta'] ?? 'Media',
      stato: map['stato'] ?? 'Posseduto',
      note: map['note'] ?? '',
      etaConsigliata: map['etaConsigliata'] ?? 8,
    );
  }
}
