class Giocatore {
  String id;
  String nome;
  String nickname;
  String livelloEsperienza;
  String note;
  List<String> giochiPreferitiIds; // ← NUOVO

  Giocatore({
    required this.id,
    required this.nome,
    this.nickname = '',
    this.livelloEsperienza = 'Principiante',
    this.note = '',
    this.giochiPreferitiIds = const [], // ← NUOVO
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'nickname': nickname,
      'livelloEsperienza': livelloEsperienza,
      'note': note,
      'giochiPreferitiIds': giochiPreferitiIds, // ← NUOVO
    };
  }

  factory Giocatore.fromMap(Map<String, dynamic> map) {
    return Giocatore(
      id: map['id'],
      nome: map['nome'],
      nickname: map['nickname'] ?? '',
      livelloEsperienza: map['livelloEsperienza'] ?? 'Principiante',
      note: map['note'] ?? '',
      giochiPreferitiIds: List<String>.from(
        map['giochiPreferitiIds'] ?? [],
      ), // ← NUOVO
    );
  }
}
