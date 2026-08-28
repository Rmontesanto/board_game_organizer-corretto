import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/gioco.dart';
import '../../data/database.dart';

class SuggeritoreScreen extends StatefulWidget {
  const SuggeritoreScreen({super.key});

  @override
  State<SuggeritoreScreen> createState() => _SuggeritoreScreenState();
}

class _SuggeritoreScreenState extends State<SuggeritoreScreen> {
  List<Gioco> _tuttiGiochi = [];
  List<Gioco> _giochiSuggeriti = [];
  Gioco? _giocoRandom;
  int _numGiocatori = 2;
  String _difficolta = 'Tutti';
  String _categoria = 'Tutti';
  int _durataMax = 180;
  bool _cercato = false;

  final List<String> _difficolta_list = [
    'Tutti',
    'Facile',
    'Media',
    'Difficile',
    'Esperto',
  ];
  final List<String> _categorie = [
    'Tutti',
    'Strategia',
    'Famiglia',
    'Cooperativo',
    'Party',
    'Carte',
    'Dadi',
    'Avventura',
    'Altro',
  ];

  @override
  void initState() {
    super.initState();
    _caricaGiochi();
  }

  Future<void> _caricaGiochi() async {
    final giochi = await Database.getGiochi();
    setState(() => _tuttiGiochi = giochi);
  }

  void _cercaGiochi() {
    setState(() {
      _cercato = true;
      _giocoRandom = null;
      _giochiSuggeriti = _tuttiGiochi.where((g) {
        final matchGiocatori =
            g.minGiocatori <= _numGiocatori && g.maxGiocatori >= _numGiocatori;
        final matchDifficolta =
            _difficolta == 'Tutti' || g.difficolta == _difficolta;
        final matchCategoria =
            _categoria == 'Tutti' || g.categoria == _categoria;
        final matchDurata = g.durata <= _durataMax;
        return matchGiocatori &&
            matchDifficolta &&
            matchCategoria &&
            matchDurata;
      }).toList();
    });
  }

  void _giocoACaso() {
    if (_giochiSuggeriti.isEmpty) return;
    final random = Random();
    setState(() {
      _giocoRandom = _giochiSuggeriti[random.nextInt(_giochiSuggeriti.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggeritore giochi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quanti giocatori siete?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _numGiocatori.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _numGiocatori.toString(),
                          onChanged: (v) =>
                              setState(() => _numGiocatori = v.toInt()),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '$_numGiocatori',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Durata massima (minuti)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _durataMax.toDouble(),
                          min: 15,
                          max: 300,
                          divisions: 19,
                          label: '$_durataMax min',
                          onChanged: (v) =>
                              setState(() => _durataMax = v.toInt()),
                        ),
                      ),
                      Text('$_durataMax min'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _difficolta,
                    decoration: InputDecoration(
                      labelText: 'Difficoltà',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _difficolta_list
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _difficolta = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _categorie
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _cercaGiochi,
                      icon: const Icon(Icons.search),
                      label: const Text('Trova giochi adatti'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_cercato) ...[
            if (_giochiSuggeriti.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Nessun gioco trovato',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Prova a cambiare i filtri',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_giochiSuggeriti.length} giochi trovati',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _giocoACaso,
                    icon: const Text('🎲'),
                    label: const Text('Gioco a caso!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_giocoRandom != null) ...[
                Card(
                  color: const Color(0xFF1A237E),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '🎲 Gioco suggerito!',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _giocoRandom!.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_giocoRandom!.minGiocatori}-${_giocoRandom!.maxGiocatori} giocatori  •  ${_giocoRandom!.durata} min  •  ${_giocoRandom!.difficolta}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ..._giochiSuggeriti.map(
                (gioco) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1A237E),
                      child: Text(
                        gioco.nome[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(gioco.nome),
                    subtitle: Text(
                      '${gioco.minGiocatori}-${gioco.maxGiocatori} giocatori  •  ${gioco.durata} min',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gioco.difficolta,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
