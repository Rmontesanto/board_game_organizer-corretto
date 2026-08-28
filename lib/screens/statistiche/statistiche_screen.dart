import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/gioco.dart';
import '../../models/giocatore.dart';
import '../../models/partita.dart';
import '../../models/serata.dart';
import '../../data/database.dart';

class StatisticheScreen extends StatefulWidget {
  const StatisticheScreen({super.key});

  @override
  State<StatisticheScreen> createState() => _StatisticheScreenState();
}

class _StatisticheScreenState extends State<StatisticheScreen> {
  List<Gioco> _giochi = [];
  List<Giocatore> _giocatori = [];
  List<Partita> _partite = [];
  List<Serata> _serate = [];

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    final giochi = await Database.getGiochi();
    final giocatori = await Database.getGiocatori();
    final partite = await Database.getPartite();
    final serate = await Database.getSerate();
    setState(() {
      _giochi = giochi;
      _giocatori = giocatori;
      _partite = partite;
      _serate = serate;
    });
  }

  String _nomeGioco(String id) =>
      _giochi.where((g) => g.id == id).firstOrNull?.nome ?? 'Sconosciuto';

  String _nomeGiocatore(String id) =>
      _giocatori.where((g) => g.id == id).firstOrNull?.nome ?? 'Sconosciuto';

  Map<String, int> get _giochiPiuGiocati {
    final conteggio = <String, int>{};
    for (final p in _partite) {
      conteggio[p.giocoId] = (conteggio[p.giocoId] ?? 0) + 1;
    }
    final sorted = conteggio.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  Map<String, int> get _giocatoriPiuVittorie {
    final conteggio = <String, int>{};
    for (final p in _partite) {
      if (p.vincitoreId.isNotEmpty) {
        conteggio[p.vincitoreId] = (conteggio[p.vincitoreId] ?? 0) + 1;
      }
    }
    final sorted = conteggio.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  Map<String, int> get _giochiPerCategoria {
    final conteggio = <String, int>{};
    for (final g in _giochi) {
      final cat = g.categoria.isEmpty ? 'Altro' : g.categoria;
      conteggio[cat] = (conteggio[cat] ?? 0) + 1;
    }
    return conteggio;
  }

  double get _durataMedia {
    if (_partite.isEmpty) return 0;
    final partiteConDurata = _partite.where((p) => p.durata > 0).toList();
    if (partiteConDurata.isEmpty) return 0;
    final totale = partiteConDurata.fold(0, (sum, p) => sum + p.durata);
    return totale / partiteConDurata.length;
  }

  // Giocatori più presenti alle serate
  Map<String, int> get _giocatoriPiuPresenti {
    final conteggio = <String, int>{};
    for (final s in _serate) {
      for (final id in s.partecipantiIds) {
        conteggio[id] = (conteggio[id] ?? 0) + 1;
      }
    }
    final sorted = conteggio.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  // Confronto giochi proposti vs giocati
  Map<String, Map<String, int>> get _confrontoGiochi {
    final proposti = <String, int>{};
    final giocati = <String, int>{};
    for (final s in _serate) {
      for (final id in s.giochiIds) {
        proposti[id] = (proposti[id] ?? 0) + 1;
      }
    }
    for (final p in _partite) {
      giocati[p.giocoId] = (giocati[p.giocoId] ?? 0) + 1;
    }
    final tuttiIds = {...proposti.keys, ...giocati.keys};
    return {
      for (final id in tuttiIds)
        id: {'proposti': proposti[id] ?? 0, 'giocati': giocati[id] ?? 0},
    };
  }

  // Statistiche personali per giocatore
  Map<String, Map<String, int>> get _statsPersonali {
    final stats = <String, Map<String, int>>{};
    for (final g in _giocatori) {
      stats[g.id] = {'partite': 0, 'vittorie': 0};
    }
    for (final p in _partite) {
      for (final id in p.giocatoriIds) {
        if (stats.containsKey(id)) {
          stats[id]!['partite'] = (stats[id]!['partite'] ?? 0) + 1;
        }
      }
      if (p.vincitoreId.isNotEmpty && stats.containsKey(p.vincitoreId)) {
        stats[p.vincitoreId]!['vittorie'] =
            (stats[p.vincitoreId]!['vittorie'] ?? 0) + 1;
      }
    }
    return stats;
  }

  final List<Color> _coloriGrafici = [
    const Color(0xFF1A237E),
    const Color(0xFF3949AB),
    const Color(0xFF7986CB),
    const Color(0xFF5C6BC0),
    const Color(0xFF9FA8DA),
    const Color(0xFF283593),
    const Color(0xFF3F51B5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _caricaDati),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Riepilogo generale
          const Text(
            'Riepilogo generale',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _cardStatistica(
                Icons.games,
                'Giochi',
                _giochi.length.toString(),
                Colors.purple,
              ),
              _cardStatistica(
                Icons.people,
                'Giocatori',
                _giocatori.length.toString(),
                Colors.blue,
              ),
              _cardStatistica(
                Icons.event,
                'Serate',
                _serate.length.toString(),
                Colors.green,
              ),
              _cardStatistica(
                Icons.sports_esports,
                'Partite',
                _partite.length.toString(),
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Grafico a torta — categorie
          if (_giochiPerCategoria.isNotEmpty) ...[
            const Text(
              'Giochi per categoria',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _giochiPerCategoria.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final i = entry.key;
                                final e = entry.value;
                                return PieChartSectionData(
                                  value: e.value.toDouble(),
                                  title: '${e.value}',
                                  color:
                                      _coloriGrafici[i % _coloriGrafici.length],
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              })
                              .toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _giochiPerCategoria.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final i = entry.key;
                            final e = entry.value;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        _coloriGrafici[i %
                                            _coloriGrafici.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  e.key,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          })
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Giocatori più presenti
          if (_giocatoriPiuPresenti.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Giocatori più presenti alle serate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _giocatoriPiuPresenti.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                        final rank = entry.key + 1;
                        final e = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF1A237E),
                                child: Text(
                                  '$rank',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_nomeGiocatore(e.key))),
                              Text(
                                '${e.value} serate',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),
          ],

          // Confronto giochi proposti vs giocati
          if (_confrontoGiochi.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Proposti vs Giocati',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A237E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Proposto', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 16),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7986CB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Giocato', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._confrontoGiochi.entries.map((e) {
                      final nome = _nomeGioco(e.key);
                      final proposti = e.value['proposti'] ?? 0;
                      final giocati = e.value['giocati'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nome, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: proposti > 0 ? 1.0 : 0,
                                    backgroundColor: Colors.grey[200],
                                    color: const Color(0xFF1A237E),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$proposti',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: proposti > 0
                                        ? giocati / proposti
                                        : 0,
                                    backgroundColor: Colors.grey[200],
                                    color: const Color(0xFF7986CB),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$giocati',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],

          // Statistiche personali
          if (_statsPersonali.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Statistiche personali',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ..._giocatori.map((g) {
              final stats = _statsPersonali[g.id];
              if (stats == null) return const SizedBox();
              final partite = stats['partite'] ?? 0;
              final vittorie = stats['vittorie'] ?? 0;
              final tasso = partite > 0
                  ? (vittorie / partite * 100).toStringAsFixed(0)
                  : '0';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF1A237E),
                        child: Text(
                          g.nome[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (g.nickname.isNotEmpty)
                              Text(
                                '@${g.nickname}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$partite partite',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '$vittorie vittorie',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$tasso% win rate',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          // Grafico a barre — giochi più giocati
          if (_giochiPiuGiocati.isNotEmpty) ...[
            const Text(
              'Giochi più giocati',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          (_giochiPiuGiocati.values.isNotEmpty
                                  ? _giochiPiuGiocati.values.reduce(
                                      (a, b) => a > b ? a : b,
                                    )
                                  : 1)
                              .toDouble() +
                          1,
                      barGroups: _giochiPiuGiocati.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final i = entry.key;
                            final e = entry.value;
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.toDouble(),
                                  color:
                                      _coloriGrafici[i % _coloriGrafici.length],
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          })
                          .toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final keys = _giochiPiuGiocati.keys.toList();
                              if (value.toInt() < keys.length) {
                                final nome = _nomeGioco(keys[value.toInt()]);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    nome.length > 8
                                        ? '${nome.substring(0, 8)}...'
                                        : nome,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Classifica vittorie
          if (_giocatoriPiuVittorie.isNotEmpty) ...[
            const Text(
              'Classifica vittorie',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _giocatoriPiuVittorie.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                        final rank = entry.key + 1;
                        final e = entry.value;
                        final colori = [
                          Colors.amber,
                          Colors.grey,
                          Colors.brown,
                        ];
                        final icone = ['🥇', '🥈', '🥉'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Text(
                                rank <= 3 ? icone[rank - 1] : '$rank.',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_nomeGiocatore(e.key))),
                              Text(
                                '${e.value} vittorie',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rank <= 3
                                      ? colori[rank - 1]
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Durata media
          if (_durataMedia > 0) ...[
            const Text(
              'Durata media partite',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Color(0xFF1A237E), size: 32),
                    const SizedBox(width: 16),
                    Text(
                      '${_durataMedia.toStringAsFixed(0)} minuti in media',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardStatistica(
    IconData icon,
    String label,
    String valore,
    Color colore,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colore, size: 28),
            const SizedBox(height: 8),
            Text(
              valore,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colore,
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
